import 'package:fpdart/fpdart.dart';
import 'package:reelio/core/errors/failure.dart';

/// Shorthand for an async operation that returns `Either<Failure, T>`.
typedef FutureEither<T> = Future<Either<Failure, T>>;

/// Shorthand for an async operation that returns `Either<Failure, Unit>`.
typedef FutureEitherVoid = FutureEither<Unit>;
