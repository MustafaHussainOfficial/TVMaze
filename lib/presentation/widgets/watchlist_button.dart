import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/watchlist/watchlist_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/show.dart';

class WatchlistIconButton extends StatelessWidget {
  const WatchlistIconButton({super.key, required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      buildWhen: (prev, curr) => prev.contains(show.id) != curr.contains(show.id),
      builder: (context, state) {
        final saved = state.contains(show.id);
        return IconButton(
          tooltip: saved ? 'Remove from watchlist' : 'Add to watchlist',
          icon: Icon(
            saved ? Icons.favorite : Icons.favorite_border,
            color: saved ? AppColors.favorite : AppColors.textPrimary,
          ),
          onPressed: () => toggleWatchlist(context, show),
        );
      },
    );
  }
}

class WatchlistActionButton extends StatelessWidget {
  const WatchlistActionButton({super.key, required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      buildWhen: (prev, curr) => prev.contains(show.id) != curr.contains(show.id),
      builder: (context, state) {
        final saved = state.contains(show.id);
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: saved ? AppColors.surfaceLight : AppColors.primary,
            ),
            onPressed: () => toggleWatchlist(context, show),
            icon: Icon(saved ? Icons.check_rounded : Icons.add_rounded),
            label: Text(saved ? 'In Watchlist · Tap to remove' : 'Add to Watchlist'),
          ),
        );
      },
    );
  }
}

void toggleWatchlist(BuildContext context, Show show) {
  final bloc = context.read<WatchlistBloc>();
  final wasSaved = bloc.state.contains(show.id);
  bloc.add(WatchlistToggled(show));
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      duration: const Duration(seconds: 2),
      content: Text(wasSaved
          ? '${show.name} removed from your watchlist'
          : '${show.name} added to your watchlist'),
    ));
}
