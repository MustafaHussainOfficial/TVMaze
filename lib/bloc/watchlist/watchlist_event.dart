part of 'watchlist_bloc.dart';

sealed class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

final class WatchlistLoaded extends WatchlistEvent {
  const WatchlistLoaded();
}

final class WatchlistToggled extends WatchlistEvent {
  const WatchlistToggled(this.show);

  final Show show;

  @override
  List<Object?> get props => [show];
}

final class WatchlistShowRemoved extends WatchlistEvent {
  const WatchlistShowRemoved(this.showId);

  final int showId;

  @override
  List<Object?> get props => [showId];
}

final class WatchlistCleared extends WatchlistEvent {
  const WatchlistCleared();
}
