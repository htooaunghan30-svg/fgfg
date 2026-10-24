import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

enum ProfilePhotoSaveStatus {
  success,
  tooLarge,
  invalid,
  ioError,
}

class ProfilePhotoSaveResult {
  final ProfilePhotoSaveStatus status;
  final String? path;

  const ProfilePhotoSaveResult._(this.status, this.path);

  const ProfilePhotoSaveResult.success(String path)
      : status = ProfilePhotoSaveStatus.success,
        path = path;

  const ProfilePhotoSaveResult.failure(ProfilePhotoSaveStatus status)
      : status = status,
        path = null;

  bool get isSuccess => status == ProfilePhotoSaveStatus.success && path != null;
}

class ProfilePhotoStorage {
  static const String _folderName = 'HF_Profile';
  static const int _maxBytes = 12 * 1024 * 1024;
  static final Random _rng = Random.secure();

  static Future<Directory> _getDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${appDir.path}/$_folderName');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<ProfilePhotoSaveResult> saveProfilePhoto(
    XFile source, {
    String? previousPath,
  }) async {
    final sourceFile = File(source.path);
    try {
      if (!await sourceFile.exists()) {
        return const ProfilePhotoSaveResult.failure(
          ProfilePhotoSaveStatus.invalid,
        );
      }
      final stat = await sourceFile.stat();
      if (stat.size <= 0) {
        return const ProfilePhotoSaveResult.failure(
          ProfilePhotoSaveStatus.invalid,
        );
      }
      if (stat.size > _maxBytes) {
        return const ProfilePhotoSaveResult.failure(
          ProfilePhotoSaveStatus.tooLarge,
        );
      }
    } catch (_) {
      return const ProfilePhotoSaveResult.failure(
        ProfilePhotoSaveStatus.ioError,
      );
    }

    final dir = await _getDirectory();
    final ext = _safeExtension(source.path);
    final fileName =
        'profile_${DateTime.now().millisecondsSinceEpoch}_${_token(6)}.$ext';
    final newPath = '${dir.path}/$fileName';

    try {
      await sourceFile.copy(newPath);
    } catch (_) {
      return const ProfilePhotoSaveResult.failure(
        ProfilePhotoSaveStatus.ioError,
      );
    }

    await _deleteIfSafe(previousPath);

    return ProfilePhotoSaveResult.success(newPath);
  }

  static Future<void> deleteProfilePhoto(String? path) async {
    await _deleteIfSafe(path);
  }

  static Future<String?> validateStoredPath(String? path) async {
    if (path == null || path.trim().isEmpty) {
      return null;
    }
    final dir = await _getDirectory();
    final normalizedDir = _normalizeDir(dir.path);
    final normalizedPath = _normalize(path);
    if (!normalizedPath.startsWith(normalizedDir)) {
      return null;
    }
    final file = File(path);
    try {
      if (!await file.exists()) {
        return null;
      }
    } catch (_) {
      return null;
    }
    return path;
  }

  static Future<void> _deleteIfSafe(String? path) async {
    if (path == null || path.trim().isEmpty) {
      return;
    }
    final dir = await _getDirectory();
    final normalizedDir = _normalizeDir(dir.path);
    final normalizedPath = _normalize(path);
    if (!normalizedPath.startsWith(normalizedDir)) {
      return;
    }
    final file = File(path);
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  static String _safeExtension(String path) {
    final fileName = path.split(Platform.pathSeparator).last;
    final parts = fileName.split('.');
    final ext = parts.length > 1 ? parts.last : 'jpg';
    final safe = ext.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    if (safe.isEmpty || safe.length > 5) {
      return 'jpg';
    }
    return safe.toLowerCase();
  }

  static String _token(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(chars[_rng.nextInt(chars.length)]);
    }
    return buffer.toString();
  }

  static String _normalize(String path) {
    return path.replaceAll('\\', '/');
  }

  static String _normalizeDir(String path) {
    var normalized = _normalize(path);
    normalized = normalized.replaceAll(RegExp(r'/+$'), '');
    return '$normalized/';
  }
}
