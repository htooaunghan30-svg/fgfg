import 'dart:io';

import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class RecordedVideoInfo {
  final File file;
  final DateTime modifiedAt;
  final int sizeBytes;

  RecordedVideoInfo({
    required this.file,
    required this.modifiedAt,
    required this.sizeBytes,
  });
}

class VideoRecordingStorage {
  static const String _recordingsFolderName = 'HF_Recordings';

  static Future<Directory> getRecordingsDirectory() async {
    if (Platform.isAndroid) {
      final publicMoviesFolder = Directory(
        '/storage/emulated/0/Movies/$_recordingsFolderName',
      );
      if (await _canUseDirectory(publicMoviesFolder)) {
        return publicMoviesFolder;
      }
    }

    final localFolder = await _getLocalRecordingsDirectory();
    return localFolder;
  }

  static Future<Directory> _getLocalRecordingsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final localFolder = Directory('${appDir.path}/$_recordingsFolderName');
    if (!await localFolder.exists()) {
      await localFolder.create(recursive: true);
    }
    return localFolder;
  }

  static Future<bool> _canUseDirectory(Directory directory) async {
    try {
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final probeFile = File('${directory.path}/.hf_write_test');
      await probeFile.writeAsString('ok', flush: true);
      if (await probeFile.exists()) {
        await probeFile.delete();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<String> saveVideoFile(
    XFile videoFile, {
    String? exerciseId,
  }) async {
    final sourcePath = videoFile.path;
    final sourceFile = File(sourcePath);
    final sourceStat = await sourceFile.stat();
    final sourceBaseName = sourcePath.split(Platform.pathSeparator).last;
    final safeSourceName =
        sourceBaseName.replaceAll(RegExp(r'[^a-zA-Z0-9_]+'), '_');
    final safeId = (exerciseId ?? '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]+'), '_')
        .trim();
    final signature =
        '${sourceStat.modified.millisecondsSinceEpoch}_${sourceStat.size}_$safeSourceName';
    final fileName = safeId.isEmpty
        ? 'workout_$signature.mp4'
        : 'workout_${safeId}_$signature.mp4';

    return _saveVideoFileToAvailableDirectory(
      videoFile: videoFile,
      sourcePath: sourcePath,
      fileName: fileName,
    );
  }

  static Future<String> saveExistingVideoPath(
    String sourcePath, {
    String? exerciseId,
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException('Source video does not exist', sourcePath);
    }

    final sourceStat = await sourceFile.stat();
    final sourceBaseName = sourcePath.split(Platform.pathSeparator).last;
    final safeSourceName =
        sourceBaseName.replaceAll(RegExp(r'[^a-zA-Z0-9_]+'), '_');
    final safeId = (exerciseId ?? '')
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]+'), '_')
        .trim();
    final signature =
        '${sourceStat.modified.millisecondsSinceEpoch}_${sourceStat.size}_$safeSourceName';
    final fileName = safeId.isEmpty
        ? 'workout_$signature.mp4'
        : 'workout_${safeId}_$signature.mp4';

    return _copyExistingVideoToAvailableDirectory(
      sourceFile: sourceFile,
      sourcePath: sourcePath,
      fileName: fileName,
    );
  }

  static Future<String> _saveVideoFileToAvailableDirectory({
    required XFile videoFile,
    required String sourcePath,
    required String fileName,
  }) async {
    final directories = await _candidateDirectories();

    for (final directory in directories) {
      final newPath = '${directory.path}/$fileName';
      final normalizedSourcePath = sourcePath.replaceAll('\\', '/');
      final normalizedDestPath = newPath.replaceAll('\\', '/');

      if (normalizedSourcePath == normalizedDestPath) {
        await _saveToGalleryAlbum(newPath);
        return newPath;
      }

      final destinationFile = File(newPath);
      if (await destinationFile.exists()) {
        return newPath;
      }

      try {
        await videoFile.saveTo(newPath);
        await _saveToGalleryAlbum(newPath);
        return newPath;
      } on FileSystemException {
        continue;
      }
    }

    throw FileSystemException(
      'Unable to save video to any accessible recordings directory',
      sourcePath,
    );
  }

  static Future<String> _copyExistingVideoToAvailableDirectory({
    required File sourceFile,
    required String sourcePath,
    required String fileName,
  }) async {
    final directories = await _candidateDirectories();

    for (final directory in directories) {
      final destinationPath = '${directory.path}/$fileName';
      final normalizedSourcePath = sourcePath.replaceAll('\\', '/');
      final normalizedDestPath = destinationPath.replaceAll('\\', '/');

      if (normalizedSourcePath == normalizedDestPath) {
        await _saveToGalleryAlbum(destinationPath);
        return destinationPath;
      }

      final destinationFile = File(destinationPath);
      try {
        if (!await destinationFile.exists()) {
          await sourceFile.copy(destinationPath);
        }
        await _saveToGalleryAlbum(destinationPath);
        return destinationPath;
      } on FileSystemException {
        continue;
      }
    }

    throw FileSystemException(
      'Unable to copy video to any accessible recordings directory',
      sourcePath,
    );
  }

  static Future<List<Directory>> _candidateDirectories() async {
    final directories = <Directory>[];

    if (Platform.isAndroid) {
      final publicMoviesFolder = Directory(
        '/storage/emulated/0/Movies/$_recordingsFolderName',
      );
      if (await _canUseDirectory(publicMoviesFolder)) {
        directories.add(publicMoviesFolder);
      }
    }

    directories.add(await _getLocalRecordingsDirectory());
    return directories;
  }

  static Future<void> _saveToGalleryAlbum(String videoPath) async {
    if (!Platform.isIOS && !Platform.isAndroid) return;
    try {
      await GallerySaver.saveVideo(
        videoPath,
        albumName: _recordingsFolderName,
      );
    } catch (_) {}
  }

  static Future<List<RecordedVideoInfo>> listRecordings() async {
    final directories = await _candidateDirectories();
    final files = <RecordedVideoInfo>[];
    final seenPaths = <String>{};

    for (final directory in directories) {
      if (!await directory.exists()) {
        continue;
      }

      final entities = await directory.list().toList();
      for (final entity in entities) {
        if (entity is! File) continue;
        if (!entity.path.toLowerCase().endsWith('.mp4')) continue;
        final fileName = entity.path.split(Platform.pathSeparator).last;
        if (!fileName.toLowerCase().startsWith('workout_')) continue;

        final normalizedPath = entity.path.replaceAll('\\', '/').toLowerCase();
        if (!seenPaths.add(normalizedPath)) {
          continue;
        }

        final stat = await entity.stat();
        files.add(
          RecordedVideoInfo(
            file: entity,
            modifiedAt: stat.modified,
            sizeBytes: stat.size,
          ),
        );
      }
    }

    files.sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
    return files;
  }

  static Future<bool> deleteRecording(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (_) {}
    return false;
  }
}
