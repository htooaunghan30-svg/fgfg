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
      final moviesFolder = Directory(
        '/storage/emulated/0/Movies/$_recordingsFolderName',
      );
      if (!await moviesFolder.exists()) {
        await moviesFolder.create(recursive: true);
      }
      return moviesFolder;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final localFolder = Directory('${appDir.path}/$_recordingsFolderName');
    if (!await localFolder.exists()) {
      await localFolder.create(recursive: true);
    }
    return localFolder;
  }

  static Future<String> saveVideoFile(
    XFile videoFile, {
    String? exerciseId,
  }) async {
    final directory = await getRecordingsDirectory();
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
    final newPath = '${directory.path}/$fileName';
    final normalizedSourcePath = sourcePath.replaceAll('\\', '/');
    final normalizedDestPath = newPath.replaceAll('\\', '/');

    if (normalizedSourcePath == normalizedDestPath) {
      return newPath;
    }

    final destinationFile = File(newPath);
    if (await destinationFile.exists()) {
      return newPath;
    }

    await videoFile.saveTo(newPath);
    await _saveToIosGalleryAlbum(newPath);
    return newPath;
  }

  static Future<void> _saveToIosGalleryAlbum(String videoPath) async {
    if (!Platform.isIOS) return;
    try {
      await GallerySaver.saveVideo(
        videoPath,
        albumName: _recordingsFolderName,
      );
    } catch (_) {}
  }

  static Future<List<RecordedVideoInfo>> listRecordings() async {
    final directory = await getRecordingsDirectory();
    if (!await directory.exists()) {
      return [];
    }

    final entities = await directory.list().toList();
    final files = <RecordedVideoInfo>[];

    for (final entity in entities) {
      if (entity is! File) continue;
      if (!entity.path.toLowerCase().endsWith('.mp4')) continue;
      final fileName = entity.path.split(Platform.pathSeparator).last;
      if (!fileName.toLowerCase().startsWith('workout_')) continue;
      final stat = await entity.stat();
      files.add(
        RecordedVideoInfo(
          file: entity,
          modifiedAt: stat.modified,
          sizeBytes: stat.size,
        ),
      );
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
