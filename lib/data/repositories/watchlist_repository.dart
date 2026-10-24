import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/app_exception.dart';
import '../models/show.dart';

class WatchlistRepository {
  WatchlistRepository({required SharedPreferences preferences}) : _prefs = preferences;

  static const String storageKey = 'watchlist_shows';

  final SharedPreferences _prefs;

  List<Show> loadWatchlist() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.whereType<Map<String, dynamic>>().map(Show.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWatchlist(List<Show> shows) async {
    final encoded = jsonEncode(shows.map((s) => s.toJson()).toList());
    final ok = await _prefs.setString(storageKey, encoded);
    if (!ok) throw const AppException('Could not save your watchlist. Please try again.');
  }
}
