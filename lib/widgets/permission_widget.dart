import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/core/enums/store_access.dart';
import 'package:totem_pro_admin/services/permission_service.dart';

import '../models/store/store_with_role.dart';

/// ✅ Widget que mostra/oculta baseado em permissão
class PermissionGuard extends StatelessWidget {
  final Widget child;
  final bool Function(StoreWithRole?) hasPermission;
  final Widget? fallback;

  const PermissionGuard({
    super.key,
    required this.child,
    required this.hasPermission,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          return fallback ?? const SizedBox.shrink();
        }

        final activeStore = state.activeStoreWithRole;

        // ✅ SEGURANÇA: Verifica permissão de forma IMUTÁVEL
        if (hasPermission(activeStore)) {
          return child;
        }

        return fallback ?? const SizedBox.shrink();
      },
    );
  }
}

/// ✅ Widget específico para OWNER
class OwnerOnly extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const OwnerOnly({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      hasPermission: PermissionService.isOwner,
      fallback: fallback,
      child: child,
    );
  }
}

/// ✅ Widget para OWNER ou MANAGER
class ManagerOrAbove extends StatelessWidget {
  final Widget child;
  final Widget? fallback;

  const ManagerOrAbove({
    super.key,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionGuard(
      hasPermission: PermissionService.canManageStore,
      fallback: fallback,
      child: child,
    );
  }
}

/// ✅ Badge de role do usuário
class RoleBadge extends StatelessWidget {
  final StoreAccessRole role;
  final bool showDescription;

  const RoleBadge({
    super.key,
    required this.role,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: PermissionService.getRoleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PermissionService.getRoleColor(role).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            PermissionService.getRoleIcon(role),
            size: 16,
            color: PermissionService.getRoleColor(role),
          ),
          const SizedBox(width: 6),
          Text(
            role.title,
            style: TextStyle(
              color: PermissionService.getRoleColor(role),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showDescription) ...[
            const SizedBox(width: 4),
            Tooltip(
              message: PermissionService.getRoleDescription(role),
              child: Icon(
                Icons.info_outline,
                size: 14,
                color: PermissionService.getRoleColor(role),
              ),
            ),
          ],
        ],
      ),
    );
  }
}