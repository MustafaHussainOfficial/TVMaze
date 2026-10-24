import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/navigation/navigation_cubit.dart';
import 'bloc/search/search_bloc.dart';
import 'bloc/shows/shows_bloc.dart';
import 'bloc/watchlist/watchlist_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/show_repository.dart';
import 'data/repositories/watchlist_repository.dart';
import 'presentation/screens/main_shell.dart';

class TvMazeApp extends StatelessWidget {
  const TvMazeApp({
    super.key,
    required this.showRepository,
    required this.watchlistRepository,
  });

  final ShowRepository showRepository;
  final WatchlistRepository watchlistRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: showRepository),
        RepositoryProvider.value(value: watchlistRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => NavigationCubit()),
          BlocProvider(
            create: (_) => ShowsBloc(repository: showRepository)..add(const ShowsFetched()),
          ),
          BlocProvider(create: (_) => SearchBloc(repository: showRepository)),
          BlocProvider(
            create: (_) => WatchlistBloc(repository: watchlistRepository)..add(const WatchlistLoaded()),
          ),
        ],
        child: MaterialApp(
          title: 'TVMaze',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          home: const MainShell(),
        ),
      ),
    );
  }
}
