import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/auth/domain/entities/reelio_user.dart';

/// Repository interface for authentication logic.
abstract class AuthRepository {
  /// Stream of authentication state changes.
  Stream<ReelioUser> get user;

  /// Sign up with email and password.
  FutureEitherVoid signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  /// Sign in with email and password.
  FutureEither<ReelioUser> signInWithEmail({
    required String email,
    required String password,
  });

  /// Sign in with Google.
  FutureEither<ReelioUser> signInWithGoogle();

  /// Sign out current user.
  FutureEitherVoid signOut();
}
