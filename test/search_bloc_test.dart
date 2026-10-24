import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tvmaze_app/bloc/search/search_bloc.dart';
import 'package:tvmaze_app/core/errors/app_exception.dart';

import 'helpers.dart';

void main() {
  late MockShowRepository repo;
  const debounce = Duration(milliseconds: 50);
  const wait = Duration(milliseconds: 120);

  setUp(() => repo = MockShowRepository());

  blocTest<SearchBloc, SearchState>(
    'debounces typing and only searches the final query',
    setUp: () => when(() => repo.searchShows(any())).thenAnswer((_) async => [fakeShow(1)]),
    build: () => SearchBloc(repository: repo, debounceDuration: debounce),
    act: (bloc) {
      bloc
        ..add(const SearchQueryChanged('d'))
        ..add(const SearchQueryChanged('da'))
        ..add(const SearchQueryChanged('dark'));
    },
    wait: wait,
    expect: () => [
      const SearchState(query: 'dark'),
      const SearchState(query: 'dark', status: SearchStatus.loading),
      SearchState(query: 'dark', status: SearchStatus.success, shows: [fakeShow(1)]),
    ],
    verify: (_) {
      verify(() => repo.searchShows('dark')).called(1);
      verifyNever(() => repo.searchShows('d'));
    },
  );

  blocTest<SearchBloc, SearchState>(
    'emits empty when nothing is found',
    setUp: () => when(() => repo.searchShows(any())).thenAnswer((_) async => []),
    build: () => SearchBloc(repository: repo, debounceDuration: debounce),
    act: (bloc) => bloc.add(const SearchQueryChanged('zzzz')),
    wait: wait,
    expect: () => [
      const SearchState(query: 'zzzz'),
      const SearchState(query: 'zzzz', status: SearchStatus.loading),
      const SearchState(query: 'zzzz', status: SearchStatus.empty),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'emits failure on error',
    setUp: () => when(() => repo.searchShows(any())).thenThrow(const TimeoutAppException()),
    build: () => SearchBloc(repository: repo, debounceDuration: debounce),
    act: (bloc) => bloc.add(const SearchQueryChanged('dark')),
    wait: wait,
    skip: 2,
    expect: () => [
      SearchState(
        query: 'dark',
        status: SearchStatus.failure,
        errorMessage: const TimeoutAppException().message,
      ),
    ],
  );

  blocTest<SearchBloc, SearchState>(
    'empty query resets to initial without calling the API',
    build: () => SearchBloc(repository: repo, debounceDuration: debounce),
    seed: () => const SearchState(query: 'dark', status: SearchStatus.empty),
    act: (bloc) => bloc.add(const SearchQueryChanged('  ')),
    wait: wait,
    expect: () => [const SearchState()],
    verify: (_) => verifyNever(() => repo.searchShows(any())),
  );
}
