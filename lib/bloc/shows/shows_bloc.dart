import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/show.dart';
import '../../data/repositories/show_repository.dart';

part 'shows_event.dart';
part 'shows_state.dart';

class ShowsBloc extends Bloc<ShowsEvent, ShowsState> {
  ShowsBloc({required ShowRepository repository})
      : _repository = repository,
        super(const ShowsState()) {
    on<ShowsEvent>(
      (event, emit) => switch (event) {
        ShowsFetched() => _onFetched(emit),
        ShowsRefreshed() => _onRefreshed(emit),
      },
      transformer: droppable(),
    );
  }

  final ShowRepository _repository;

  Future<void> _onFetched(Emitter<ShowsState> emit) async {
    if (state.hasReachedMax) return;
    emit(state.copyWith(status: ShowsStatus.loading));

    try {
      final page = await _repository.getShows(page: state.nextPage);
      if (page.isEmpty) {
        emit(state.copyWith(
          status: state.shows.isEmpty ? ShowsStatus.empty : ShowsStatus.success,
          hasReachedMax: true,
        ));
        return;
      }
      emit(state.copyWith(
        status: ShowsStatus.success,
        shows: [...state.shows, ...page],
        nextPage: state.nextPage + 1,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: ShowsStatus.failure, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
          status: ShowsStatus.failure, errorMessage: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _onRefreshed(Emitter<ShowsState> emit) async {
    try {
      final page = await _repository.getShows(page: 0);
      emit(ShowsState(
        status: page.isEmpty ? ShowsStatus.empty : ShowsStatus.success,
        shows: page,
        nextPage: 1,
        hasReachedMax: page.isEmpty,
      ));
    } on AppException catch (e) {
      emit(state.copyWith(status: ShowsStatus.failure, errorMessage: e.message));
    }
  }
}
