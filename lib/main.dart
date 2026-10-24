import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'bloc/app_bloc_observer.dart';
import 'data/repositories/show_repository.dart';
import 'data/repositories/watchlist_repository.dart';
import 'data/services/tvmaze_api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();

  final preferences = await SharedPreferences.getInstance();

  runApp(TvMazeApp(
    showRepository: ShowRepository(apiService: TvMazeApiService()),
    watchlistRepository: WatchlistRepository(preferences: preferences),
  ));
}
