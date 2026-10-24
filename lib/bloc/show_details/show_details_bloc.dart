import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/cast_member.dart';
import '../../data/models/episode.dart';
import '../../data/models/show.dart';
import '../../data/repositories/show_repository.dart';

part 'show_details_event.dart';
part 'show_details_state.dart';

class ShowDetailsBloc extends Bloc<ShowDetailsEvent, ShowDetailsState> {
  ShowDetailsBloc({
    required ShowRepository repository,
    required int showId,
    Show? initialShow,
  })  : _repository = repository,
        super(ShowDetailsState(showId: showId, show: initialShow)) {
    on<ShowDetailsStarted>(_onStarted);
    on<ShowInfoRequested>(_onInfoRequested);
    on<ShowCastRequested>(_onCastRequested);
    on<ShowEpisodesRequested>(_onEpisodesRequested);
    on<SeasonSelected>((event, emit) => emit(state.copyWith(selectedSeason: event.season)));
  }

  final ShowRepository _repository;

  void _onStarted(ShowDetailsStarted event, Emitter<ShowDetailsState> emit) {
    add(const ShowInfoRequested());
    add(const ShowCastRequested());
    add(const ShowEpisodesRequested());
  }

  Future<void> _onInfoRequested(ShowInfoRequested event, Emitter<ShowDetailsState> emit) async {
    emit(state.copyWith(infoStatus: LoadStatus.loading, infoError: () => null));
    try {
      final show = await _repository.getShowDetails(state.showId);
      emit(state.copyWith(show: show, infoStatus: LoadStatus.success));
    } on AppException catch (e) {
      emit(state.copyWith(infoStatus: LoadStatus.failure, infoError: () => e.message));
    }
  }

  Future<void> _onCastRequested(ShowCastRequested event, Emitter<ShowDetailsState> emit) async {
    emit(state.copyWith(castStatus: LoadStatus.loading, castError: () => null));
    try {
      final cast = await _repository.getCast(state.showId);
      emit(state.copyWith(
        cast: cast,
        castStatus: cast.isEmpty ? LoadStatus.empty : LoadStatus.success,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(castStatus: LoadStatus.failure, castError: () => e.message));
    }
  }

  Future<void> _onEpisodesRequested(
      ShowEpisodesRequested event, Emitter<ShowDetailsState> emit) async {
    emit(state.copyWith(episodesStatus: LoadStatus.loading, episodesError: () => null));
    try {
      final episodes = await _repository.getEpisodes(state.showId);
      final grouped = groupBySeason(episodes);
      emit(state.copyWith(
        episodesBySeason: grouped,
        episodesStatus: grouped.isEmpty ? LoadStatus.empty : LoadStatus.success,
        selectedSeason: grouped.isEmpty ? null : grouped.keys.first,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(episodesStatus: LoadStatus.failure, episodesError: () => e.message));
    }
  }

  static Map<int, List<Episode>> groupBySeason(List<Episode> episodes) {
    final map = <int, List<Episode>>{};
    for (final episode in episodes) {
      map.putIfAbsent(episode.season, () => []).add(episode);
    }
    final seasons = map.keys.toList()..sort();
    return {
      for (final season in seasons)
        season: map[season]!
          ..sort((a, b) => (a.number ?? 9999).compareTo(b.number ?? 9999)),
    };
  }
}
