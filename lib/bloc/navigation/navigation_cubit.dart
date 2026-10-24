import 'package:flutter_bloc/flutter_bloc.dart';

enum AppTab { home, search, watchlist, profile }

class NavigationCubit extends Cubit<AppTab> {
  NavigationCubit() : super(AppTab.home);

  void select(AppTab tab) => emit(tab);
}
