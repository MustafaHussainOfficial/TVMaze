import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('[${bloc.runtimeType}] event: ${event.runtimeType}');
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    final next = change.nextState;
    final status = _statusOf(next);
    debugPrint('[${bloc.runtimeType}] state: ${next.runtimeType}${status == null ? '' : ' ($status)'}');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    debugPrint('[${bloc.runtimeType}] error: $error');
    super.onError(bloc, error, stackTrace);
  }

  String? _statusOf(Object? state) {
    try {
      return (state as dynamic).status.toString();
    } catch (_) {
      return null;
    }
  }
}
