part of 'shows_bloc.dart';

sealed class ShowsEvent extends Equatable {
  const ShowsEvent();

  @override
  List<Object?> get props => [];
}

final class ShowsFetched extends ShowsEvent {
  const ShowsFetched();
}

final class ShowsRefreshed extends ShowsEvent {
  const ShowsRefreshed();
}
