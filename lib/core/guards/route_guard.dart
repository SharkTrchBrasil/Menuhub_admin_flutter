import 'package:go_router/go_router.dart';

abstract interface class RouteGuard {

  String? call(GoRouterState state);

  static String? apply(GoRouterState state, List<RouteGuard> guards) {
    for (final guard in guards) {
      final redirect = guard(state);
      if(redirect != null) {
        return redirect;
      }
    }
    return null;
  }

}