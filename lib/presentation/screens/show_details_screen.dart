import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/show_details/show_details_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/text_utils.dart';
import '../../data/models/cast_member.dart';
import '../../data/models/episode.dart';
import '../../data/models/show.dart';
import '../../data/repositories/show_repository.dart';
import '../widgets/app_network_image.dart';
import '../widgets/genre_chip.dart';
import '../widgets/state_views.dart';
import '../widgets/watchlist_button.dart';

class ShowDetailsScreen extends StatelessWidget {
  const ShowDetailsScreen({super.key});

  static void open(BuildContext context, Show show) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (ctx) => ShowDetailsBloc(
          repository: ctx.read<ShowRepository>(),
          showId: show.id,
          initialShow: show,
        )..add(const ShowDetailsStarted()),
        child: const ShowDetailsScreen(),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ShowDetailsBloc, ShowDetailsState>(
        buildWhen: (p, c) => p.show != c.show || p.infoStatus != c.infoStatus,
        builder: (context, state) {
          final show = state.show;
          if (show == null) {
            if (state.infoStatus == LoadStatus.failure) {
              return Scaffold(
                appBar: AppBar(),
                body: ErrorView(
                  message: state.infoError ?? 'Could not load show.',
                  onRetry: () => context.read<ShowDetailsBloc>().add(const ShowInfoRequested()),
                ),
              );
            }
            return const LoadingView();
          }
          return DefaultTabController(
            length: 3,
            child: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: _DetailsAppBar(show: show),
                ),
              ],
              body: const TabBarView(
                children: [_OverviewTab(), _EpisodesTab(), _CastTab()],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailsAppBar extends StatelessWidget {
  const _DetailsAppBar({required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 420,
      backgroundColor: AppColors.background,
      leading: const _CircleButton(child: BackButton()),
      actions: [_CircleButton(child: WatchlistIconButton(show: show)), const SizedBox(width: 8)],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(start: 60, end: 60, bottom: 16 + kTextTabBarHeight),
        title: Text(
          show.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            AppNetworkImage(url: show.backdropUrl, placeholderIcon: Icons.live_tv_rounded),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.3, 0.78, 1.0],
                  colors: [Color(0x99000000), Colors.transparent, Color(0xE60F0E17), AppColors.background],
                ),
              ),
            ),
          ],
        ),
      ),
      bottom: const TabBar(
        tabs: [Tab(text: 'Overview'), Tab(text: 'Episodes'), Tab(text: 'Cast')],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: child,
      ),
    );
  }
}

class _TabScrollView extends StatelessWidget {
  const _TabScrollView({required this.storageKey, required this.slivers});

  final String storageKey;
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: PageStorageKey(storageKey),
      slivers: [
        SliverOverlapInjector(handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context)),
        ...slivers,
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShowDetailsBloc, ShowDetailsState>(
      buildWhen: (p, c) =>
          p.show != c.show || p.infoStatus != c.infoStatus || p.seasons.length != c.seasons.length,
      builder: (context, state) {
        final show = state.show!;
        final seasons = state.seasons.where((s) => s > 0).length;
        final meta = [
          show.yearRange,
          if (seasons > 0) '$seasons Season${seasons == 1 ? '' : 's'}',
        ].join('  ·  ');

        return _TabScrollView(
          storageKey: 'overview',
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.list(
                children: [
                  if (state.infoStatus == LoadStatus.loading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                  if (state.infoStatus == LoadStatus.failure)
                    _InlineError(
                      message: state.infoError!,
                      onRetry: () => context.read<ShowDetailsBloc>().add(const ShowInfoRequested()),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(meta, style: const TextStyle(color: AppColors.textSecondary)),
                      ),
                      const Icon(Icons.star_rounded, color: AppColors.rating, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        show.rating == null ? 'No rating' : '${show.rating!.toStringAsFixed(1)}/10',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (show.genres.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [for (final g in show.genres) GenreChip(label: g)],
                    ),
                  const SizedBox(height: 16),
                  _ExpandableText(text: show.summary ?? 'No summary available for this show.'),
                  const SizedBox(height: 20),
                  WatchlistActionButton(show: show),
                  const SizedBox(height: 24),
                  const Text('Quick Info', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _QuickInfo(show: show),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ExpandableText extends StatefulWidget {
  const _ExpandableText({required this.text});

  final String text;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final long = widget.text.length > 220;
    return GestureDetector(
      onTap: long ? () => setState(() => _expanded = !_expanded) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            maxLines: _expanded ? null : 5,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(height: 1.5, color: Color(0xFFD6D3E8)),
          ),
          if (long)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_expanded ? 'Show less' : 'Read more',
                  style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

class _QuickInfo extends StatelessWidget {
  const _QuickInfo({required this.show});

  final Show show;

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      (Icons.circle_outlined, 'Status', show.status ?? 'Unknown'),
      (Icons.tv_rounded, 'Network', show.network ?? 'Unknown'),
      (Icons.category_outlined, 'Genres', show.genres.isEmpty ? 'N/A' : show.genres.join(', ')),
      (Icons.language_rounded, 'Language', show.language ?? 'Unknown'),
      (Icons.schedule_rounded, 'Runtime', show.runtime == null ? 'Unknown' : '${show.runtime} min'),
      (Icons.event_rounded, 'Premiered', show.premiered ?? 'Unknown'),
      if (show.type != null) (Icons.movie_filter_outlined, 'Type', show.type!),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(rows[i].$1, size: 18, color: AppColors.primaryLight),
                  const SizedBox(width: 12),
                  Text(rows[i].$2, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(rows[i].$3,
                        textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(child: Text('Could not refresh details. $message', style: const TextStyle(fontSize: 12))),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EpisodesTab extends StatelessWidget {
  const _EpisodesTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShowDetailsBloc, ShowDetailsState>(
      buildWhen: (p, c) =>
          p.episodesStatus != c.episodesStatus ||
          p.episodesBySeason != c.episodesBySeason ||
          p.selectedSeason != c.selectedSeason,
      builder: (context, state) {
        final Widget body = switch (state.episodesStatus) {
          LoadStatus.initial || LoadStatus.loading => const LoadingView(),
          LoadStatus.failure => ErrorView(
              compact: true,
              message: state.episodesError ?? 'Could not load episodes.',
              onRetry: () => context.read<ShowDetailsBloc>().add(const ShowEpisodesRequested()),
            ),
          LoadStatus.empty => const EmptyView(
              icon: Icons.video_library_outlined,
              title: 'No episodes yet',
              message: 'Episodes for this show are not available.',
            ),
          LoadStatus.success => const SizedBox.shrink(),
        };

        if (state.episodesStatus != LoadStatus.success) {
          return _TabScrollView(
            storageKey: 'episodes',
            slivers: [SliverFillRemaining(hasScrollBody: false, child: body)],
          );
        }

        final episodes = state.selectedEpisodes;
        return _TabScrollView(
          storageKey: 'episodes',
          slivers: [
            SliverToBoxAdapter(child: _SeasonDropdown(state: state)),
            SliverList.separated(
              itemCount: episodes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, i) => _EpisodeTile(episode: episodes[i]),
            ),
          ],
        );
      },
    );
  }
}

class _SeasonDropdown extends StatelessWidget {
  const _SeasonDropdown({required this.state});

  final ShowDetailsState state;

  String _label(int season) {
    final count = state.episodesBySeason[season]?.length ?? 0;
    final name = season == 0 ? 'Specials' : 'Season $season';
    return '$name ($count episode${count == 1 ? '' : 's'})';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,
            value: state.selectedSeason,
            dropdownColor: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            items: [
              for (final s in state.seasons) DropdownMenuItem(value: s, child: Text(_label(s))),
            ],
            onChanged: (s) {
              if (s != null) context.read<ShowDetailsBloc>().add(SeasonSelected(s));
            },
          ),
        ),
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  const _EpisodeTile({required this.episode});

  final Episode episode;

  void _showSummary(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (episode.imageMedium != null) ...[
                AppNetworkImage(
                  url: episode.imageMedium,
                  height: 180,
                  width: double.infinity,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'S${episode.season}${episode.number == null ? ' · Special' : ' E${episode.number}'}',
                style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(episode.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                [
                  TextUtils.formatDate(episode.airdate),
                  if (episode.runtime != null) '${episode.runtime} min',
                  if (episode.rating != null) '★ ${episode.rating!.toStringAsFixed(1)}',
                ].join('  ·  '),
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              Text(episode.summary ?? 'No summary available.', style: const TextStyle(height: 1.5)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showSummary(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Stack(
              children: [
                AppNetworkImage(
                  url: episode.imageMedium,
                  width: 110,
                  height: 62,
                  borderRadius: BorderRadius.circular(8),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(episode.number?.toString() ?? 'SP',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(episode.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(TextUtils.formatDate(episode.airdate),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _CastTab extends StatelessWidget {
  const _CastTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShowDetailsBloc, ShowDetailsState>(
      buildWhen: (p, c) => p.castStatus != c.castStatus || p.cast != c.cast,
      builder: (context, state) {
        if (state.castStatus != LoadStatus.success) {
          final Widget body = switch (state.castStatus) {
            LoadStatus.failure => ErrorView(
                compact: true,
                message: state.castError ?? 'Could not load cast.',
                onRetry: () => context.read<ShowDetailsBloc>().add(const ShowCastRequested()),
              ),
            LoadStatus.empty => const EmptyView(
                icon: Icons.people_outline,
                title: 'No cast information',
                message: 'Cast details are not available for this show.',
              ),
            _ => const LoadingView(),
          };
          return _TabScrollView(
            storageKey: 'cast',
            slivers: [SliverFillRemaining(hasScrollBody: false, child: body)],
          );
        }
        return _TabScrollView(
          storageKey: 'cast',
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverList.separated(
              itemCount: state.cast.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 84, endIndent: 16),
              itemBuilder: (context, i) => _CastTile(member: state.cast[i]),
            ),
          ],
        );
      },
    );
  }
}

class _CastTile extends StatelessWidget {
  const _CastTile({required this.member});

  final CastMember member;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: AppNetworkImage(
        url: member.imageUrl,
        width: 54,
        height: 54,
        borderRadius: BorderRadius.circular(27),
        placeholderIcon: Icons.person,
      ),
      title: Text(member.personName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(member.characterName, style: const TextStyle(color: AppColors.textSecondary)),
    );
  }
}
