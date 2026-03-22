import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

@lazySingleton
class VideoThumbnailService {
  Future<File> generateThumbnail({required File videoFile}) async {
    final tempDir = await getTemporaryDirectory();
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: videoFile.path,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 720,
      quality: 70,
    );

    if (thumbnailPath == null || thumbnailPath.trim().isEmpty) {
      throw const FileSystemException('Unable to generate thumbnail');
    }

    return File(thumbnailPath);
  }
}
