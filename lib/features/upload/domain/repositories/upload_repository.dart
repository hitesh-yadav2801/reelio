import 'dart:io';

import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/upload/domain/entities/upload_reel_payload.dart';

abstract class UploadRepository {
  FutureEitherVoid submitReel(
    UploadReelPayload payload, {
    void Function(double progress)? onProgress,
  });

  FutureEither<String> uploadThumbnail({
    required String reelId,
    required File thumbnailFile,
  });

  FutureEitherVoid createReelDocument({
    required String reelId,
    required UploadReelPayload payload,
    required String videoUrl,
    required String thumbnailUrl,
  });

  FutureEitherVoid cancelActiveUpload();
}
