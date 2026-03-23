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
import 'package:supabase_flutter/supabase_flutter.dart';

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
    var mediaUploaded = false;

    try {
      final thumbnailFile = await _thumbnailService.generateThumbnail(
        videoFile: payload.videoFile,
      );
      final thumbnail = await _remoteDataSource.uploadThumbnail(
        reelId: reelId,
        userId: payload.userId,
        thumbnailFile: thumbnailFile,
      );

      final video = await _remoteDataSource.uploadVideo(
        reelId: reelId,
        userId: payload.userId,
        videoFile: payload.videoFile,
        onProgress: onProgress,
      );
      mediaUploaded = true;

      await _remoteDataSource.createReelDocument(
        reelId: reelId,
        payload: payload,
        videoUrl: video.url,
        thumbnailUrl: thumbnail.url,
      );

      return right(unit);
    } on StorageException catch (error) {
      final message = error.message;
      if (message.contains('Upload canceled by user')) {
        return left(const StorageFailure('Upload canceled by user.'));
      }
      return left(StorageFailure(message));
    } on FirebaseException catch (error) {
      if (mediaUploaded) {
        final cleanup = await _cleanupUploadedMedia(
          userId: payload.userId,
          reelId: reelId,
        );
        if (cleanup != null) {
          return left(cleanup);
        }
      }

      return left(
        FirestoreFailure(error.message ?? 'Unable to publish this reel.'),
      );
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  Future<Failure?> _cleanupUploadedMedia({
    required String userId,
    required String reelId,
  }) async {
    try {
      await _remoteDataSource.deleteUploadedMedia(
        reelId: reelId,
        userId: userId,
      );
      return null;
    } on Exception catch (error) {
      return ConsistencyFailure(
        'Firestore write failed and media rollback failed for $reelId. '
        'Cleanup required. Details: $error',
      );
    }
  }

  @override
  FutureEither<String> uploadThumbnail({
    required String reelId,
    required String userId,
    required File thumbnailFile,
  }) async {
    try {
      final uploaded = await _remoteDataSource.uploadThumbnail(
        reelId: reelId,
        userId: userId,
        thumbnailFile: thumbnailFile,
      );
      return right(uploaded.url);
    } on FirebaseException catch (error) {
      return left(
        StorageFailure(error.message ?? 'Unable to upload thumbnail.'),
      );
    } on StorageException catch (error) {
      return left(StorageFailure(error.message));
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
