import 'package:flutter_test/flutter_test.dart';
import 'package:tvmaze_app/core/utils/text_utils.dart';
import 'package:tvmaze_app/data/models/cast_member.dart';
import 'package:tvmaze_app/data/models/episode.dart';
import 'package:tvmaze_app/data/models/show.dart';

void main() {
  group('Show', () {
    test('parses a full API object', () {
      final show = Show.fromJson({
        'id': 169,
        'name': 'Breaking Bad',
        'genres': ['Drama', 'Crime'],
        'status': 'Ended',
        'premiered': '2008-01-20',
        'ended': '2013-09-29',
        'rating': {'average': 9.2},
        'network': {'name': 'AMC'},
        'image': {'medium': 'm.jpg', 'original': 'o.jpg'},
        'summary': '<p><b>Breaking Bad</b> follows &amp; more</p>',
      });
      expect(show.name, 'Breaking Bad');
      expect(show.rating, 9.2);
      expect(show.network, 'AMC');
      expect(show.yearRange, '2008 - 2013');
      expect(show.summary, 'Breaking Bad follows & more');
    });

    test('handles missing information gracefully', () {
      final show = Show.fromJson({
        'id': 1,
        'name': null,
        'genres': null,
        'rating': {'average': null},
        'image': null,
        'network': null,
        'webChannel': {'name': 'Netflix'},
        'summary': null,
      });
      expect(show.name, 'Untitled');
      expect(show.genres, isEmpty);
      expect(show.rating, isNull);
      expect(show.posterUrl, isNull);
      expect(show.network, 'Netflix');
      expect(show.yearRange, 'Unknown');
    });

    test('running show shows Present', () {
      const show = Show(id: 1, name: 'x', premiered: '2023-01-15', status: 'Running');
      expect(show.yearRange, '2023 - Present');
    });

    test('toJson / fromJson round trip (used by the watchlist)', () {
      const show = Show(
        id: 5,
        name: 'Dark',
        genres: ['Drama'],
        rating: 8.7,
        network: 'Netflix',
        imageMedium: 'm.jpg',
        imageOriginal: 'o.jpg',
        summary: 'Time travel',
      );
      final copy = Show.fromJson(show.toJson());
      expect(copy, show);
      expect(copy.genres, ['Drama']);
      expect(copy.network, 'Netflix');
      expect(copy.summary, 'Time travel');
    });
  });

  test('CastMember parses person and character', () {
    final member = CastMember.fromJson({
      'person': {'id': 1, 'name': 'Bryan Cranston', 'image': null},
      'character': {'name': 'Walter White', 'image': {'medium': 'c.jpg'}},
    });
    expect(member.personName, 'Bryan Cranston');
    expect(member.characterName, 'Walter White');
    expect(member.imageUrl, 'c.jpg');
  });

  test('Episode parses airdate and allows null number', () {
    final ep = Episode.fromJson({'id': 1, 'name': 'Special', 'season': 2, 'number': null, 'airdate': ''});
    expect(ep.number, isNull);
    expect(ep.airdate, isNull);
    expect(TextUtils.formatDate(DateTime(2008, 1, 20)), 'Jan 20, 2008');
  });
}
