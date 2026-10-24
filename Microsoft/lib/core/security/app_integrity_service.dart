import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'polymorphic_validator.dart';
import 'security_build_config.dart';

class IntegrityVerdict {
  final bool ok;
  final String message;
  final String packageName;
  final String runtimeSignature;
  final bool debuggable;
  final bool debuggerConnected;
  final bool emulator;
  final bool rooted;
  final bool virtualSpace;
  final bool hookDetected;
  final String platform;

  const IntegrityVerdict({
    required this.ok,
    required this.message,
    required this.packageName,
    required this.runtimeSignature,
    required this.debuggable,
    this.debuggerConnected = false,
    this.emulator = false,
    this.rooted = false,
    this.virtualSpace = false,
    this.hookDetected = false,
    required this.platform,
  });
}

class AppIntegrityService {
  const AppIntegrityService._();

  static const AppIntegrityService instance = AppIntegrityService._();

  Future<IntegrityVerdict> verify() async {
    PackageInfo packageInfo;
    try {
      packageInfo = await PackageInfo.fromPlatform();
    } catch (_) {
      return IntegrityVerdict(
        ok: !SecurityBuildConfig.strictMode || kDebugMode,
        message: 'Unable to read package metadata.',
        packageName: '',
        runtimeSignature: '',
        debuggable: false,
        debuggerConnected: false,
        emulator: false,
        rooted: false,
        virtualSpace: false,
        hookDetected: false,
        platform: Platform.operatingSystem,
      );
    }
    final packageName = packageInfo.packageName.trim();
    final expectedPackage = SecurityBuildConfig.expectedPackageId;

    String signatureSha256 = '';
    bool debuggable = false;
    bool debuggerConnected = false;
    String installer = '';
    bool emulator = false;
    bool rooted = false;
    bool virtualSpace = false;
    bool hookDetected = false;

    if (Platform.isAndroid || Platform.isIOS) {
      try {
        final channel = MethodChannel(SecurityBuildConfig.methodChannelName);
        final result = await channel.invokeMapMethod<String, dynamic>(
          'runtimeInfo',
        );
        signatureSha256 =
            (result?['signatureSha256'] as String? ?? '').toUpperCase().trim();
        debuggable = (result?['debuggable'] as bool?) ?? false;
        debuggerConnected = (result?['debuggerConnected'] as bool?) ?? false;
        installer = (result?['installer'] as String? ?? '').trim();
        emulator = (result?['emulator'] as bool?) ?? false;
        rooted = (result?['rooted'] as bool?) ?? false;
        virtualSpace = (result?['virtualSpace'] as bool?) ?? false;
        hookDetected = (result?['hookDetected'] as bool?) ?? false;
      } on PlatformException {
        // Keep defaults; strict mode will reject in release.
      }
    }

    if (SecurityBuildConfig.strictMode && !kDebugMode && Platform.isAndroid) {
      if (packageName != expectedPackage) {
        return IntegrityVerdict(
          ok: false,
          message: 'Package check failed.',
          packageName: packageName,
          runtimeSignature: '',
          debuggable: debuggable,
          debuggerConnected: debuggerConnected,
          emulator: emulator,
          rooted: rooted,
          virtualSpace: virtualSpace,
          hookDetected: hookDetected,
          platform: Platform.operatingSystem,
        );
      }
    }

    if (SecurityBuildConfig.strictMode && !kDebugMode && debuggable) {
      return IntegrityVerdict(
        ok: false,
        message: 'Debuggable build blocked.',
        packageName: packageName,
        runtimeSignature: '',
        debuggable: debuggable,
        debuggerConnected: debuggerConnected,
        emulator: emulator,
        rooted: rooted,
        virtualSpace: virtualSpace,
        hookDetected: hookDetected,
        platform: Platform.operatingSystem,
      );
    }

    if (SecurityBuildConfig.strictMode && !kDebugMode && debuggerConnected) {
      return IntegrityVerdict(
        ok: false,
        message: 'Debugger blocked.',
        packageName: packageName,
        runtimeSignature: '',
        debuggable: debuggable,
        debuggerConnected: debuggerConnected,
        emulator: emulator,
        rooted: rooted,
        virtualSpace: virtualSpace,
        hookDetected: hookDetected,
        platform: Platform.operatingSystem,
      );
    }

    if (SecurityBuildConfig.strictMode && !kDebugMode && emulator) {
      return IntegrityVerdict(
        ok: false,
        message: 'Emulator environment blocked.',
        packageName: packageName,
        runtimeSignature: '',
        debuggable: debuggable,
        debuggerConnected: debuggerConnected,
        emulator: emulator,
        rooted: rooted,
        virtualSpace: virtualSpace,
        hookDetected: hookDetected,
        platform: Platform.operatingSystem,
      );
    }

    if (SecurityBuildConfig.strictMode && !kDebugMode && rooted) {
      return IntegrityVerdict(
        ok: false,
        message: 'Rooted/jailbroken device blocked.',
        packageName: packageName,
        runtimeSignature: '',
        debuggable: debuggable,
        debuggerConnected: debuggerConnected,
        emulator: emulator,
        rooted: rooted,
        virtualSpace: virtualSpace,
        hookDetected: hookDetected,
        platform: Platform.operatingSystem,
      );
    }

    if (SecurityBuildConfig.strictMode && !kDebugMode && virtualSpace) {
      return IntegrityVerdict(
        ok: false,
        message: 'Virtual space/clone environment blocked.',
        packageName: packageName,
        runtimeSignature: '',
        debuggable: debuggable,
        debuggerConnected: debuggerConnected,
        emulator: emulator,
        rooted: rooted,
        virtualSpace: virtualSpace,
        hookDetected: hookDetected,
        platform: Platform.operatingSystem,
      );
    }

    if (SecurityBuildConfig.strictMode && !kDebugMode && hookDetected) {
      return IntegrityVerdict(
        ok: false,
        message: 'Hooking/tamper environment blocked.',
        packageName: packageName,
        runtimeSignature: '',
        debuggable: debuggable,
        debuggerConnected: debuggerConnected,
        emulator: emulator,
        rooted: rooted,
        virtualSpace: virtualSpace,
        hookDetected: hookDetected,
        platform: Platform.operatingSystem,
      );
    }

    final expectedSignatures = SecurityBuildConfig.allowedAndroidSignatures;
    if (Platform.isAndroid &&
        SecurityBuildConfig.strictMode &&
        !kDebugMode &&
        expectedSignatures.isEmpty) {
      return IntegrityVerdict(
        ok: false,
        message: 'Missing APP_SIGNATURE_SHA256 configuration.',
        packageName: packageName,
        runtimeSignature: '',
        debuggable: debuggable,
        debuggerConnected: debuggerConnected,
        emulator: emulator,
        rooted: rooted,
        virtualSpace: virtualSpace,
        hookDetected: hookDetected,
        platform: Platform.operatingSystem,
      );
    }

    if (Platform.isAndroid &&
        SecurityBuildConfig.strictMode &&
        !kDebugMode &&
        expectedSignatures.isNotEmpty &&
        signatureSha256.isEmpty) {
      return IntegrityVerdict(
        ok: false,
        message: 'Unable to read app signature.',
        packageName: packageName,
        runtimeSignature: '',
        debuggable: debuggable,
        debuggerConnected: debuggerConnected,
        emulator: emulator,
        rooted: rooted,
        virtualSpace: virtualSpace,
        hookDetected: hookDetected,
        platform: Platform.operatingSystem,
      );
    }

    if (Platform.isAndroid &&
        signatureSha256.isNotEmpty &&
        expectedSignatures.isNotEmpty &&
        !expectedSignatures.contains(signatureSha256)) {
      return IntegrityVerdict(
        ok: false,
        message: 'App signature mismatch.',
        packageName: packageName,
        runtimeSignature: '',
        debuggable: debuggable,
        debuggerConnected: debuggerConnected,
        emulator: emulator,
        rooted: rooted,
        virtualSpace: virtualSpace,
        hookDetected: hookDetected,
        platform: Platform.operatingSystem,
      );
    }

    final runtimeSeed =
        '$packageName|${Platform.operatingSystem}|$signatureSha256|$installer';
    final gamma = PolymorphicValidator.shardGamma(runtimeSeed).toString();
    final runtimeSignature = '$runtimeSeed|$gamma';

    return IntegrityVerdict(
      ok: true,
      message: 'ok',
      packageName: packageName,
      runtimeSignature: runtimeSignature,
      debuggable: debuggable,
      debuggerConnected: debuggerConnected,
      emulator: emulator,
      rooted: rooted,
      virtualSpace: virtualSpace,
      hookDetected: hookDetected,
      platform: Platform.operatingSystem,
    );
  }
}
