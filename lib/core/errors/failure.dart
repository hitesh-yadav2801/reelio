import 'package:equatable/equatable.dart';

/// Base failure class for all domain-level errors.
///
/// Each feature should extend this with specific failure types.
abstract class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Failure from Firebase Firestore operations.
class FirestoreFailure extends Failure {
  const FirestoreFailure(super.message);
}

/// Failure from Firebase Auth operations.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Failure from Firebase Storage operations.
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Failure from local cache operations.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Generic server/network failure.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}
