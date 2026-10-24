import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tvmaze_app/bloc/shows/shows_bloc.dart';
import 'package:tvmaze_app/core/errors/app_exception.dart';

import 'helpers.dart';

void main() {
  late MockShowRepository repo;

  setUp(() => repo = MockShowRepository());

  blocTest<ShowsBloc, ShowsState>(
    'loads the first page',
    setUp: () => when(() => repo.getShows(page: 0)).thenAnswer((_) async => [fakeShow(1), fakeShow(2)]),
    build: () => ShowsBloc(repository: repo),
    act: (bloc) => bloc.add(const ShowsFetched()),
    expect: () => [
      const ShowsState(status: ShowsStatus.loading),
      ShowsState(status: ShowsStatus.success, shows: [fakeShow(1), fakeShow(2)], nextPage: 1),
    ],
  );

  blocTest<ShowsBloc, ShowsState>(
    'appends the next page (pagination)',
    setUp: () => when(() => repo.getShows(page: 1)).thenAnswer((_) async => [fakeShow(3)]),
    build: () => ShowsBloc(repository: repo),
    seed: () => ShowsState(status: ShowsStatus.success, shows: [fakeShow(1)], nextPage: 1),
    act: (bloc) => bloc.add(const ShowsFetched()),
    skip: 1,
    expect: () => [
      ShowsState(status: ShowsStatus.success, shows: [fakeShow(1), fakeShow(3)], nextPage: 2),
    ],
  );

  blocTest<ShowsBloc, ShowsState>(
    'empty page marks hasReachedMax and stops fetching',
    setUp: () => when(() => repo.getShows(page: 1)).thenAnswer((_) async => []),
    build: () => ShowsBloc(repository: repo),
    seed: () => ShowsState(status: ShowsStatus.success, shows: [fakeShow(1)], nextPage: 1),
    act: (bloc) async {
      bloc.add(const ShowsFetched());
      await Future<void>.delayed(Duration.zero);
      bloc.add(const ShowsFetched());
    },
    skip: 1,
    expect: () => [
      ShowsState(status: ShowsStatus.success, shows: [fakeShow(1)], nextPage: 1, hasReachedMax: true),
    ],
    verify: (_) => verify(() => repo.getShows(page: 1)).called(1),
  );

  blocTest<ShowsBloc, ShowsState>(
    'emits failure with message on error',
    setUp: () => when(() => repo.getShows(page: 0)).thenThrow(const NetworkException()),
    build: () => ShowsBloc(repository: repo),
    act: (bloc) => bloc.add(const ShowsFetched()),
    expect: () => [
      const ShowsState(status: ShowsStatus.loading),
      ShowsState(status: ShowsStatus.failure, errorMessage: const NetworkException().message),
    ],
  );

  test('trending is sorted by rating', () {
    final state = ShowsState(shows: [fakeShow(1, rating: 7), fakeShow(2), fakeShow(3, rating: 9)]);
    expect(state.trending.map((s) => s.id), [3, 1]);
  });
}
