import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/errors/failure.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/likes/data/sources/like_remote_data_source.dart';
import 'package:reelio/features/likes/domain/repositories/like_repository.dart';

@LazySingleton(as: LikeRepository)
class LikeRepositoryImpl implements LikeRepository {
  LikeRepositoryImpl(this._remoteDataSource);

  final LikeRemoteDataSource _remoteDataSource;

  @override
  FutureEither<bool> getLikeStatus({required String reelId}) async {
    try {
      final isLiked = await _remoteDataSource.getLikeStatus(reelId: reelId);
      return right(isLiked);
    } on FirebaseAuthException catch (error) {
      return left(AuthFailure(error.message ?? 'Authentication required.'));
    } on FirebaseException catch (error) {
      return left(
        FirestoreFailure(error.message ?? 'Unable to fetch like status.'),
      );
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  @override
  FutureEither<bool> toggleLike({
    required String reelId,
    required bool currentlyLiked,
  }) async {
    try {
      final isLiked = await _remoteDataSource.toggleLike(
        reelId: reelId,
        currentlyLiked: currentlyLiked,
      );
      return right(isLiked);
    } on FirebaseAuthException catch (error) {
      return left(AuthFailure(error.message ?? 'Authentication required.'));
    } on FirebaseException catch (error) {
      return left(FirestoreFailure(error.message ?? 'Unable to update like.'));
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }
}
