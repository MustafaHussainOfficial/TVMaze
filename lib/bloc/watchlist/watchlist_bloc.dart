import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/show.dart';
import '../../data/repositories/watchlist_repository.dart';

part 'watchlist_event.dart';
part 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  WatchlistBloc({required WatchlistRepository repository})
      : _repository = repository,
        super(const WatchlistState()) {
    on<WatchlistEvent>(
      (event, emit) => switch (event) {
        WatchlistLoaded() => _onLoaded(emit),
        WatchlistToggled(:final show) => _onToggled(show, emit),
        WatchlistShowRemoved(:final showId) => _update(
            state.shows.where((s) => s.id != showId).toList(), emit),
        WatchlistCleared() => _update(const [], emit),
      },
      transformer: sequential(),
    );
  }

  final WatchlistRepository _repository;

  Future<void> _onLoaded(Emitter<WatchlistState> emit) async {
    emit(state.copyWith(status: WatchlistStatus.loading));
    final shows = _repository.loadWatchlist();
    emit(WatchlistState(
      status: shows.isEmpty ? WatchlistStatus.empty : WatchlistStatus.success,
      shows: shows,
    ));
  }

  Future<void> _onToggled(Show show, Emitter<WatchlistState> emit) {
    final updated = state.contains(show.id)
        ? state.shows.where((s) => s.id != show.id).toList()
        : [show, ...state.shows];
    return _update(updated, emit);
  }

  Future<void> _update(List<Show> shows, Emitter<WatchlistState> emit) async {
    final previous = state.shows;
    emit(WatchlistState(
      status: shows.isEmpty ? WatchlistStatus.empty : WatchlistStatus.success,
      shows: shows,
    ));
    try {
      await _repository.saveWatchlist(shows);
    } on AppException catch (e) {
      emit(WatchlistState(
        status: WatchlistStatus.failure,
        shows: previous,
        errorMessage: e.message,
      ));
    }
  }
}
