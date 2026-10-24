import 'package:flutter/material.dart';

import '../../data/models/show.dart';
import '../screens/show_details_screen.dart';
import 'show_poster_card.dart';

class ShowSliverGrid extends StatelessWidget {
  const ShowSliverGrid({super.key, required this.shows});

  final List<Show> shows;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 160,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.52,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => ShowPosterCard(
            show: shows[index],
            onTap: () => ShowDetailsScreen.open(context, shows[index]),
          ),
          childCount: shows.length,
        ),
      ),
    );
  }
}

class PaginationFooter extends StatelessWidget {
  const PaginationFooter({
    super.key,
    required this.isLoading,
    required this.hasReachedMax,
    this.errorMessage,
    required this.onRetry,
  });

  final bool isLoading;
  final bool hasReachedMax;
  final String? errorMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (errorMessage != null) {
      child = Column(
        children: [
          Text(errorMessage!, textAlign: TextAlign.center),
          TextButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Retry')),
        ],
      );
    } else if (hasReachedMax) {
      child = const Text("You've reached the end 🎬");
    } else if (isLoading) {
      child = const CircularProgressIndicator();
    } else {
      child = const SizedBox(height: 36);
    }
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Center(child: child),
      ),
    );
  }
}
