import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/exercise_log.dart';

class BadgeStableLogState {
  final int stableDayKey;
  final DateTime trustedLocalTimestamp;

  const BadgeStableLogState({
    required this.stableDayKey,
    required this.trustedLocalTimestamp,
  });
}

class BadgeUptimeClock {
  static const MethodChannel _channel = MethodChannel('hf.sec.guard');
  static const int _millisecondsPerDay = 24 * 60 * 60 * 1000;
  static const int _dayKeyStridePerBoot = 100000;
  static const int _rebootDetectionToleranceMs = 5000;
  static const int _maxForwardDriftMs = 30 * 60 * 60 * 1000; // 30 hours
  static const int _monotonicBackToleranceMs = 5 * 60 * 1000; // 5 minutes
  static const int _maxForwardDriftAfterRebootMs =
      90 * _millisecondsPerDay; // 90 days

  static const String _logDayKeyPrefix = 'badge_uptime_daykey_log_';
  static const String _calendarDayKeyPrefix = 'badge_calendar_daykey_log_';
  static const String _trustedTimestampPrefix = 'badge_ts_trusted_ms_';
  static const String _trustedTimestampSigPrefix = 'badge_ts_trusted_sig_';
  static const String _timestampSecretKey = 'badge_ts_secret_v1';
  static const String _lastTrustedEpochMsKey = 'badge_ts_last_epoch_ms';
  static const String _lastTrustedUptimeMsKey = 'badge_ts_last_uptime_ms';
  static const String _lastUptimeKey = 'badge_uptime_last_uptime_ms';
  static const String _bootSequenceKey = 'badge_uptime_boot_sequence';

  final Stopwatch _fallbackProcessStopwatch = Stopwatch()..start();

  Future<void> clearPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    final keysToRemove = prefs.getKeys().where((key) {
      return key == _timestampSecretKey ||
          key == _lastTrustedEpochMsKey ||
          key == _lastTrustedUptimeMsKey ||
          key == _lastUptimeKey ||
          key == _bootSequenceKey ||
          key.startsWith(_logDayKeyPrefix) ||
          key.startsWith(_calendarDayKeyPrefix) ||
          key.startsWith(_trustedTimestampPrefix) ||
          key.startsWith(_trustedTimestampSigPrefix);
    }).toList(growable: false);

    for (final key in keysToRemove) {
      await prefs.remove(key);
    }
  }

  Future<void> debugSeedStableTimeline(List<ExerciseLog> logs) async {
    if (!kDebugMode) {
      throw StateError(
          'debugSeedStableTimeline is only available in debug mode.');
    }
    if (logs.isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final secret = await _loadOrCreateSecret(prefs);
    final sortedLogs = [...logs]..sort((a, b) {
        final byTimestamp = a.timestamp.compareTo(b.timestamp);
        if (byTimestamp != 0) {
          return byTimestamp;
        }
        return a.id.compareTo(b.id);
      });

    for (final log in sortedLogs) {
      if (log.id <= 0) {
        continue;
      }

      final trustedTimestampMs = log.timestamp.toUtc().millisecondsSinceEpoch;
      final dayKey = _calendarDayKeyFromMs(trustedTimestampMs);

      await prefs.setInt(_logDayKeyKey(log.id), dayKey);
      await prefs.setInt(_calendarDayKeyKey(log.id), dayKey);
      await _storeTrustedTimestamp(
        log.id,
        trustedTimestampMs,
        prefs,
        secretBytes: secret,
      );
    }

    final lastTimestampMs =
        sortedLogs.last.timestamp.toUtc().millisecondsSinceEpoch;
    await prefs.setInt(_lastTrustedEpochMsKey, lastTimestampMs);
    await prefs.setInt(_lastTrustedUptimeMsKey, 0);
    await prefs.setInt(_lastUptimeKey, 0);
    await prefs.setInt(_bootSequenceKey, 0);
  }

  Future<int> ensureDayKeyForLog(ExerciseLog log) async {
    if (log.id <= 0) {
      return 0;
    }

    final prefs = await SharedPreferences.getInstance();
    final key = _logDayKeyKey(log.id);
    final existing = prefs.getInt(key);
    if (existing != null) {
      return existing;
    }

    final uptimeMs = await _currentUptimeMs();
    var bootSequence = prefs.getInt(_bootSequenceKey) ?? 0;
    final lastUptime = prefs.getInt(_lastUptimeKey);
    if (lastUptime != null &&
        uptimeMs + _rebootDetectionToleranceMs < lastUptime) {
      bootSequence += 1;
      await prefs.setInt(_bootSequenceKey, bootSequence);
    }

    await prefs.setInt(_lastUptimeKey, uptimeMs);

    final dayInBoot = uptimeMs ~/ _millisecondsPerDay;
    final dayKey = (bootSequence * _dayKeyStridePerBoot) + dayInBoot;
    await prefs.setInt(key, dayKey);
    final trustedTimestampMs =
        await _resolveTrustedTimestampMs(log, prefs, uptimeMs);
    await _storeTrustedTimestamp(log.id, trustedTimestampMs, prefs);
    await prefs.setInt(
      _calendarDayKeyKey(log.id),
      _calendarDayKeyFromMs(trustedTimestampMs),
    );
    return dayKey;
  }

  Future<Map<int, int>> readDayKeysForLogs(List<ExerciseLog> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final result = <int, int>{};
    for (final log in logs) {
      if (log.id <= 0) {
        continue;
      }
      final dayKey = prefs.getInt(_logDayKeyKey(log.id));
      if (dayKey != null) {
        result[log.id] = dayKey;
      }
    }
    return result;
  }

  Future<Map<int, int>> readStableDayKeysForLogs(List<ExerciseLog> logs) async {
    final states = await readStableStatesForLogs(logs);
    return {
      for (final entry in states.entries) entry.key: entry.value.stableDayKey,
    };
  }

  Future<Map<int, BadgeStableLogState>> readStableStatesForLogs(
    List<ExerciseLog> logs,
  ) async {
    if (logs.isEmpty) {
      return {};
    }

    final prefs = await SharedPreferences.getInstance();
    final secret = await _loadOrCreateSecret(prefs);
    final pendingLogs = <_PendingStableLog>[];

    for (final log in logs) {
      if (log.id <= 0) {
        continue;
      }

      pendingLogs.add(
        _PendingStableLog(
          log: log,
          uptimeDayKey: prefs.getInt(_logDayKeyKey(log.id)),
          candidateTimestampMs:
              await _readTrustedTimestampMs(log, prefs, secret) ??
                  log.timestamp.toUtc().millisecondsSinceEpoch,
        ),
      );
    }

    pendingLogs.sort((a, b) {
      final byTimestamp = a.candidateTimestampMs.compareTo(
        b.candidateTimestampMs,
      );
      if (byTimestamp != 0) {
        return byTimestamp;
      }
      return a.log.id.compareTo(b.log.id);
    });

    final result = <int, BadgeStableLogState>{};
    int? lastAssignedDayKey;
    int? lastAssignedTimestampMs;
    int? lastUptimeDayKey;

    for (final pendingLog in pendingLogs) {
      final log = pendingLog.log;
      var stableTimestampMs = pendingLog.candidateTimestampMs;
      if (lastAssignedTimestampMs != null) {
        final minAllowed = lastAssignedTimestampMs - _monotonicBackToleranceMs;
        if (stableTimestampMs < minAllowed) {
          stableTimestampMs = lastAssignedTimestampMs;
        }
      }

      await _storeTrustedTimestamp(log.id, stableTimestampMs, prefs,
          secretBytes: secret);

      final calendarKeyStorage = _calendarDayKeyKey(log.id);
      var calendarDayKey = _calendarDayKeyFromMs(stableTimestampMs);
      await prefs.setInt(calendarKeyStorage, calendarDayKey);

      var stableDayKey = calendarDayKey;
      if (lastAssignedDayKey != null) {
        if (stableDayKey < lastAssignedDayKey) {
          stableDayKey = lastAssignedDayKey;
        } else if (pendingLog.uptimeDayKey != null &&
            lastUptimeDayKey != null &&
            pendingLog.uptimeDayKey == lastUptimeDayKey &&
            stableDayKey > lastAssignedDayKey) {
          stableDayKey = lastAssignedDayKey;
        }
      }

      result[log.id] = BadgeStableLogState(
        stableDayKey: stableDayKey,
        trustedLocalTimestamp: DateTime.fromMillisecondsSinceEpoch(
          stableTimestampMs,
          isUtc: true,
        ).toLocal(),
      );
      lastAssignedDayKey = stableDayKey;
      lastAssignedTimestampMs = stableTimestampMs;
      if (pendingLog.uptimeDayKey != null) {
        lastUptimeDayKey = pendingLog.uptimeDayKey;
      }
    }

    return result;
  }

  Future<DateTime> readTrustedNow() async {
    final prefs = await SharedPreferences.getInstance();
    final uptimeMs = await _currentUptimeMs();
    final trustedNowMs = _clampTrustedTimestampMs(
      rawTimestampMs: DateTime.now().toUtc().millisecondsSinceEpoch,
      uptimeMs: uptimeMs,
      lastTrustedEpochMs: prefs.getInt(_lastTrustedEpochMsKey),
      lastTrustedUptimeMs: prefs.getInt(_lastTrustedUptimeMsKey),
    );
    return DateTime.fromMillisecondsSinceEpoch(
      trustedNowMs,
      isUtc: true,
    ).toLocal();
  }

  Future<void> backfillMissingDayKeys(List<ExerciseLog> logs) async {
    if (logs.isEmpty) {
      return;
    }

    final sortedLogs = [...logs]..sort((a, b) {
        final byTimestamp = a.timestamp.compareTo(b.timestamp);
        if (byTimestamp != 0) {
          return byTimestamp;
        }
        return a.id.compareTo(b.id);
      });
    final prefs = await SharedPreferences.getInstance();
    final uptimeMs = await _currentUptimeMs();

    var syntheticDayKey = 0;
    DateTime? maxObservedDate;

    for (final log in sortedLogs) {
      if (log.id <= 0) {
        continue;
      }

      final storageKey = _logDayKeyKey(log.id);
      final existing = prefs.getInt(storageKey);
      final calendarStorageKey = _calendarDayKeyKey(log.id);
      if (prefs.getInt(calendarStorageKey) == null ||
          prefs.getInt(_trustedTimestampKey(log.id)) == null) {
        final trustedTimestampMs =
            await _resolveTrustedTimestampMs(log, prefs, uptimeMs);
        await _storeTrustedTimestamp(log.id, trustedTimestampMs, prefs);
        await prefs.setInt(
          calendarStorageKey,
          _calendarDayKeyFromMs(trustedTimestampMs),
        );
      }
      if (existing != null) {
        syntheticDayKey = existing;
        continue;
      }

      // Migration for old logs before uptime tracking existed.
      // This uses only forward day movement so backdated logs cannot gain
      // extra progress.
      final logDate = DateTime(
        log.timestamp.year,
        log.timestamp.month,
        log.timestamp.day,
      );
      if (maxObservedDate == null) {
        maxObservedDate = logDate;
      } else if (logDate.isAfter(maxObservedDate)) {
        final step = logDate.difference(maxObservedDate).inDays;
        syntheticDayKey += step <= 0 ? 1 : step;
        maxObservedDate = logDate;
      }

      await prefs.setInt(storageKey, syntheticDayKey);
    }
  }

  String _logDayKeyKey(int logId) => '$_logDayKeyPrefix$logId';
  String _calendarDayKeyKey(int logId) => '$_calendarDayKeyPrefix$logId';
  String _trustedTimestampKey(int logId) => '$_trustedTimestampPrefix$logId';
  String _trustedTimestampSigKey(int logId) =>
      '$_trustedTimestampSigPrefix$logId';

  Future<int> _resolveTrustedTimestampMs(
    ExerciseLog log,
    SharedPreferences prefs,
    int uptimeMs,
  ) async {
    final existing = prefs.getInt(_trustedTimestampKey(log.id));
    if (existing != null) {
      final secret = await _loadOrCreateSecret(prefs);
      final sig = prefs.getString(_trustedTimestampSigKey(log.id));
      if (sig != null && _verifySignature(log.id, existing, sig, secret)) {
        return existing;
      }
    }

    final trustedMs = _clampTrustedTimestampMs(
      rawTimestampMs: log.timestamp.toUtc().millisecondsSinceEpoch,
      uptimeMs: uptimeMs,
      lastTrustedEpochMs: prefs.getInt(_lastTrustedEpochMsKey),
      lastTrustedUptimeMs: prefs.getInt(_lastTrustedUptimeMsKey),
    );

    await prefs.setInt(_lastTrustedEpochMsKey, trustedMs);
    await prefs.setInt(_lastTrustedUptimeMsKey, uptimeMs);
    return trustedMs;
  }

  int _clampTrustedTimestampMs({
    required int rawTimestampMs,
    required int uptimeMs,
    required int? lastTrustedEpochMs,
    required int? lastTrustedUptimeMs,
  }) {
    var trustedMs = rawTimestampMs;

    if (lastTrustedEpochMs != null && lastTrustedUptimeMs != null) {
      final minAllowed = lastTrustedEpochMs - _monotonicBackToleranceMs;
      final rebootDetected =
          uptimeMs + _rebootDetectionToleranceMs < lastTrustedUptimeMs;

      if (rebootDetected) {
        final maxForward = lastTrustedEpochMs + _maxForwardDriftAfterRebootMs;
        if (trustedMs > maxForward) {
          trustedMs = maxForward;
        }
      } else {
        final uptimeDelta = max(0, uptimeMs - lastTrustedUptimeMs);
        final maxForward =
            lastTrustedEpochMs + uptimeDelta + _maxForwardDriftMs;
        if (trustedMs > maxForward) {
          trustedMs = maxForward;
        }
      }

      if (trustedMs < minAllowed) {
        trustedMs = lastTrustedEpochMs;
      }
    }

    return trustedMs;
  }

  Future<int?> _readTrustedTimestampMs(
    ExerciseLog log,
    SharedPreferences prefs,
    List<int> secret,
  ) async {
    final trustedMs = prefs.getInt(_trustedTimestampKey(log.id));
    if (trustedMs == null) {
      return null;
    }
    final sig = prefs.getString(_trustedTimestampSigKey(log.id));
    if (sig == null) {
      return null;
    }
    if (!_verifySignature(log.id, trustedMs, sig, secret)) {
      return null;
    }
    return trustedMs;
  }

  Future<void> _storeTrustedTimestamp(
    int logId,
    int timestampMs,
    SharedPreferences prefs, {
    List<int>? secretBytes,
  }) async {
    final secret = secretBytes ?? await _loadOrCreateSecret(prefs);
    final sig = _signatureFor(logId, timestampMs, secret);
    await prefs.setInt(_trustedTimestampKey(logId), timestampMs);
    await prefs.setString(_trustedTimestampSigKey(logId), sig);
  }

  Future<List<int>> _loadOrCreateSecret(SharedPreferences prefs) async {
    final existing = prefs.getString(_timestampSecretKey);
    if (existing != null && existing.isNotEmpty) {
      try {
        return base64Url.decode(existing);
      } catch (_) {
        // Fall through to regenerate.
      }
    }
    final rand = Random.secure();
    final bytes = List<int>.generate(32, (_) => rand.nextInt(256));
    await prefs.setString(_timestampSecretKey, base64UrlEncode(bytes));
    return bytes;
  }

  String _signatureFor(int logId, int timestampMs, List<int> secret) {
    final payload = '$logId|$timestampMs';
    final hmacSha256 = Hmac(sha256, secret);
    final digest = hmacSha256.convert(utf8.encode(payload));
    return base64UrlEncode(digest.bytes);
  }

  bool _verifySignature(
    int logId,
    int timestampMs,
    String signature,
    List<int> secret,
  ) {
    final expected = _signatureFor(logId, timestampMs, secret);
    return signature == expected;
  }

  int _calendarDayKeyFromMs(int timestampMs) {
    final local = DateTime.fromMillisecondsSinceEpoch(
      timestampMs,
      isUtc: true,
    ).toLocal();
    final utcMidnight = DateTime.utc(local.year, local.month, local.day);
    return utcMidnight.millisecondsSinceEpoch ~/ _millisecondsPerDay;
  }

  Future<int> _currentUptimeMs() async {
    try {
      final dynamic raw = await _channel.invokeMethod('systemUptimeMs');
      if (raw is int && raw >= 0) {
        return raw;
      }
      if (raw is double && raw >= 0) {
        return raw.toInt();
      }
      if (raw is num && raw >= 0) {
        return raw.toInt();
      }
    } catch (_) {
      // Fall through to process uptime fallback.
    }
    return _fallbackProcessStopwatch.elapsedMilliseconds;
  }
}

class _PendingStableLog {
  final ExerciseLog log;
  final int? uptimeDayKey;
  final int candidateTimestampMs;

  const _PendingStableLog({
    required this.log,
    required this.uptimeDayKey,
    required this.candidateTimestampMs,
  });
}
