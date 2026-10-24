import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/navigation/navigation_cubit.dart';
import '../../bloc/search/search_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/person.dart';
import '../widgets/app_network_image.dart';
import '../widgets/show_list_tile.dart';
import '../widgets/state_views.dart';
import 'show_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    final bloc = context.read<SearchBloc>();
    bloc.add(const SearchQueryChanged(''));
    bloc.add(const SearchCleared());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationCubit, AppTab>(
      listener: (context, tab) {
        if (tab == AppTab.search) {
          _focusNode.requestFocus();
        } else {
          _focusNode.unfocus();
        }
      },
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  setState(() {});
                  context.read<SearchBloc>().add(SearchQueryChanged(value));
                },
                decoration: InputDecoration(
                  hintText: 'Search shows or people...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isEmpty
                      ? null
                      : IconButton(icon: const Icon(Icons.cancel), onPressed: _clear),
                ),
              ),
            ),
            const _TypeSelector(),
            const SizedBox(height: 8),
            const Expanded(child: _SearchResults()),
          ],
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector();

  @override
  Widget build(BuildContext context) {
    final type = context.select((SearchBloc b) => b.state.type);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            for (final t in SearchType.values)
              Expanded(
                child: GestureDetector(
                  onTap: () => context.read<SearchBloc>().add(SearchTypeChanged(t)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: t == type ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      t == SearchType.shows ? 'Shows' : 'People',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: t == type ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        switch (state.status) {
          case SearchStatus.initial:
            return EmptyView(
              icon: Icons.manage_search_rounded,
              title: state.type == SearchType.shows ? 'Find your favorite shows' : 'Find actors & creators',
              message: 'Start typing to search the TVMaze database.',
            );
          case SearchStatus.loading:
            return const LoadingView();
          case SearchStatus.empty:
            return EmptyView(
              icon: Icons.search_off_rounded,
              title: 'No results found',
              message: 'We could not find anything matching "${state.query}".\nTry a different name.',
            );
          case SearchStatus.failure:
            return ErrorView(
              message: state.errorMessage ?? 'Search failed.',
              onRetry: () => context.read<SearchBloc>().add(const SearchRetried()),
            );
          case SearchStatus.success:
            if (state.type == SearchType.shows) {
              return ListView.separated(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: state.shows.length,
                separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, i) => ShowListTile(
                  show: state.shows[i],
                  onTap: () => ShowDetailsScreen.open(context, state.shows[i]),
                ),
              );
            }
            return ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: state.people.length,
              separatorBuilder: (_, _) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, i) => _PersonTile(person: state.people[i]),
            );
        }
      },
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final details = [
      if (person.country != null) person.country!,
      if (person.birthday != null) 'Born ${person.birthday}',
    ].join(' · ');
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: AppNetworkImage(
        url: person.imageMedium,
        width: 52,
        height: 52,
        borderRadius: BorderRadius.circular(26),
        placeholderIcon: Icons.person,
      ),
      title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(details.isEmpty ? 'No details available' : details,
          style: const TextStyle(color: AppColors.textSecondary)),
    );
  }
}
