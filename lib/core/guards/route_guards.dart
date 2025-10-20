import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/core/enums/store_access.dart';
import 'package:totem_pro_admin/services/permission_service.dart';
import 'package:totem_pro_admin/models/store/store_with_role.dart';

/// ✅ Classe base para guards de rota
abstract class RouteGuard {
  /// Verifica se o usuário tem permissão para acessar a rota
  /// Retorna null se permitido, ou uma rota de redirecionamento se bloqueado
  String? canActivate(BuildContext context, GoRouterState state);

  /// Mensagem de erro personalizada (opcional)
  String get deniedMessage => 'Você não tem permissão para acessar esta página.';
}

/// ✅ Guard que verifica se o usuário está autenticado
class AuthGuard extends RouteGuard {
  @override
  String? canActivate(BuildContext context, GoRouterState state) {
    // Implementado no redirect principal do router
    return null;
  }
}

/// ✅ Guard que verifica se o usuário tem uma role específica
class RoleGuard extends RouteGuard {
  final List<StoreAccessRole> allowedRoles;
  final String redirectTo;

  RoleGuard({
    required this.allowedRoles,
    this.redirectTo = '/hub',
  });

  @override
  String? canActivate(BuildContext context, GoRouterState state) {
    if (!getIt.isRegistered<StoresManagerCubit>()) {
      return '/splash';
    }

    final storesState = getIt<StoresManagerCubit>().state;

    if (storesState is! StoresManagerLoaded) {
      return '/splash';
    }

    final activeStore = storesState.activeStoreWithRole;

    if (activeStore == null) {
      return '/select-store';
    }

    // ✅ VALIDAÇÃO PRINCIPAL: Verifica se a role está permitida
    final hasPermission = PermissionService.hasAnyRole(activeStore, allowedRoles);

    if (!hasPermission) {
      // ✅ SEGURANÇA: Mostra mensagem e redireciona
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAccessDeniedMessage(context, activeStore);
      });
      return redirectTo;
    }

    return null; // ✅ Permitido
  }

  void _showAccessDeniedMessage(BuildContext context, StoreWithRole activeStore) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.block, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Acesso Negado',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Esta funcionalidade requer uma das seguintes funções: ${allowedRoles.map((r) => r.title).join(", ")}.\n'
                      'Sua função atual: ${activeStore.role.title}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red.shade700,
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  String get deniedMessage =>
      'Você precisa ser ${allowedRoles.map((r) => r.title).join(" ou ")} para acessar esta página.';
}

/// ✅ Guard específico para OWNER
class OwnerGuard extends RoleGuard {
  OwnerGuard({String redirectTo = '/hub'})
      : super(
    allowedRoles: [StoreAccessRole.owner],
    redirectTo: redirectTo,
  );

  @override
  String get deniedMessage => 'Apenas o proprietário da loja pode acessar esta página.';
}

/// ✅ Guard para OWNER ou MANAGER
class ManagerGuard extends RoleGuard {
  ManagerGuard({String redirectTo = '/hub'})
      : super(
    allowedRoles: [
      StoreAccessRole.owner,
      StoreAccessRole.manager,
    ],
    redirectTo: redirectTo,
  );

  @override
  String get deniedMessage => 'Apenas proprietários e gerentes podem acessar esta página.';
}

/// ✅ Guard que verifica se o usuário pode criar lojas
class CanCreateStoreGuard extends RouteGuard {
  @override
  String? canActivate(BuildContext context, GoRouterState state) {
    if (!getIt.isRegistered<StoresManagerCubit>()) {
      return '/splash';
    }

    final storesState = getIt<StoresManagerCubit>().state;

    if (storesState is! StoresManagerLoaded) {
      return '/splash';
    }

    // ✅ Verifica se tem pelo menos uma loja como OWNER
    final canCreate = PermissionService.canCreateStore(
      storesState.stores.values.toList(),
    );

    if (!canCreate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Você precisa ser proprietário de pelo menos uma loja para criar novas lojas.',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 4),
          ),
        );
      });
      return '/hub';
    }

    return null;
  }

  @override
  String get deniedMessage =>
      'Você precisa ser proprietário de pelo menos uma loja para criar novas.';
}

/// ✅ Guard que verifica múltiplas lojas (para trocar de loja)
class MultiStoreGuard extends RouteGuard {
  @override
  String? canActivate(BuildContext context, GoRouterState state) {
    if (!getIt.isRegistered<StoresManagerCubit>()) {
      return '/splash';
    }

    final storesState = getIt<StoresManagerCubit>().state;

    if (storesState is! StoresManagerLoaded) {
      return '/splash';
    }

    // ✅ Só permite se tiver mais de uma loja
    if (storesState.stores.length <= 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você tem acesso a apenas uma loja.'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 3),
          ),
        );
      });
      return '/hub';
    }

    return null;
  }
}

/// ✅ Função helper para aplicar guards a uma rota
String? applyGuards(
    BuildContext context,
    GoRouterState state,
    List<RouteGuard> guards,
    ) {
  for (final guard in guards) {
    final result = guard.canActivate(context, state);
    if (result != null) {
      return result; // ✅ Bloqueia e redireciona
    }
  }
  return null; // ✅ Todos os guards passaram
}