import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/comments/data/models/comment_model.dart';
import 'package:reelio/features/comments/data/models/comments_page_model.dart';

abstract class CommentRemoteDataSource {
  Future<CommentsPageModel> fetchCommentsPage({
    required String reelId,
    String? lastCommentId,
    int limit = 10,
  });

  Future<CommentModel> postComment({
    required String reelId,
    required String text,
  });
}

@LazySingleton(as: CommentRemoteDataSource)
class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  CommentRemoteDataSourceImpl(this._firestore, this._firebaseAuth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CollectionReference<Map<String, dynamic>> get _reelsCollection =>
      _firestore.collection('reels');

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  Future<CommentsPageModel> fetchCommentsPage({
    required String reelId,
    String? lastCommentId,
    int limit = 10,
  }) async {
    var query = _reelsCollection
        .doc(reelId)
        .collection('comments')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastCommentId != null && lastCommentId.trim().isNotEmpty) {
      final lastDoc = await _reelsCollection
          .doc(reelId)
          .collection('comments')
          .doc(lastCommentId)
          .get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final snapshot = await query.get();
    final comments = snapshot.docs
        .map(CommentModel.fromFirestore)
        .where((comment) => comment.text.isNotEmpty)
        .toList(growable: false);

    final lastVisibleId = snapshot.docs.isNotEmpty
        ? snapshot.docs.last.id
        : null;

    return CommentsPageModel(
      comments: comments,
      hasMore: snapshot.docs.length == limit,
      lastCommentId: lastVisibleId,
    );
  }

  @override
  Future<CommentModel> postComment({
    required String reelId,
    required String text,
  }) async {
    final user = _requireUser();
    final trimmedText = text.trim();
    final userProfileDoc = await _usersCollection.doc(user.uid).get();
    final userProfile = userProfileDoc.data() ?? <String, dynamic>{};

    final username = (userProfile['username'] as String? ?? '').trim();
    final normalizedUsername = username.isEmpty ? 'reelio_user' : username;
    final avatarUrl = (userProfile['photoUrl'] as String?) ?? user.photoURL;

    final reelRef = _reelsCollection.doc(reelId);
    final commentRef = reelRef.collection('comments').doc();

    final batch = _firestore.batch();
    batch
      ..set(commentRef, {
        'id': commentRef.id,
        'userId': user.uid,
        'username': normalizedUsername,
        'userAvatarUrl': avatarUrl,
        'text': trimmedText,
        'createdAt': FieldValue.serverTimestamp(),
      })
      ..set(reelRef, {
        'commentsCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

    await batch.commit();

    final created = await commentRef.get();
    return CommentModel.fromFirestore(created);
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
