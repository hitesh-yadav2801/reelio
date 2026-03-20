import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:reelio/core/usecases/usecase.dart';
import 'package:reelio/core/utils/typedefs.dart';
import 'package:reelio/features/search/domain/entities/search_user.dart';
import 'package:reelio/features/search/domain/repositories/search_repository.dart';

class SearchUsersParams extends Equatable {
  const SearchUsersParams({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

@lazySingleton
class SearchUsersUseCase
    extends UseCase<FutureEither<List<SearchUser>>, SearchUsersParams> {
  SearchUsersUseCase(this._searchRepository);

  final SearchRepository _searchRepository;

  @override
  FutureEither<List<SearchUser>> call(SearchUsersParams params) {
    return _searchRepository.searchUsers(params.query);
  }
}
