import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tvmaze_app/bloc/show_details/show_details_bloc.dart';
import 'package:tvmaze_app/core/errors/app_exception.dart';
import 'package:tvmaze_app/data/models/episode.dart';

import 'helpers.dart';

void main() {
  test('groupBySeason groups and sorts episodes', () {
    final grouped = ShowDetailsBloc.groupBySeason(const [
      Episode(id: 3, name: 'c', season: 2, number: 1),
      Episode(id: 2, name: 'b', season: 1, number: 2),
      Episode(id: 1, name: 'a', season: 1, number: 1),
    ]);
    expect(grouped.keys, [1, 2]);
    expect(grouped[1]!.map((e) => e.id), [1, 2]);
  });

  test('a failing cast request does not break episodes', () async {
    final repo = MockShowRepository();
    when(() => repo.getShowDetails(7)).thenAnswer((_) async => fakeShow(7));
    when(() => repo.getCast(7)).thenThrow(const NetworkException());
    when(() => repo.getEpisodes(7)).thenAnswer(
        (_) async => const [Episode(id: 1, name: 'Pilot', season: 1, number: 1)]);

    final bloc = ShowDetailsBloc(repository: repo, showId: 7)..add(const ShowDetailsStarted());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(bloc.state.infoStatus, LoadStatus.success);
    expect(bloc.state.castStatus, LoadStatus.failure);
    expect(bloc.state.episodesStatus, LoadStatus.success);
    expect(bloc.state.selectedSeason, 1);
    await bloc.close();
  });
}
