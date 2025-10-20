import 'package:totem_pro_admin/core/enums/store_access.dart';
import 'package:totem_pro_admin/models/store/store_with_role.dart';
import 'package:flutter/material.dart';
/// ✅ Serviço IMUTÁVEL para verificação de permissões
class PermissionService {
  // ✅ PRIVATE: Não pode ser instanciado diretamente
  const PermissionService._();

  /// ✅ Verifica se o usuário tem uma role específica na loja ativa
  static bool hasRole(StoreWithRole? storeWithRole, StoreAccessRole requiredRole) {
    if (storeWithRole == null) return false;
    return storeWithRole.role == requiredRole;
  }

  /// ✅ Verifica se o usuário tem qualquer uma das roles especificadas
  static bool hasAnyRole(StoreWithRole? storeWithRole, List<StoreAccessRole> allowedRoles) {
    if (storeWithRole == null) return false;
    return allowedRoles.contains(storeWithRole.role);
  }

  /// ✅ Verifica se o usuário é OWNER
  static bool isOwner(StoreWithRole? storeWithRole) {
    return hasRole(storeWithRole, StoreAccessRole.owner);
  }

  /// ✅ Verifica se o usuário é OWNER ou MANAGER
  static bool canManageStore(StoreWithRole? storeWithRole) {
    return hasAnyRole(storeWithRole, [
      StoreAccessRole.owner,
      StoreAccessRole.manager,
    ]);
  }

  /// ✅ Verifica se pode criar produtos
  static bool canManageProducts(StoreWithRole? storeWithRole) {
    return hasAnyRole(storeWithRole, [
      StoreAccessRole.owner,
      StoreAccessRole.manager,
    ]);
  }

  /// ✅ Verifica se pode gerenciar usuários
  static bool canManageUsers(StoreWithRole? storeWithRole) {
    return isOwner(storeWithRole); // ✅ Somente OWNER
  }

  /// ✅ Verifica se pode trocar de loja
  static bool canSwitchStores(List<StoreWithRole> stores) {
    return stores.length > 1; // ✅ Só se tiver mais de uma loja
  }

  /// ✅ Verifica se pode criar nova loja
  static bool canCreateStore(List<StoreWithRole> stores) {
    // ✅ Só pode criar se for OWNER em pelo menos UMA loja
    return stores.any((store) => store.role == StoreAccessRole.owner);
  }

  /// ✅ Verifica se pode editar configurações da loja
  static bool canEditStoreSettings(StoreWithRole? storeWithRole) {
    return hasAnyRole(storeWithRole, [
      StoreAccessRole.owner,
      StoreAccessRole.manager,
    ]);
  }

  /// ✅ Verifica se pode ver relatórios financeiros
  static bool canViewFinancials(StoreWithRole? storeWithRole) {
    return hasAnyRole(storeWithRole, [
      StoreAccessRole.owner,
      StoreAccessRole.manager,
      StoreAccessRole.cashier,
    ]);
  }

  /// ✅ Verifica se pode gerenciar estoque
  static bool canManageInventory(StoreWithRole? storeWithRole) {
    return hasAnyRole(storeWithRole, [
      StoreAccessRole.owner,
      StoreAccessRole.manager,
      StoreAccessRole.stockManager,
    ]);
  }

  /// ✅ Verifica se pode aceitar pedidos
  static bool canManageOrders(StoreWithRole? storeWithRole) {
    return hasAnyRole(storeWithRole, [
      StoreAccessRole.owner,
      StoreAccessRole.manager,
      StoreAccessRole.cashier,
      StoreAccessRole.waiter,
    ]);
  }

  /// ✅ Hierarquia de roles (para futuras validações)
  static const Map<StoreAccessRole, int> _roleHierarchy = {
    StoreAccessRole.owner: 5,
    StoreAccessRole.manager: 4,
    StoreAccessRole.cashier: 3,
    StoreAccessRole.stockManager: 2,
    StoreAccessRole.waiter: 1,
  };

  /// ✅ Verifica se uma role é superior a outra
  static bool isRoleHigherThan(StoreAccessRole role, StoreAccessRole comparedTo) {
    final roleLevel = _roleHierarchy[role] ?? 0;
    final comparedLevel = _roleHierarchy[comparedTo] ?? 0;
    return roleLevel > comparedLevel;
  }

  /// ✅ Retorna texto descritivo da role
  static String getRoleDescription(StoreAccessRole role) {
    switch (role) {
      case StoreAccessRole.owner:
        return 'Controle total da loja';
      case StoreAccessRole.manager:
        return 'Gerenciar operações e equipe';
      case StoreAccessRole.cashier:
        return 'Processar pedidos e pagamentos';
      case StoreAccessRole.waiter:
        return 'Atender mesas e pedidos';
      case StoreAccessRole.stockManager:
        return 'Gerenciar estoque';
      default:
        return 'Acesso limitado';
    }
  }

  /// ✅ Retorna ícone da role
  static IconData getRoleIcon(StoreAccessRole role) {
    switch (role) {
      case StoreAccessRole.owner:
        return Icons.workspace_premium;
      case StoreAccessRole.manager:
        return Icons.admin_panel_settings;
      case StoreAccessRole.cashier:
        return Icons.point_of_sale;
      case StoreAccessRole.waiter:
        return Icons.room_service;
      case StoreAccessRole.stockManager:
        return Icons.inventory;
      default:
        return Icons.person;
    }
  }

  /// ✅ Retorna cor da role
  static Color getRoleColor(StoreAccessRole role) {
    switch (role) {
      case StoreAccessRole.owner:
        return Colors.purple;
      case StoreAccessRole.manager:
        return Colors.blue;
      case StoreAccessRole.cashier:
        return Colors.green;
      case StoreAccessRole.waiter:
        return Colors.orange;
      case StoreAccessRole.stockManager:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}