part of 'watchlist_bloc.dart';

enum WatchlistStatus { initial, loading, success, empty, failure }

class WatchlistState extends Equatable {
  const WatchlistState({
    this.status = WatchlistStatus.initial,
    this.shows = const [],
    this.errorMessage,
  });

  final WatchlistStatus status;
  final List<Show> shows;
  final String? errorMessage;

  bool contains(int showId) => shows.any((s) => s.id == showId);

  WatchlistState copyWith({
    WatchlistStatus? status,
    List<Show>? shows,
    String? errorMessage,
  }) {
    return WatchlistState(
      status: status ?? this.status,
      shows: shows ?? this.shows,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, shows, errorMessage];
}
