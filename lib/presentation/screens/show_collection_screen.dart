import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/shows/shows_bloc.dart';
import '../../data/models/show.dart';
import '../widgets/show_grid.dart';
import '../widgets/state_views.dart';

class ShowCollectionScreen extends StatefulWidget {
  const ShowCollectionScreen({super.key, required this.title, required this.selector});

  final String title;
  final List<Show> Function(ShowsState state) selector;

  static void open(BuildContext context, String title, List<Show> Function(ShowsState) selector) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ShowCollectionScreen(title: title, selector: selector),
    ));
  }

  @override
  State<ShowCollectionScreen> createState() => _ShowCollectionScreenState();
}

class _ShowCollectionScreenState extends State<ShowCollectionScreen> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final bloc = context.read<ShowsBloc>();
      if (_controller.position.extentAfter < 600 &&
          bloc.state.status != ShowsStatus.failure &&
          !bloc.state.hasReachedMax) {
        bloc.add(const ShowsFetched());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: BlocBuilder<ShowsBloc, ShowsState>(
        builder: (context, state) {
          final shows = widget.selector(state);
          if (shows.isEmpty) {
            return const EmptyView(icon: Icons.tv_off_outlined, title: 'No shows yet');
          }
          return CustomScrollView(
            controller: _controller,
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              ShowSliverGrid(shows: shows),
              PaginationFooter(
                isLoading: state.isLoadingMore,
                hasReachedMax: state.hasReachedMax,
                errorMessage: state.status == ShowsStatus.failure ? state.errorMessage : null,
                onRetry: () => context.read<ShowsBloc>().add(const ShowsFetched()),
              ),
            ],
          );
        },
      ),
    );
  }
}
