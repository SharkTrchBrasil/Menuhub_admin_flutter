import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/guards/route_guard.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';

class StoreOwnerGuard implements RouteGuard {
  @override
  String? call(GoRouterState state) {
    final storeId = int.tryParse(state.pathParameters['storeId']!)!;
    final store = getIt<StoreRepository>()
        .stores
        .firstWhere((s) => s.store.id == storeId);
    if (store.role != StoreAccessRole.owner) {
      return '/stores/${store.store.id}/products';
    }
    return null;
  }
}