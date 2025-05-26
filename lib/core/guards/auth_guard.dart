import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/guards/route_guard.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';

class AuthGuard implements RouteGuard {

  AuthGuard({this.invert = false});

  final bool invert;

  @override
  String? call(GoRouterState state) {
    final AuthRepository authRepository = getIt();
    if (authRepository.authTokens == null && !invert) {
      return '/sign-in?redirectTo=${state.matchedLocation}';
    } else if (authRepository.authTokens != null && invert) {
      return '/stores';
    }
    return null;
  }
}