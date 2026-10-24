class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.tvmaze.com';

  static const String shows = '/shows';
  static const String searchShows = '/search/shows';
  static const String searchPeople = '/search/people';

  static String showDetails(int id) => '/shows/$id';
  static String showCast(int id) => '/shows/$id/cast';
  static String showEpisodes(int id) => '/shows/$id/episodes';

  static const Duration requestTimeout = Duration(seconds: 15);
}
