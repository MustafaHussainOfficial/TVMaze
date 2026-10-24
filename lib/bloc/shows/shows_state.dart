part of 'shows_bloc.dart';

enum ShowsStatus { initial, loading, success, empty, failure }

class ShowsState extends Equatable {
  const ShowsState({
    this.status = ShowsStatus.initial,
    this.shows = const [],
    this.nextPage = 0,
    this.hasReachedMax = false,
    this.errorMessage,
  });

  final ShowsStatus status;
  final List<Show> shows;
  final int nextPage;
  final bool hasReachedMax;
  final String? errorMessage;

  bool get isFirstLoad => shows.isEmpty && (status == ShowsStatus.initial || status == ShowsStatus.loading);
  bool get isLoadingMore => shows.isNotEmpty && status == ShowsStatus.loading;

  List<Show> get topRated =>
      shows.where((s) => s.rating != null).toList()..sort((a, b) => b.rating!.compareTo(a.rating!));

  List<Show> get mostPopular => [...shows]..sort((a, b) => b.weight.compareTo(a.weight));

  List<Show> get trending => topRated.take(10).toList();
  List<Show> get popular => mostPopular.take(10).toList();

  ShowsState copyWith({
    ShowsStatus? status,
    List<Show>? shows,
    int? nextPage,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return ShowsState(
      status: status ?? this.status,
      shows: shows ?? this.shows,
      nextPage: nextPage ?? this.nextPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, shows, nextPage, hasReachedMax, errorMessage];
}
