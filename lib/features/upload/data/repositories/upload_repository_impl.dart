import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/errors/failure.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/upload/data/sources/upload_remote_data_source.dart';
import 'package:reelio/features/upload/domain/entities/upload_reel_payload.dart';
import 'package:reelio/features/upload/domain/repositories/upload_repository.dart';
import 'package:reelio/shared/services/video_thumbnail_service.dart';

@LazySingleton(as: UploadRepository)
class UploadRepositoryImpl implements UploadRepository {
  UploadRepositoryImpl(this._remoteDataSource, this._thumbnailService);

  final UploadRemoteDataSource _remoteDataSource;
  final VideoThumbnailService _thumbnailService;

  @override
  FutureEitherVoid submitReel(
    UploadReelPayload payload, {
    void Function(double progress)? onProgress,
  }) async {
    final reelId = _createReelId(payload.userId);

    try {
      final thumbnailFile = await _thumbnailService.generateThumbnail(
        videoFile: payload.videoFile,
      );
      final thumbnailUrl = await _remoteDataSource.uploadThumbnail(
        reelId: reelId,
        thumbnailFile: thumbnailFile,
      );

      final videoUrl = await _remoteDataSource.uploadVideo(
        reelId: reelId,
        videoFile: payload.videoFile,
        onProgress: onProgress,
      );

      await _remoteDataSource.createReelDocument(
        reelId: reelId,
        payload: payload,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
      );

      return right(unit);
    } on FirebaseException catch (error) {
      if (error.plugin == 'firebase_storage') {
        return left(
          StorageFailure(error.message ?? 'Unable to upload media right now.'),
        );
      }

      return left(
        FirestoreFailure(error.message ?? 'Unable to publish this reel.'),
      );
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  @override
  FutureEither<String> uploadThumbnail({
    required String reelId,
    required File thumbnailFile,
  }) async {
    try {
      final url = await _remoteDataSource.uploadThumbnail(
        reelId: reelId,
        thumbnailFile: thumbnailFile,
      );
      return right(url);
    } on FirebaseException catch (error) {
      return left(
        StorageFailure(error.message ?? 'Unable to upload thumbnail.'),
      );
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  @override
  FutureEitherVoid createReelDocument({
    required String reelId,
    required UploadReelPayload payload,
    required String videoUrl,
    required String thumbnailUrl,
  }) async {
    try {
      await _remoteDataSource.createReelDocument(
        reelId: reelId,
        payload: payload,
        videoUrl: videoUrl,
        thumbnailUrl: thumbnailUrl,
      );
      return right(unit);
    } on FirebaseException catch (error) {
      return left(
        FirestoreFailure(error.message ?? 'Unable to save reel details.'),
      );
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  @override
  FutureEitherVoid cancelActiveUpload() async {
    try {
      await _remoteDataSource.cancelActiveUpload();
      return right(unit);
    } on FirebaseException catch (error) {
      return left(
        StorageFailure(error.message ?? 'Unable to cancel upload right now.'),
      );
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  String _createReelId(String userId) {
    final millis = DateTime.now().millisecondsSinceEpoch;
    return '$userId-$millis';
  }
}
