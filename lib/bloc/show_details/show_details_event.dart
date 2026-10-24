part of 'show_details_bloc.dart';

sealed class ShowDetailsEvent extends Equatable {
  const ShowDetailsEvent();

  @override
  List<Object?> get props => [];
}

final class ShowDetailsStarted extends ShowDetailsEvent {
  const ShowDetailsStarted();
}

final class ShowInfoRequested extends ShowDetailsEvent {
  const ShowInfoRequested();
}

final class ShowCastRequested extends ShowDetailsEvent {
  const ShowCastRequested();
}

final class ShowEpisodesRequested extends ShowDetailsEvent {
  const ShowEpisodesRequested();
}

final class SeasonSelected extends ShowDetailsEvent {
  const SeasonSelected(this.season);

  final int season;

  @override
  List<Object?> get props => [season];
}
