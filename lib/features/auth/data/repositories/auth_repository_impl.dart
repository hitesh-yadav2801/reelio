import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/errors/failure.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/auth/data/models/user_model.dart';
import 'package:reelio/features/auth/data/sources/remote_auth_data_source.dart';
import 'package:reelio/features/auth/domain/entities/reelio_user.dart';
import 'package:reelio/features/auth/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);
  final RemoteAuthDataSource _remoteDataSource;

  @override
  Stream<ReelioUser> get user =>
      _remoteDataSource.authStateChanges.asyncMap((firebaseUser) async {
        if (firebaseUser == null) return ReelioUser.empty;
        try {
          return await _remoteDataSource.getUserProfile(firebaseUser.uid);
        } on Exception {
          // If no profile exists, return basic info from auth
          return ReelioUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            displayName: firebaseUser.displayName,
            photoUrl: firebaseUser.photoURL,
          );
        }
      });

  @override
  FutureEitherVoid signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await _remoteDataSource.signUpWithEmail(
        email,
        password,
      );
      final userModel = UserModel(
        uid: credential.user!.uid,
        email: email,
        displayName: fullName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _remoteDataSource.createUserProfile(userModel);
      return right(unit);
    } on Exception catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  FutureEither<ReelioUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _remoteDataSource.signInWithEmail(
        email,
        password,
      );
      final user = await _remoteDataSource.getUserProfile(credential.user!.uid);
      return right(user);
    } on Exception catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  FutureEither<ReelioUser> signInWithGoogle() async {
    try {
      final credential = await _remoteDataSource.signInWithGoogle();

      // Try to get existing profile
      try {
        final existingUser = await _remoteDataSource.getUserProfile(
          credential.user!.uid,
        );
        return right(existingUser);
      } on Exception {
        // Create new profile for Google user
        final newUser = UserModel(
          uid: credential.user!.uid,
          email: credential.user!.email ?? '',
          displayName: credential.user!.displayName,
          photoUrl: credential.user!.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _remoteDataSource.createUserProfile(newUser);
        return right(newUser);
      }
    } on Exception catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }

  @override
  FutureEitherVoid signOut() async {
    try {
      await _remoteDataSource.signOut();
      return right(unit);
    } on Exception catch (e) {
      return left(AuthFailure(e.toString()));
    }
  }
}
