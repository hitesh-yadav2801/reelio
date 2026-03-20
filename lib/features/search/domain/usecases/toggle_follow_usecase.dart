import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/search/domain/repositories/search_repository.dart';

class ToggleFollowParams extends Equatable {
  const ToggleFollowParams({
    required this.targetUserId,
    required this.currentlyFollowing,
  });

  final String targetUserId;
  final bool currentlyFollowing;

  @override
  List<Object?> get props => [targetUserId, currentlyFollowing];
}

@lazySingleton
class ToggleFollowUseCase
    extends UseCase<FutureEither<bool>, ToggleFollowParams> {
  ToggleFollowUseCase(this._searchRepository);

  final SearchRepository _searchRepository;

  @override
  FutureEither<bool> call(ToggleFollowParams params) {
    return _searchRepository.toggleFollow(
      targetUserId: params.targetUserId,
      currentlyFollowing: params.currentlyFollowing,
    );
  }
}
