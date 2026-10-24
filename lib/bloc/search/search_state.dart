part of 'search_bloc.dart';

enum SearchType { shows, people }

enum SearchStatus { initial, loading, success, empty, failure }

class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.type = SearchType.shows,
    this.status = SearchStatus.initial,
    this.shows = const [],
    this.people = const [],
    this.errorMessage,
  });

  final String query;
  final SearchType type;
  final SearchStatus status;
  final List<Show> shows;
  final List<Person> people;
  final String? errorMessage;

  SearchState copyWith({
    String? query,
    SearchType? type,
    SearchStatus? status,
    List<Show>? shows,
    List<Person>? people,
    String? errorMessage,
  }) {
    return SearchState(
      query: query ?? this.query,
      type: type ?? this.type,
      status: status ?? this.status,
      shows: shows ?? this.shows,
      people: people ?? this.people,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [query, type, status, shows, people, errorMessage];
}
