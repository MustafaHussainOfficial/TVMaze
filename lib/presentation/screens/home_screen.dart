import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/navigation/navigation_cubit.dart';
import '../../bloc/shows/shows_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/show.dart';
import '../widgets/section_header.dart';
import '../widgets/show_grid.dart';
import '../widgets/show_poster_card.dart';
import '../widgets/state_views.dart';
import 'show_collection_screen.dart';
import 'show_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bloc = context.read<ShowsBloc>();
    if (_scrollController.position.extentAfter < 800 &&
        bloc.state.status != ShowsStatus.failure &&
        !bloc.state.hasReachedMax) {
      bloc.add(const ShowsFetched());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<ShowsBloc, ShowsState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<ShowsBloc>()..add(const ShowsRefreshed());
              await bloc.stream.firstWhere((s) => s.status != ShowsStatus.loading);
            },
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: _Header()),
                ..._buildContent(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context, ShowsState state) {
    if (state.isFirstLoad) {
      return const [SliverFillRemaining(hasScrollBody: false, child: LoadingView(message: 'Loading shows...'))];
    }
    if (state.shows.isEmpty && state.status == ShowsStatus.failure) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorView(
            message: state.errorMessage ?? 'Could not load shows.',
            onRetry: () => context.read<ShowsBloc>().add(const ShowsFetched()),
          ),
        ),
      ];
    }
    if (state.shows.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyView(icon: Icons.tv_off_outlined, title: 'No shows available'),
        ),
      ];
    }

    return [
      SliverToBoxAdapter(
        child: SectionHeader(
          title: 'Trending Now',
          onSeeAll: () => ShowCollectionScreen.open(context, 'Top Rated', (s) => s.topRated),
        ),
      ),
      SliverToBoxAdapter(child: _Carousel(shows: state.trending)),
      SliverToBoxAdapter(
        child: SectionHeader(
          title: 'Popular Shows',
          onSeeAll: () => ShowCollectionScreen.open(context, 'Popular Shows', (s) => s.mostPopular),
        ),
      ),
      SliverToBoxAdapter(child: _Carousel(shows: state.popular)),
      const SliverToBoxAdapter(child: SectionHeader(title: 'All Shows')),
      ShowSliverGrid(shows: state.shows),
      PaginationFooter(
        isLoading: state.isLoadingMore,
        hasReachedMax: state.hasReachedMax,
        errorMessage: state.status == ShowsStatus.failure ? state.errorMessage : null,
        onRetry: () => context.read<ShowsBloc>().add(const ShowsFetched()),
      ),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final nav = context.read<NavigationCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello,', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                    SizedBox(height: 2),
                    Text('TV Explorer! 👋', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => nav.select(AppTab.profile),
                icon: const Icon(Icons.settings_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => nav.select(AppTab.search),
            child: AbsorbPointer(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search shows...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Carousel extends StatelessWidget {
  const _Carousel({required this.shows});

  final List<Show> shows;

  @override
  Widget build(BuildContext context) {
    if (shows.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Nothing to show yet', style: TextStyle(color: AppColors.textSecondary)),
      );
    }
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: shows.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => ShowPosterCard(
          width: 125,
          show: shows[index],
          onTap: () => ShowDetailsScreen.open(context, shows[index]),
        ),
      ),
    );
  }
}
