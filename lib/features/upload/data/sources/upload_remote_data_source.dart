import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/upload/domain/entities/upload_reel_payload.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadedMediaObject {
  const UploadedMediaObject({required this.path, required this.url});

  final String path;
  final String url;
}

abstract class UploadRemoteDataSource {
  Future<UploadedMediaObject> uploadVideo({
    required String reelId,
    required String userId,
    required File videoFile,
    void Function(double progress)? onProgress,
  });

  Future<UploadedMediaObject> uploadThumbnail({
    required String reelId,
    required String userId,
    required File thumbnailFile,
  });

  Future<void> deleteUploadedMedia({
    required String reelId,
    required String userId,
  });

  Future<void> createReelDocument({
    required String reelId,
    required UploadReelPayload payload,
    required String videoUrl,
    required String thumbnailUrl,
  });

  Future<void> cancelActiveUpload();
}

@LazySingleton(as: UploadRemoteDataSource)
class UploadRemoteDataSourceImpl implements UploadRemoteDataSource {
  UploadRemoteDataSourceImpl(this._supabaseClient, this._firestore);

  final SupabaseClient _supabaseClient;
  final FirebaseFirestore _firestore;

  static const String _reelsBucket = 'reels';
  static const String _thumbnailsBucket = 'thumbnails';
  bool _cancelRequested = false;

  CollectionReference<Map<String, dynamic>> get _reelsCollection =>
      _firestore.collection('reels');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<UploadedMediaObject> uploadVideo({
    required String reelId,
    required String userId,
    required File videoFile,
    void Function(double progress)? onProgress,
  }) async {
    _throwIfCanceled();
    final path = _videoPath(userId: userId, reelId: reelId);
    onProgress?.call(0.1);

    await _supabaseClient.storage
        .from(_reelsBucket)
        .upload(
          path,
          videoFile,
          fileOptions: const FileOptions(
            contentType: 'video/mp4',
            upsert: true,
          ),
        );

    _throwIfCanceled();
    onProgress?.call(0.95);

    final url = _supabaseClient.storage.from(_reelsBucket).getPublicUrl(path);
    if (url.trim().isEmpty) {
      throw const StorageException('Unable to resolve uploaded video URL.');
    }

    onProgress?.call(1);
    return UploadedMediaObject(path: path, url: url);
  }

  @override
  Future<UploadedMediaObject> uploadThumbnail({
    required String reelId,
    required String userId,
    required File thumbnailFile,
  }) async {
    _throwIfCanceled();
    final path = _thumbnailPath(userId: userId, reelId: reelId);

    await _supabaseClient.storage
        .from(_thumbnailsBucket)
        .upload(
          path,
          thumbnailFile,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    _throwIfCanceled();
    final url = _supabaseClient.storage
        .from(_thumbnailsBucket)
        .getPublicUrl(path);

    if (url.trim().isEmpty) {
      throw const StorageException('Unable to resolve uploaded thumbnail URL.');
    }

    return UploadedMediaObject(path: path, url: url);
  }

  @override
  Future<void> deleteUploadedMedia({
    required String reelId,
    required String userId,
  }) async {
    final videoPath = _videoPath(userId: userId, reelId: reelId);
    final thumbnailPath = _thumbnailPath(userId: userId, reelId: reelId);

    await _supabaseClient.storage.from(_reelsBucket).remove([videoPath]);
    await _supabaseClient.storage.from(_thumbnailsBucket).remove([
      thumbnailPath,
    ]);
  }

  @override
  Future<void> createReelDocument({
    required String reelId,
    required UploadReelPayload payload,
    required String videoUrl,
    required String thumbnailUrl,
  }) async {
    final reelRef = _reelsCollection.doc(reelId);
    final userRef = _usersCollection.doc(payload.userId);

    final batch = _firestore.batch();

    final username = payload.username.trim();
    final normalizedUsername = username.isEmpty ? 'reelio_user' : username;

    final caption = payload.caption.trim();

    batch
      ..set(reelRef, {
        'id': reelId,
        'userId': payload.userId,
        'username': normalizedUsername,
        'userAvatarUrl': payload.userAvatarUrl,
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'caption': caption,
        'likesCount': 0,
        'commentsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..set(userRef, {
        'reelsCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    await batch.commit();
  }

  @override
  Future<void> cancelActiveUpload() async {
    _cancelRequested = true;
  }

  String _videoPath({required String userId, required String reelId}) {
    return '$userId/$reelId.mp4';
  }

  String _thumbnailPath({required String userId, required String reelId}) {
    return '$userId/$reelId.jpg';
  }

  void _throwIfCanceled() {
    if (_cancelRequested) {
      _cancelRequested = false;
      throw const StorageException('Upload canceled by user.');
    }
  }
}
