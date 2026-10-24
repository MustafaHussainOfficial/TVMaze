import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tvmaze_app/bloc/watchlist/watchlist_bloc.dart';
import 'package:tvmaze_app/data/repositories/watchlist_repository.dart';

import 'helpers.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<WatchlistBloc> createBloc() async {
    final prefs = await SharedPreferences.getInstance();
    final bloc = WatchlistBloc(repository: WatchlistRepository(preferences: prefs))
      ..add(const WatchlistLoaded());
    await Future<void>.delayed(Duration.zero);
    return bloc;
  }

  test('starts empty', () async {
    final bloc = await createBloc();
    expect(bloc.state.status, WatchlistStatus.empty);
    await bloc.close();
  });

  test('toggle adds then removes a show', () async {
    final bloc = await createBloc();
    bloc.add(WatchlistToggled(fakeShow(1)));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.contains(1), isTrue);

    bloc.add(WatchlistToggled(fakeShow(1)));
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.contains(1), isFalse);
    await bloc.close();
  });

  test('watchlist survives an app restart (new bloc, same storage)', () async {
    final first = await createBloc();
    first
      ..add(WatchlistToggled(fakeShow(1, name: 'Dark')))
      ..add(WatchlistToggled(fakeShow(2, name: 'Lost')));
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await first.close();

    final second = await createBloc();
    expect(second.state.shows.map((s) => s.name), ['Lost', 'Dark']);
    await second.close();
  });
}
