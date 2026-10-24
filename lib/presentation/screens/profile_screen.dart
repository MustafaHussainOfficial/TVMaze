import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/navigation/navigation_cubit.dart';
import '../../bloc/shows/shows_bloc.dart';
import '../../bloc/watchlist/watchlist_bloc.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final watchlistCount = context.select((WatchlistBloc b) => b.state.shows.length);
    final loadedCount = context.select((ShowsBloc b) => b.state.shows.length);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          const Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text('TV Explorer', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _StatCard(
                label: 'In Watchlist',
                value: '$watchlistCount',
                icon: Icons.favorite,
                onTap: () => context.read<NavigationCubit>().select(AppTab.watchlist),
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Shows Loaded',
                value: '$loadedCount',
                icon: Icons.live_tv_rounded,
                onTap: () => context.read<NavigationCubit>().select(AppTab.home),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: AppColors.primaryLight),
                  title: Text('About'),
                  subtitle: Text('Discover. Explore. Save.'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.cloud_outlined, color: AppColors.primaryLight),
                  title: Text('Data source'),
                  subtitle: Text('TVMaze public API · api.tvmaze.com'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.storage_outlined, color: AppColors.primaryLight),
                  title: Text('Storage'),
                  subtitle: Text('Watchlist is saved locally on this device'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.code, color: AppColors.primaryLight),
                  title: Text('Version'),
                  subtitle: Text('1.0.0 · Flutter + BLoC'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.onTap});

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primaryLight),
              const SizedBox(height: 12),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
              Text(label, style: const TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
