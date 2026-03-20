import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/errors/failure.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/search/data/sources/search_remote_data_source.dart';
import 'package:reelio/features/search/domain/entities/search_user.dart';
import 'package:reelio/features/search/domain/repositories/search_repository.dart';

@LazySingleton(as: SearchRepository)
class SearchRepositoryImpl implements SearchRepository {
  SearchRepositoryImpl(this._remoteDataSource);

  final SearchRemoteDataSource _remoteDataSource;

  @override
  FutureEither<List<SearchUser>> searchUsers(String query) async {
    final currentUserId = _remoteDataSource.currentUserId;
    if (currentUserId == null) {
      return left(const AuthFailure('No active user session found.'));
    }

    try {
      final results = await _remoteDataSource.searchUsers(
        query: query,
        currentUserId: currentUserId,
      );
      return right(results);
    } on FirebaseException catch (error) {
      return left(
        FirestoreFailure(error.message ?? 'Unable to load search results.'),
      );
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  @override
  FutureEither<bool> toggleFollow({
    required String targetUserId,
    required bool currentlyFollowing,
  }) async {
    final currentUserId = _remoteDataSource.currentUserId;
    if (currentUserId == null) {
      return left(const AuthFailure('No active user session found.'));
    }

    if (currentUserId == targetUserId) {
      return left(const AuthFailure('You cannot follow yourself.'));
    }

    final shouldFollow = !currentlyFollowing;

    try {
      await _remoteDataSource.toggleFollow(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
        shouldFollow: shouldFollow,
      );
      return right(shouldFollow);
    } on FirebaseAuthException catch (error) {
      return left(
        AuthFailure(
          error.message ?? 'Authentication failed. Please sign in again.',
        ),
      );
    } on FirebaseException catch (error) {
      return left(
        FirestoreFailure(error.message ?? 'Unable to update follow status.'),
      );
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }
}
