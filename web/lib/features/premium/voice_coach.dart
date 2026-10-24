import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceCoach {
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _countingPlayer = AudioPlayer();
  bool _isCountingEnabled = false;
  bool _isPremium = false;
  final String _defaultLanguage = 'en-US';
  String _countingLanguage = 'en-US';
  String _activeLanguage = 'en-US';
  final Set<String> _availableTtsLanguages = {};
  final List<Map<String, String>> _availableTtsVoices = [];
  int? _lastSpokenCount;
  DateTime? _lastSpokenCountAt;
  static const Duration _countSpeakCooldown = Duration(milliseconds: 650);

  static const Map<String, String> _assetCountingLanguageFolders = {
    'my-MM': 'myanmar-v',
    'fi-FI': 'finnish-v',
    'th-TH': 'thai-v',
  };

  // Extra locale fallbacks for engines that don't expose certain regional tags.
  static const Map<String, List<String>> _languageFallbacks = {
    'pt-br': ['pt-pt', 'pt'],
    'pt-pt': ['pt-br', 'pt'],
    'de-de': ['de-at', 'de-ch', 'de'],
    'de-at': ['de-de', 'de'],
    'de-ch': ['de-de', 'de'],
    'ko-kr': ['ko'],
    // Mandarin can surface as zh-Hans or cmn in some engines.
    'zh-cn': ['zh-hans-cn', 'cmn-hans-cn', 'cmn-cn', 'zh'],
    'zh-hans-cn': ['zh-cn', 'cmn-hans-cn', 'zh'],
  };

  static final VoiceCoach _instance = VoiceCoach._internal();
  factory VoiceCoach() => _instance;
  VoiceCoach._internal();

  Future<void> initialize() async {
    await _setBestTtsEngine();
    await _tts.setLanguage(_defaultLanguage);
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    await _tts.setQueueMode(0);
    _countingPlayer.audioCache = AudioCache(prefix: 'assets/');
    // Use mediaPlayer for MP3 compatibility across devices.
    await _countingPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _countingPlayer.setReleaseMode(ReleaseMode.stop);
    await _countingPlayer.setVolume(1.0);
    await _loadAvailableTtsLanguages();
    await _loadAvailableTtsVoices();

    _tts.setStartHandler(() {
      print('TTS started');
    });

    _tts.setCompletionHandler(() {
      print('TTS completed');
    });

    _tts.setErrorHandler((msg) {
      print('TTS error: $msg');
    });
  }

  Future<void> warmUpCounting() async {
    await _preloadCountingAssets(_countingLanguage);
    await _warmUpTts(_countingLanguage);
  }

  Future<void> speakCount(int count) async {
    if (!_isCountingEnabled || !_isPremium) return;

    try {
      final now = DateTime.now();
      final lastSpokenCountAt = _lastSpokenCountAt;
      if (_lastSpokenCount == count) {
        return;
      }
      if (lastSpokenCountAt != null &&
          now.difference(lastSpokenCountAt) < _countSpeakCooldown) {
        return;
      }

      _lastSpokenCount = count;
      _lastSpokenCountAt = now;

      if (_isAssetCountingLanguage(_countingLanguage)) {
        await _speakCountFromAsset(count);
        return;
      }

      await _countingPlayer.stop();
      await _tts.stop();
      final isKorean = _isKoreanLanguage(_countingLanguage);
      final languageSet = await _setLanguage(_countingLanguage);
      if (!languageSet && isKorean) {
        await _setLanguage('ko-KR');
      }
      final textToSpeak = isKorean ? _countToKorean(count) : count.toString();
      await _tts.speak(textToSpeak);
    } catch (e) {
      try {
        await _countingPlayer.stop();
        await _setLanguage(_defaultLanguage);
        await _tts.speak(count.toString());
      } catch (_) {
        print('Error speaking count: $e');
      }
    }
  }

  void setCountingEnabled(bool enabled) {
    _isCountingEnabled = enabled;
  }

  void setPremium(bool premium) {
    _isPremium = premium;
  }

  void setCountingLanguage(String languageCode) {
    _countingLanguage = languageCode;
  }

  Future<void> _preloadCountingAssets(String languageCode) async {
    final folder = _assetCountingLanguageFolders[languageCode];
    final cache = _countingPlayer.audioCache;
    if (folder == null || cache == null) return;

    final assets = List<String>.generate(
      10,
      (index) => 'data/$folder/${index + 1}.mp3',
    );

    try {
      await cache.loadAll(assets);
    } catch (e) {
      print('Error preloading count assets: $e');
    }
  }

  Future<void> _warmUpTts(String languageCode) async {
    try {
      await _setLanguage(languageCode);
      await _tts.setVolume(0.0);
      await _tts.speak('1');
      await _tts.stop();
    } catch (e) {
      print('Error warming up TTS: $e');
    } finally {
      await _tts.setVolume(1.0);
    }
  }

  bool _isAssetCountingLanguage(String languageCode) {
    return _assetCountingLanguageFolders.containsKey(languageCode);
  }

  Future<void> _speakCountFromAsset(int count) async {
    final folder = _assetCountingLanguageFolders[_countingLanguage];
    if (folder == null) {
      await _setLanguage(_countingLanguage);
      await _tts.speak(count.toString());
      return;
    }

    if (count < 1 || count > 100) {
      await _setLanguage(_countingLanguage);
      await _tts.speak(count.toString());
      return;
    }

    final assetPath = 'assets/data/$folder/$count.mp3';
    await _tts.stop();
    await _countingPlayer.stop();
    try {
      await _countingPlayer.play(
        AssetSource('data/$folder/$count.mp3'),
        volume: 1.0,
      );
    } catch (e) {
      await _setLanguage(_defaultLanguage);
      await _tts.speak(count.toString());
      print('Error playing count asset: $e');
      print('Missing/invalid count asset path: $assetPath');
    }
  }

  Future<bool> _setLanguage(String languageCode) async {
    if (_availableTtsLanguages.isEmpty) {
      await _loadAvailableTtsLanguages();
    }
    if (_availableTtsVoices.isEmpty) {
      await _loadAvailableTtsVoices();
    }
    final normalized = _normalizeLanguageCode(languageCode);
    final base = normalized.split('-').first;
    final candidates = _buildLanguageCandidates(languageCode);
    for (final candidate in candidates) {
      if (_activeLanguage == candidate) {
        return true;
      }
      try {
        final available = await _tts.isLanguageAvailable(candidate);
        if (_isTtsSuccess(available)) {
          final result = await _tts.setLanguage(candidate);
          if (_isTtsSuccess(result)) {
            _activeLanguage = candidate;
            return true;
          }
        } else {
          // Some engines incorrectly report availability; try setting anyway.
          final result = await _tts.setLanguage(candidate);
          if (_isTtsSuccess(result)) {
            _activeLanguage = candidate;
            return true;
          }
        }
      } catch (_) {
        try {
          final result = await _tts.setLanguage(candidate);
          if (_isTtsSuccess(result)) {
            _activeLanguage = candidate;
            return true;
          }
        } catch (_) {
          // Try next candidate.
        }
      }
    }

    final voice = _findVoiceForLanguage(languageCode);
    if (voice != null) {
      try {
        final result = await _tts.setVoice(voice);
        if (_isTtsSuccess(result)) {
          final voiceLocale = voice['locale'] ?? languageCode;
          try {
            final langResult = await _tts.setLanguage(voiceLocale);
            if (_isTtsSuccess(langResult)) {
              _activeLanguage = voiceLocale;
              return true;
            }
          } catch (_) {
            // Continue with voice-only fallback.
          }
          _activeLanguage = voiceLocale;
          return true;
        }
      } catch (_) {
        // Fall through to default language.
      }
    }

    if (base == 'ko') {
      final fallbackVoice =
          _findVoiceForLanguage('ko') ?? _findVoiceForLanguage('ko-KR');
      if (fallbackVoice != null) {
        try {
          final result = await _tts.setVoice(fallbackVoice);
          if (_isTtsSuccess(result)) {
            final locale = fallbackVoice['locale'] ?? 'ko-KR';
            try {
              await _tts.setLanguage(locale);
            } catch (_) {}
            _activeLanguage = locale;
            return true;
          }
        } catch (_) {
          // Ignore and fall back to default.
        }
      }
    }

    if (_activeLanguage != _defaultLanguage) {
      try {
        await _tts.setLanguage(_defaultLanguage);
        _activeLanguage = _defaultLanguage;
      } catch (e) {
        print('Error setting fallback TTS language: $e');
      }
    }
    return false;
  }

  Future<void> _loadAvailableTtsLanguages() async {
    try {
      final languages = await _tts.getLanguages;
      if (languages is List) {
        _availableTtsLanguages
          ..clear()
          ..addAll(languages.map((item) => item.toString()));
      }
    } catch (e) {
      print('Error loading TTS languages: $e');
    }
  }

  Future<void> _loadAvailableTtsVoices() async {
    try {
      final voices = await _tts.getVoices;
      _availableTtsVoices.clear();
      if (voices is List) {
        for (final voice in voices) {
          if (voice is Map) {
            final name = voice['name']?.toString();
            final locale = voice['locale']?.toString();
            if (name != null && locale != null) {
              _availableTtsVoices.add({
                'name': name,
                'locale': locale,
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error loading TTS voices: $e');
    }
  }

  Future<void> _setBestTtsEngine() async {
    try {
      final engines = await _tts.getEngines;
      if (engines is! List) return;
      final values = engines.map((item) => item.toString()).toList();
      const preferred = 'com.google.android.tts';
      if (values.contains(preferred)) {
        await _tts.setEngine(preferred);
      }
    } catch (e) {
      print('Error selecting TTS engine: $e');
    }
  }

  List<String> _buildLanguageCandidates(String languageCode) {
    final normalized = _normalizeLanguageCode(languageCode);
    final list = <String>[
      ..._expandLocaleVariants(languageCode),
    ];

    final fallbacks = _languageFallbacks[normalized];
    if (fallbacks != null) {
      for (final fallback in fallbacks) {
        list.addAll(_expandLocaleVariants(fallback));
      }
    }

    final availableMatches = _availableTtsLanguages.where((lang) {
      final normalizedAvailable = _normalizeLanguageCode(lang);
      final base = normalized.split('-').first;
      return normalizedAvailable == normalized ||
          normalizedAvailable == base ||
          normalizedAvailable.startsWith('$base-');
    });
    list.addAll(availableMatches);

    final deduped = <String>[];
    final seen = <String>{};
    for (final item in list) {
      if (item.isEmpty) continue;
      if (seen.add(item)) {
        deduped.add(item);
      }
    }
    return deduped;
  }

  List<String> _expandLocaleVariants(String code) {
    final normalized = _normalizeLanguageCode(code);
    final parts = normalized.split('-');
    final base = parts.first;
    final list = <String>[
      code,
      normalized,
      normalized.replaceAll('-', '_'),
      base,
    ];
    if (parts.length >= 2) {
      final region = parts[1].toUpperCase();
      list.add('$base-$region');
      list.add('${base}_$region');
    }
    return list;
  }

  Map<String, String>? _findVoiceForLanguage(String languageCode) {
    final normalized = _normalizeLanguageCode(languageCode);
    final base = normalized.split('-').first;

    for (final voice in _availableTtsVoices) {
      final locale = voice['locale'];
      if (locale == null) continue;
      if (_normalizeLanguageCode(locale) == normalized) {
        return voice;
      }
    }

    for (final voice in _availableTtsVoices) {
      final locale = voice['locale'];
      if (locale == null) continue;
      final normalizedLocale = _normalizeLanguageCode(locale);
      if (normalizedLocale == base || normalizedLocale.startsWith('$base-')) {
        return voice;
      }
    }
    return null;
  }

  bool _isTtsSuccess(dynamic result) {
    if (result is bool) return result;
    if (result is int) return result == 1;
    if (result is String)
      return result == '1' || result.toLowerCase() == 'true';
    return false;
  }

  String _normalizeLanguageCode(String code) {
    return code.toLowerCase().replaceAll('_', '-');
  }

  bool _isKoreanLanguage(String languageCode) {
    return _normalizeLanguageCode(languageCode).startsWith('ko');
  }

  String _countToKorean(int count) {
    if (count <= 0) return count.toString();
    if (count > 100) return count.toString();
    const ones = [
      '',
      '일',
      '이',
      '삼',
      '사',
      '오',
      '육',
      '칠',
      '팔',
      '구',
    ];
    if (count < 10) {
      return ones[count];
    }
    if (count == 10) return '십';
    if (count < 20) {
      return '십${ones[count - 10]}';
    }
    if (count < 100) {
      final tens = count ~/ 10;
      final onesDigit = count % 10;
      final tensPart = tens == 1 ? '십' : '${ones[tens]}십';
      return onesDigit == 0 ? tensPart : '$tensPart${ones[onesDigit]}';
    }
    if (count == 100) return '백';
    return count.toString();
  }

  Future<void> dispose() async {
    // VoiceCoach is a singleton and is re-used across screens.
    // Only stop playback here; disposing would break subsequent sessions.
    await _countingPlayer.stop();
    await _tts.stop();
  }
}


