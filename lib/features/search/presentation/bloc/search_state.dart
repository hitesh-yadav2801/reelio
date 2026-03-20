part of 'search_cubit.dart';

enum SearchStatus { initial, loading, loaded, empty, error }

class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.status = SearchStatus.initial,
    this.results = const [],
    this.errorMessage,
    this.actionErrorMessage,
  });

  final String query;
  final SearchStatus status;
  final List<SearchUser> results;
  final String? errorMessage;
  final String? actionErrorMessage;

  bool get showPrompt => status == SearchStatus.initial && query.isEmpty;

  SearchState copyWith({
    String? query,
    SearchStatus? status,
    List<SearchUser>? results,
    String? errorMessage,
    String? actionErrorMessage,
    bool clearError = false,
    bool clearActionError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      status: status ?? this.status,
      results: results ?? this.results,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      actionErrorMessage: clearActionError
          ? null
          : (actionErrorMessage ?? this.actionErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
    query,
    status,
    results,
    errorMessage,
    actionErrorMessage,
  ];
}
