import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/errors/failure.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/profile/data/sources/profile_remote_data_source.dart';
import 'package:reelio/features/profile/domain/entities/profile_user.dart';
import 'package:reelio/features/profile/domain/repositories/profile_repository.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  FutureEither<ProfileUser> getCurrentProfile() async {
    try {
      final profile = await _remoteDataSource.getCurrentProfile();
      return right(profile);
    } on FirebaseAuthException catch (error) {
      return left(AuthFailure(_mapAuthError(error)));
    } on FirebaseException catch (error) {
      return left(FirestoreFailure(error.message ?? 'Failed to load profile.'));
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  @override
  FutureEither<ProfileUser> updateProfile({
    required String displayName,
    required String bio,
  }) async {
    try {
      final profile = await _remoteDataSource.updateProfile(
        displayName: displayName,
        bio: bio,
      );
      return right(profile);
    } on FirebaseAuthException catch (error) {
      return left(AuthFailure(_mapAuthError(error)));
    } on FirebaseException catch (error) {
      return left(
        FirestoreFailure(error.message ?? 'Failed to update profile.'),
      );
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  @override
  FutureEitherVoid changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return right(unit);
    } on FirebaseAuthException catch (error) {
      return left(AuthFailure(_mapAuthError(error)));
    } on Exception catch (error) {
      return left(ServerFailure(error.toString()));
    }
  }

  String _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Your current password is incorrect.';
      case 'weak-password':
        return 'Use a stronger password with at least 8 characters.';
      case 'requires-recent-login':
        return 'Please sign in again before changing your password.';
      case 'operation-not-allowed':
        return error.message ??
            'Password changes are only available for email/password accounts.';
      case 'user-not-found':
        return 'No active user session found. Please sign in again.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
}
