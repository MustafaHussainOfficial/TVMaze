import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/app_exception.dart';
import '../../core/utils/event_transformers.dart';
import '../../data/models/person.dart';
import '../../data/models/show.dart';
import '../../data/repositories/show_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({
    required ShowRepository repository,
    this.debounceDuration = const Duration(milliseconds: 500),
  })  : _repository = repository,
        super(const SearchState()) {
    on<SearchQueryChanged>(_onQueryChanged, transformer: debounceRestartable(debounceDuration));
    on<SearchTypeChanged>(_onTypeChanged, transformer: restartable());
    on<SearchRetried>((_, emit) => _search(emit), transformer: restartable());
    on<SearchCleared>((_, emit) => emit(SearchState(type: state.type)));
  }

  final ShowRepository _repository;
  final Duration debounceDuration;

  Future<void> _onQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) async {
    final query = event.query.trim();
    if (query == state.query && state.status != SearchStatus.failure) return;
    if (query.isEmpty) {
      emit(SearchState(type: state.type));
      return;
    }
    emit(state.copyWith(query: query));
    await _search(emit);
  }

  Future<void> _onTypeChanged(SearchTypeChanged event, Emitter<SearchState> emit) async {
    if (event.type == state.type) return;
    emit(state.copyWith(type: event.type, status: SearchStatus.initial));
    if (state.query.isNotEmpty) await _search(emit);
  }

  Future<void> _search(Emitter<SearchState> emit) async {
    final query = state.query;
    final type = state.type;
    if (query.isEmpty) return;

    emit(state.copyWith(status: SearchStatus.loading));
    try {
      if (type == SearchType.shows) {
        final shows = await _repository.searchShows(query);
        if (_isStale(query, type)) return;
        emit(state.copyWith(
          status: shows.isEmpty ? SearchStatus.empty : SearchStatus.success,
          shows: shows,
        ));
      } else {
        final people = await _repository.searchPeople(query);
        if (_isStale(query, type)) return;
        emit(state.copyWith(
          status: people.isEmpty ? SearchStatus.empty : SearchStatus.success,
          people: people,
        ));
      }
    } on AppException catch (e) {
      if (_isStale(query, type)) return;
      emit(state.copyWith(status: SearchStatus.failure, errorMessage: e.message));
    }
  }

  bool _isStale(String query, SearchType type) => state.query != query || state.type != type;
}
