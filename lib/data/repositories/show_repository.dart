import '../../core/errors/app_exception.dart';
import '../models/cast_member.dart';
import '../models/episode.dart';
import '../models/person.dart';
import '../models/show.dart';
import '../services/tvmaze_api_service.dart';

class ShowRepository {
  ShowRepository({required TvMazeApiService apiService}) : _api = apiService;

  final TvMazeApiService _api;

  Future<List<Show>> getShows({required int page}) async {
    try {
      return await _api.fetchShows(page);
    } on NotFoundException {
      return const [];
    }
  }

  Future<List<Show>> searchShows(String query) => _api.searchShows(query);

  Future<List<Person>> searchPeople(String query) => _api.searchPeople(query);

  Future<Show> getShowDetails(int id) => _api.fetchShowDetails(id);

  Future<List<CastMember>> getCast(int showId) => _api.fetchCast(showId);

  Future<List<Episode>> getEpisodes(int showId) => _api.fetchEpisodes(showId);
}
