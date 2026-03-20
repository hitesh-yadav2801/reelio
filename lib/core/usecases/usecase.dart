import 'package:equatable/equatable.dart';

abstract class UseCase<T, Params> {
  T call(Params params);

  String get label => runtimeType.toString();
}

abstract class StreamUseCase<T, Params> {
  Stream<T> call(Params params);

  String get label => runtimeType.toString();
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
