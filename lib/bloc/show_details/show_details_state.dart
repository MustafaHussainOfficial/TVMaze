part of 'show_details_bloc.dart';

enum LoadStatus { initial, loading, success, empty, failure }

class ShowDetailsState extends Equatable {
  const ShowDetailsState({
    required this.showId,
    this.show,
    this.infoStatus = LoadStatus.initial,
    this.infoError,
    this.cast = const [],
    this.castStatus = LoadStatus.initial,
    this.castError,
    this.episodesBySeason = const {},
    this.episodesStatus = LoadStatus.initial,
    this.episodesError,
    this.selectedSeason,
  });

  final int showId;

  final Show? show;
  final LoadStatus infoStatus;
  final String? infoError;

  final List<CastMember> cast;
  final LoadStatus castStatus;
  final String? castError;

  final Map<int, List<Episode>> episodesBySeason;
  final LoadStatus episodesStatus;
  final String? episodesError;
  final int? selectedSeason;

  List<int> get seasons => episodesBySeason.keys.toList();
  List<Episode> get selectedEpisodes => episodesBySeason[selectedSeason] ?? const [];

  ShowDetailsState copyWith({
    Show? show,
    LoadStatus? infoStatus,
    String? Function()? infoError,
    List<CastMember>? cast,
    LoadStatus? castStatus,
    String? Function()? castError,
    Map<int, List<Episode>>? episodesBySeason,
    LoadStatus? episodesStatus,
    String? Function()? episodesError,
    int? selectedSeason,
  }) {
    return ShowDetailsState(
      showId: showId,
      show: show ?? this.show,
      infoStatus: infoStatus ?? this.infoStatus,
      infoError: infoError != null ? infoError() : this.infoError,
      cast: cast ?? this.cast,
      castStatus: castStatus ?? this.castStatus,
      castError: castError != null ? castError() : this.castError,
      episodesBySeason: episodesBySeason ?? this.episodesBySeason,
      episodesStatus: episodesStatus ?? this.episodesStatus,
      episodesError: episodesError != null ? episodesError() : this.episodesError,
      selectedSeason: selectedSeason ?? this.selectedSeason,
    );
  }

  @override
  List<Object?> get props => [
        showId, show, infoStatus, infoError,
        cast, castStatus, castError,
        episodesBySeason, episodesStatus, episodesError, selectedSeason,
      ];
}
