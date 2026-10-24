import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tvmaze_app/core/errors/app_exception.dart';
import 'package:tvmaze_app/data/repositories/show_repository.dart';
import 'package:tvmaze_app/data/services/tvmaze_api_service.dart';

void main() {
  test('search maps results and builds the correct URL', () async {
    late Uri requested;
    final api = TvMazeApiService(
      client: MockClient((req) async {
        requested = req.url;
        return http.Response(
          jsonEncode([
            {'score': 1, 'show': {'id': 1, 'name': 'Dark'}},
            {'score': 0.5, 'show': 'broken'},
          ]),
          200,
        );
      }),
    );
    final shows = await api.searchShows('dark');
    expect(requested.toString(), 'https://api.tvmaze.com/search/shows?q=dark');
    expect(shows.single.name, 'Dark');
  });

  test('404 on a page means "no more pages" in the repository', () async {
    final repo = ShowRepository(
      apiService: TvMazeApiService(client: MockClient((_) async => http.Response('', 404))),
    );
    expect(await repo.getShows(page: 999), isEmpty);
  });

  test('server errors become ServerException', () {
    final api = TvMazeApiService(client: MockClient((_) async => http.Response('', 500)));
    expect(api.fetchShowDetails(1), throwsA(isA<ServerException>()));
  });

  test('network failures become NetworkException', () {
    final api = TvMazeApiService(
      client: MockClient((_) async => throw http.ClientException('offline')),
    );
    expect(api.fetchCast(1), throwsA(isA<NetworkException>()));
  });

  test('invalid JSON becomes ParsingException', () {
    final api = TvMazeApiService(client: MockClient((_) async => http.Response('<html>', 200)));
    expect(api.fetchEpisodes(1), throwsA(isA<ParsingException>()));
  });
}
