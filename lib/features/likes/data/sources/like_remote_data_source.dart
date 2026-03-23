import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

abstract class LikeRemoteDataSource {
  Future<bool> getLikeStatus({required String reelId});

  Future<bool> toggleLike({
    required String reelId,
    required bool currentlyLiked,
  });
}

@LazySingleton(as: LikeRemoteDataSource)
class LikeRemoteDataSourceImpl implements LikeRemoteDataSource {
  LikeRemoteDataSourceImpl(this._firestore, this._firebaseAuth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CollectionReference<Map<String, dynamic>> get _reelsCollection =>
      _firestore.collection('reels');

  @override
  Future<bool> getLikeStatus({required String reelId}) async {
    final currentUser = _requireUser();

    final likeDoc = await _reelsCollection
        .doc(reelId)
        .collection('likes')
        .doc(currentUser.uid)
        .get();

    return likeDoc.exists;
  }

  @override
  Future<bool> toggleLike({
    required String reelId,
    required bool currentlyLiked,
  }) async {
    final currentUser = _requireUser();
    final reelRef = _reelsCollection.doc(reelId);
    final likeRef = reelRef.collection('likes').doc(currentUser.uid);

    return _firestore.runTransaction((transaction) async {
      final likeSnapshot = await transaction.get(likeRef);
      final shouldLike = !currentlyLiked;

      if (shouldLike) {
        if (!likeSnapshot.exists) {
          transaction
            ..set(likeRef, {
              'userId': currentUser.uid,
              'likedAt': FieldValue.serverTimestamp(),
            })
            ..set(reelRef, {
              'likesCount': FieldValue.increment(1),
            }, SetOptions(merge: true));
        }

        return true;
      }

      if (likeSnapshot.exists) {
        transaction
          ..delete(likeRef)
          ..set(reelRef, {
            'likesCount': FieldValue.increment(-1),
          }, SetOptions(merge: true));
      }

      return false;
    });
  }

  User _requireUser() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No authenticated user found.',
      );
    }

    return user;
  }
}
