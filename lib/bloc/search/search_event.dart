part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class SearchTypeChanged extends SearchEvent {
  const SearchTypeChanged(this.type);

  final SearchType type;

  @override
  List<Object?> get props => [type];
}

final class SearchRetried extends SearchEvent {
  const SearchRetried();
}

final class SearchCleared extends SearchEvent {
  const SearchCleared();
}
