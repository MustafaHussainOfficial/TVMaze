import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/errors/app_exception.dart';
import '../models/cast_member.dart';
import '../models/episode.dart';
import '../models/person.dart';
import '../models/show.dart';

class TvMazeApiService {
  TvMazeApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Show>> fetchShows(int page) async {
    final data = await _get(ApiConstants.shows, {'page': '$page'});
    return _parseList(data, Show.fromJson);
  }

  Future<List<Show>> searchShows(String query) async {
    final data = await _get(ApiConstants.searchShows, {'q': query});
    return _parseList(data, (item) => Show.fromJson(item['show'] as Map<String, dynamic>));
  }

  Future<List<Person>> searchPeople(String query) async {
    final data = await _get(ApiConstants.searchPeople, {'q': query});
    return _parseList(data, (item) => Person.fromJson(item['person'] as Map<String, dynamic>));
  }

  Future<Show> fetchShowDetails(int id) async {
    final data = await _get(ApiConstants.showDetails(id));
    try {
      return Show.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      throw const ParsingException();
    }
  }

  Future<List<CastMember>> fetchCast(int id) async {
    final data = await _get(ApiConstants.showCast(id));
    return _parseList(data, CastMember.fromJson);
  }

  Future<List<Episode>> fetchEpisodes(int id) async {
    final data = await _get(ApiConstants.showEpisodes(id));
    return _parseList(data, Episode.fromJson);
  }

  Future<dynamic> _get(String path, [Map<String, String>? query]) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path').replace(queryParameters: query);

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(ApiConstants.requestTimeout);
    } on TimeoutException {
      throw const TimeoutAppException();
    } on http.ClientException {
      throw const NetworkException();
    } catch (_) {
      throw const NetworkException();
    }

    switch (response.statusCode) {
      case 200:
        try {
          return jsonDecode(response.body);
        } on FormatException {
          throw const ParsingException();
        }
      case 404:
        throw const NotFoundException();
      case 429:
        throw const AppException('Too many requests. Please wait a moment and try again.',
            statusCode: 429);
      default:
        throw ServerException(response.statusCode);
    }
  }

  List<T> _parseList<T>(dynamic data, T Function(Map<String, dynamic>) parser) {
    if (data is! List) throw const ParsingException();
    final result = <T>[];
    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;
      try {
        result.add(parser(item));
      } catch (_) {
      }
    }
    return result;
  }
}
