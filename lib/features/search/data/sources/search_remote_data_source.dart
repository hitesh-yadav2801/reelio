import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/features/search/data/models/search_user_model.dart';

abstract class SearchRemoteDataSource {
  String? get currentUserId;

  Future<List<SearchUserModel>> searchUsers({
    required String query,
    required String currentUserId,
  });

  Future<void> toggleFollow({
    required String currentUserId,
    required String targetUserId,
    required bool shouldFollow,
  });
}

@LazySingleton(as: SearchRemoteDataSource)
class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  SearchRemoteDataSourceImpl(this._firestore, this._firebaseAuth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  Future<List<SearchUserModel>> searchUsers({
    required String query,
    required String currentUserId,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    final upperBound = '$normalizedQuery\uf8ff';

    final displayNameFuture = _usersCollection
        .where('displayNameLower', isGreaterThanOrEqualTo: normalizedQuery)
        .where('displayNameLower', isLessThanOrEqualTo: upperBound)
        .limit(25)
        .get();

    final displayNameFallbackFuture = _usersCollection
        .where('displayName', isGreaterThanOrEqualTo: query.trim())
        .where('displayName', isLessThanOrEqualTo: '${query.trim()}\uf8ff')
        .limit(25)
        .get();

    final usernameFuture = _usersCollection
        .where('username', isGreaterThanOrEqualTo: normalizedQuery)
        .where('username', isLessThanOrEqualTo: upperBound)
        .limit(25)
        .get();

    final snapshots = await Future.wait([
      displayNameFuture,
      displayNameFallbackFuture,
      usernameFuture,
    ]);

    final merged = <String, DocumentSnapshot<Map<String, dynamic>>>{};
    for (final snapshot in snapshots) {
      for (final doc in snapshot.docs) {
        if (doc.id == currentUserId) {
          continue;
        }

        final username = (doc.data()['username'] as String? ?? '').trim();
        if (username.isEmpty) {
          continue;
        }

        merged[doc.id] = doc;
      }
    }

    if (merged.isEmpty) {
      return const [];
    }

    final followedIds = await _getFollowedIds(
      currentUserId: currentUserId,
      candidateIds: merged.keys.toList(growable: false),
    );

    return merged.values
        .map((doc) {
          return SearchUserModel.fromFirestore(
            doc,
            isFollowing: followedIds.contains(doc.id),
          );
        })
        .toList(growable: false)
      ..sort((a, b) {
        final usernameCompare = a.username.compareTo(b.username);
        if (usernameCompare != 0) {
          return usernameCompare;
        }
        return a.displayName.compareTo(b.displayName);
      });
  }

  Future<Set<String>> _getFollowedIds({
    required String currentUserId,
    required List<String> candidateIds,
  }) async {
    final followingCollection = _usersCollection
        .doc(currentUserId)
        .collection('following');

    final followedIds = <String>{};
    const chunkSize = 10;

    for (var i = 0; i < candidateIds.length; i += chunkSize) {
      final end = (i + chunkSize) > candidateIds.length
          ? candidateIds.length
          : i + chunkSize;
      final chunk = candidateIds.sublist(i, end);
      if (chunk.isEmpty) {
        continue;
      }

      final followedSnapshot = await followingCollection
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      followedIds.addAll(followedSnapshot.docs.map((doc) => doc.id));
    }

    return followedIds;
  }

  @override
  Future<void> toggleFollow({
    required String currentUserId,
    required String targetUserId,
    required bool shouldFollow,
  }) async {
    final currentUserRef = _usersCollection.doc(currentUserId);
    final targetUserRef = _usersCollection.doc(targetUserId);
    final followingRef = currentUserRef
        .collection('following')
        .doc(targetUserId);
    final followerRef = targetUserRef
        .collection('followers')
        .doc(currentUserId);

    final existing = await followingRef.get();
    if (shouldFollow == existing.exists) {
      return;
    }

    final batch = _firestore.batch();

    if (shouldFollow) {
      batch
        ..set(followingRef, {
          'uid': targetUserId,
          'createdAt': FieldValue.serverTimestamp(),
        })
        ..set(followerRef, {
          'uid': currentUserId,
          'createdAt': FieldValue.serverTimestamp(),
        })
        ..set(currentUserRef, {
          'followingCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        ..set(targetUserRef, {
          'followerCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
    } else {
      batch
        ..delete(followingRef)
        ..delete(followerRef)
        ..set(currentUserRef, {
          'followingCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true))
        ..set(targetUserRef, {
          'followerCount': FieldValue.increment(-1),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
    }

    await batch.commit();
  }
}
