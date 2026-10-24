import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/navigation/navigation_cubit.dart';
import '../../bloc/watchlist/watchlist_bloc.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import 'watchlist_screen.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    final tab = context.watch<NavigationCubit>().state;

    return BlocListener<WatchlistBloc, WatchlistState>(
      listenWhen: (prev, curr) => curr.status == WatchlistStatus.failure,
      listener: (context, state) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.errorMessage ?? 'Watchlist error'))),
      child: Scaffold(
        body: IndexedStack(
          index: tab.index,
          children: const [HomeScreen(), SearchScreen(), WatchlistScreen(), ProfileScreen()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab.index,
          onDestinationSelected: (i) => context.read<NavigationCubit>().select(AppTab.values[i]),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(
                icon: Icon(Icons.search), selectedIcon: Icon(Icons.search_rounded), label: 'Search'),
            NavigationDestination(
                icon: Icon(Icons.favorite_border), selectedIcon: Icon(Icons.favorite), label: 'Watchlist'),
            NavigationDestination(
                icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
