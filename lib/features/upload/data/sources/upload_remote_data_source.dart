import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/upload/domain/entities/upload_reel_payload.dart';

abstract class UploadRemoteDataSource {
  Future<String> uploadVideo({
    required String reelId,
    required File videoFile,
    void Function(double progress)? onProgress,
  });

  Future<String> uploadThumbnail({
    required String reelId,
    required File thumbnailFile,
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
  UploadRemoteDataSourceImpl(this._storage, this._firestore);

  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;

  UploadTask? _activeUploadTask;

  CollectionReference<Map<String, dynamic>> get _reelsCollection =>
      _firestore.collection('reels');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<String> uploadVideo({
    required String reelId,
    required File videoFile,
    void Function(double progress)? onProgress,
  }) async {
    final reelRef = _storage.ref().child('reels/$reelId.mp4');
    final uploadTask = reelRef.putFile(videoFile);
    _activeUploadTask = uploadTask;

    await for (final snapshot in uploadTask.snapshotEvents) {
      final total = snapshot.totalBytes;
      final transferred = snapshot.bytesTransferred;
      if (total <= 0) {
        onProgress?.call(0);
        continue;
      }

      final value = (transferred / total).clamp(0, 1).toDouble();
      onProgress?.call(value);
    }

    if (uploadTask.snapshot.state != TaskState.success) {
      throw FirebaseException(
        plugin: 'firebase_storage',
        code: 'upload-failed',
        message: 'Video upload did not complete successfully.',
      );
    }

    onProgress?.call(1);
    _activeUploadTask = null;
    return reelRef.getDownloadURL();
  }

  @override
  Future<String> uploadThumbnail({
    required String reelId,
    required File thumbnailFile,
  }) async {
    final thumbnailRef = _storage.ref().child('thumbnails/$reelId.jpg');
    await thumbnailRef.putFile(thumbnailFile);
    return thumbnailRef.getDownloadURL();
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
    final uploadTask = _activeUploadTask;
    if (uploadTask == null) {
      return;
    }

    await uploadTask.cancel();
    _activeUploadTask = null;
  }
}
