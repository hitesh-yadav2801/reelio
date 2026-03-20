import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/errors/failure.dart';
import 'package:reelio/core/logging/app_logger.dart';
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
          AppLogger.instance.w(
            'Auth user stream profile fallback for uid=${firebaseUser.uid}.',
          );
          return _basicUserFromFirebase(firebaseUser);
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
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return left(
          const AuthFailure('Unable to create your account right now.'),
        );
      }

      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: email,
        displayName: fullName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _remoteDataSource.createUserProfile(userModel);
      return right(unit);
    } on FirebaseAuthException catch (error) {
      _logAuthException('signUpWithEmail', error);
      return left(
        AuthFailure(
          _authMessageForCode(
            error.code,
            fallback: 'Unable to create your account right now.',
          ),
        ),
      );
    } on FirebaseException catch (error) {
      _logFirestoreException('signUpWithEmail', error);
      return left(
        AuthFailure(
          _firestoreMessageForCode(
            error.code,
            fallback: 'Unable to finish account setup. Please try again.',
          ),
        ),
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.instance.e(
        'Unexpected sign up error.',
        error: error,
        stackTrace: stackTrace,
      );
      return left(
        const AuthFailure('Unable to create your account right now.'),
      );
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
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return left(
          const AuthFailure('Unable to sign in right now. Please try again.'),
        );
      }

      final user = await _resolveUserProfile(firebaseUser);
      return right(user);
    } on FirebaseAuthException catch (error) {
      _logAuthException('signInWithEmail', error);
      return left(
        AuthFailure(
          _authMessageForCode(
            error.code,
            fallback: 'Unable to sign in right now. Please try again.',
          ),
        ),
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.instance.e(
        'Unexpected sign in error.',
        error: error,
        stackTrace: stackTrace,
      );
      return left(
        const AuthFailure('Unable to sign in right now. Please try again.'),
      );
    }
  }

  @override
  FutureEither<ReelioUser> signInWithGoogle() async {
    try {
      final credential = await _remoteDataSource.signInWithGoogle();
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        return left(
          const AuthFailure('Unable to continue with Google right now.'),
        );
      }

      // Try to get existing profile
      try {
        final existingUser = await _remoteDataSource.getUserProfile(
          firebaseUser.uid,
        );
        return right(existingUser);
      } on Exception {
        AppLogger.instance.i(
          'Google user profile not found; creating one for '
          'uid=${firebaseUser.uid}.',
        );

        // Create new profile for Google user
        final newUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        try {
          await _remoteDataSource.createUserProfile(newUser);
        } on FirebaseException catch (createError) {
          _logFirestoreException(
            'signInWithGoogle.createUserProfile',
            createError,
          );
          return right(_basicUserFromFirebase(firebaseUser));
        }

        return right(newUser);
      }
    } on FirebaseAuthException catch (error) {
      _logAuthException('signInWithGoogle', error);
      return left(
        AuthFailure(
          _authMessageForCode(
            error.code,
            fallback: 'Unable to continue with Google right now.',
          ),
        ),
      );
    } on Exception catch (error, stackTrace) {
      AppLogger.instance.e(
        'Unexpected Google sign in error.',
        error: error,
        stackTrace: stackTrace,
      );
      return left(
        const AuthFailure('Unable to continue with Google right now.'),
      );
    }
  }

  @override
  FutureEitherVoid signOut() async {
    try {
      await _remoteDataSource.signOut();
      return right(unit);
    } on FirebaseAuthException catch (error) {
      _logAuthException('signOut', error);
      return left(const AuthFailure('Unable to log out right now.'));
    } on Exception catch (error, stackTrace) {
      AppLogger.instance.e(
        'Unexpected sign out error.',
        error: error,
        stackTrace: stackTrace,
      );
      return left(const AuthFailure('Unable to log out right now.'));
    }
  }

  Future<ReelioUser> _resolveUserProfile(User firebaseUser) async {
    try {
      return await _remoteDataSource.getUserProfile(firebaseUser.uid);
    } on Exception {
      AppLogger.instance.w(
        'Falling back to auth profile for uid=${firebaseUser.uid}.',
      );
      return _basicUserFromFirebase(firebaseUser);
    }
  }

  ReelioUser _basicUserFromFirebase(User firebaseUser) {
    return ReelioUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }

  String _authMessageForCode(String code, {required String fallback}) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support for help.';
      case 'user-not-found':
        return 'No account found for this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password. Please try again.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Use a stronger password with at least 8 characters.';
      case 'operation-not-allowed':
        return 'This sign-in method is currently unavailable.';
      case 'too-many-requests':
        return 'Too many attempts detected. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method.';
      case 'credential-already-in-use':
        return 'This sign-in credential is already linked to another account.';
      case 'google-sign-in-cancelled':
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Google sign-in was cancelled.';
      default:
        return fallback;
    }
  }

  String _firestoreMessageForCode(String code, {required String fallback}) {
    switch (code) {
      case 'permission-denied':
        return 'You do not have permission to complete this request.';
      case 'unavailable':
      case 'deadline-exceeded':
        return 'Service is temporarily unavailable. Please try again.';
      default:
        return fallback;
    }
  }

  void _logAuthException(String action, FirebaseAuthException error) {
    AppLogger.instance.w('Auth failure during $action [${error.code}]');
  }

  void _logFirestoreException(String action, FirebaseException error) {
    AppLogger.instance.w('Firestore failure during $action [${error.code}]');
  }
}
