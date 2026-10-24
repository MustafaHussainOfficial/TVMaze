import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/navigation/navigation_cubit.dart';
import '../../bloc/watchlist/watchlist_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/show_list_tile.dart';
import '../widgets/state_views.dart';
import 'show_details_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  Future<void> _confirmClear(BuildContext context) async {
    final bloc = context.read<WatchlistBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Clear watchlist?'),
        content: const Text('All saved shows will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) bloc.add(const WatchlistCleared());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlist'),
        actions: [
          BlocBuilder<WatchlistBloc, WatchlistState>(
            builder: (context, state) => state.shows.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Clear all',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _confirmClear(context),
                  ),
          ),
        ],
      ),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          if (state.status == WatchlistStatus.initial || state.status == WatchlistStatus.loading) {
            return const LoadingView();
          }
          if (state.shows.isEmpty) {
            return EmptyView(
              icon: Icons.favorite_rounded,
              title: 'Your watchlist is empty',
              message: 'Discover amazing shows and save\nthem here to watch later.',
              actionLabel: 'Explore Shows',
              onAction: () => context.read<NavigationCubit>().select(AppTab.home),
            );
          }
          return ListView.separated(
            itemCount: state.shows.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, i) {
              final show = state.shows[i];
              return Dismissible(
                key: ValueKey(show.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.error.withValues(alpha: 0.2),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete_outline, color: AppColors.error),
                ),
                onDismissed: (_) {
                  final bloc = context.read<WatchlistBloc>()..add(WatchlistShowRemoved(show.id));
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text('${show.name} removed'),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () => bloc.add(WatchlistToggled(show)),
                      ),
                    ));
                },
                child: ShowListTile(
                  show: show,
                  onTap: () => ShowDetailsScreen.open(context, show),
                  trailing: IconButton(
                    tooltip: 'Remove',
                    icon: const Icon(Icons.favorite, color: AppColors.favorite),
                    onPressed: () => context.read<WatchlistBloc>().add(WatchlistShowRemoved(show.id)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
