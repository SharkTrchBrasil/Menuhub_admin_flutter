// widgets/drawercode.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:totem_pro_admin/widgets/permission_widget.dart';

import '../core/helpers/sidepanel.dart';
import '../core/provider/drawer_provider.dart';
import '../core/enums/store_access.dart'; // ✅ ADICIONAR
import '../cubits/auth_cubit.dart';
import '../cubits/store_manager_cubit.dart';
import '../cubits/store_manager_state.dart';
import '../models/store/store.dart';
import '../services/permission_service.dart'; // ✅ ADICIONAR

import 'store_switcher_panel.dart';

class DrawerCode extends StatefulWidget {
  final int storeId;

  const DrawerCode({super.key, required this.storeId});

  @override
  State<DrawerCode> createState() => _DrawerCodeState();
}

class _DrawerCodeState extends State<DrawerCode> {
  final double _collapsedWidth = 72.0;
  final double _expandedWidth = 260.0;
  bool _isLoggingOut = false;

  void _openStoreSwitcherPanel(BuildContext context) {
    final storesManagerCubit = context.read<StoresManagerCubit>();

    showResponsiveSidePanel(
      context,
      StoreSwitcherPanel(
        storesManagerCubit: storesManagerCubit,
        isInSidePanel: true,
      ),
      useHalfScreenOnDesktop: true,
    );
  }

  /// ✅ Pega a rota atual do GoRouter
  String _getCurrentRoute(BuildContext context) {
    return GoRouterState.of(context).uri.path;
  }

  /// ✅ Verifica se a rota está ativa
  bool _isRouteActive(BuildContext context, String menuRoute) {
    final currentPath = _getCurrentRoute(context);
    final fullRoute = '/stores/${widget.storeId}$menuRoute';

    return currentPath == fullRoute || currentPath.startsWith('$fullRoute/');
  }

  /// ✅ Navega e fecha o drawer
  void _navigateAndCloseDrawer(BuildContext context, String route) {
    if (Scaffold.of(context).isDrawerOpen) {
      Navigator.of(context).pop();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      context.go(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    final drawerProvider = context.watch<DrawerProvider>();
    final bool isExpanded = drawerProvider.isExpanded;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, storesState) {
        if (storesState is! StoresManagerLoaded) {
          return const Drawer(
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final activeStore = storesState.activeStore;
        if (activeStore == null) {
          return const Drawer(
            child: Center(child: Text('Erro: Loja não encontrada.')),
          );
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isExpanded ? _expandedWidth : _collapsedWidth,
          child: Drawer(
            backgroundColor: Colors.white,
            child: Column(
              children: [
                SizedBox(height: isMobile ? 16 : 0),

                // ✅ HEADER DA LOJA
                _buildStoreHeader(
                  context,
                  isExpanded,
                  activeStore,
                  drawerProvider,
                ),

                // ✅ MENU PRINCIPAL
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ AGORA PASSA activeStore PARA VALIDAR PERMISSÕES
                        ..._buildMenuItemsFromData(
                          context: context,
                          isExpanded: isExpanded,
                          activeStore: storesState.activeStoreWithRole,
                        ),

                        const SizedBox(height: 20),

                        // ✅ TROCAR DE LOJA - Só mostra se tiver múltiplas lojas
                        if (PermissionService.canSwitchStores(
                            storesState.stores.values.toList()))
                          _buildStoreSwitcherMenuItem(context, isExpanded),

                        const SizedBox(height: 8),

                        // ✅ LOGOUT
                        _buildLogoutButton(context, isExpanded),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoreHeader(
      BuildContext context,
      bool isExpanded,
      Store store,
      DrawerProvider drawerProvider,
      ) {
    final hasImage = store.media?.image?.url != null &&
        store.media!.image!.url!.isNotEmpty;

    return Padding(
      padding: isExpanded
          ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0)
          : const EdgeInsets.symmetric(vertical: 20.0),
      child: InkWell(
        onTap: () => drawerProvider.toggle(),
        borderRadius: BorderRadius.circular(12),
        child: isExpanded
            ? Container(
          constraints: BoxConstraints(
            maxWidth: _expandedWidth - 32,
          ),
          child: Row(
            children: [
              // Avatar da loja
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: hasImage
                      ? CachedNetworkImage(
                    imageUrl: store.media!.image!.url!,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) =>
                        _buildDefaultStoreIcon(context),
                  )
                      : _buildDefaultStoreIcon(context),
                ),
              ),
              const SizedBox(width: 12),

              // Nome e status da loja
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      store.core.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: store.core.isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        store.core.isActive ? 'Ativa' : 'Inativa',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: store.core.isActive
                              ? Colors.green
                              : Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),

              // Botão de toggle
              SizedBox(
                width: 24,
                child: IconButton(
                  onPressed: () => drawerProvider.toggle(),
                  icon: Icon(
                    Icons.menu,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        )
            : Column(
          children: [
            // Avatar compacto
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: ClipOval(
                child: hasImage
                    ? CachedNetworkImage(
                  imageUrl: store.media!.image!.url!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      _buildDefaultStoreIcon(context, size: 20),
                )
                    : _buildDefaultStoreIcon(context, size: 20),
              ),
            ),
            const SizedBox(height: 8),

            // Indicador de status
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: store.core.isActive ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultStoreIcon(BuildContext context, {double size = 24}) {
    return Icon(
      Icons.store_mall_directory_outlined,
      size: size,
      color: Theme.of(context).primaryColor,
    );
  }

  Widget _buildStoreSwitcherMenuItem(BuildContext context, bool isExpanded) {
    final Color defaultIconColor =
        Theme.of(context).listTileTheme.iconColor ??
            Theme.of(context).iconTheme.color ??
            Colors.grey;
    final Color defaultTextColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return InkWell(
      onTap: () {
        if (Scaffold.of(context).isDrawerOpen) {
          Navigator.of(context).pop();
        }
        Future.delayed(const Duration(milliseconds: 100), () {
          _openStoreSwitcherPanel(context);
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: isExpanded ? 48 : 55,
        width: isExpanded ? double.infinity : 60,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: isExpanded
            ? Row(
          children: [
            const SizedBox(width: 8),
            Icon(Icons.swap_horiz_rounded,
                size: 20, color: defaultIconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Trocar de Loja",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: defaultTextColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.swap_horiz_rounded,
                    size: 20, color: defaultIconColor),
              ),
              const SizedBox(height: 4),
              Text(
                "Trocar",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: defaultTextColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isExpanded) {
    return InkWell(
      onTap: _isLoggingOut ? null : () => _handleLogout(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: isExpanded ? 48 : 55,
        width: isExpanded ? double.infinity : 60,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: _isLoggingOut
            ? const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          ),
        )
            : isExpanded
            ? Row(
          children: [
            const SizedBox(width: 8),
            const Icon(
              Icons.logout_rounded,
              size: 20,
              color: Colors.red,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "Sair",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.red,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 4),
              if (!isExpanded)
                const Text(
                  "Sair",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.red,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final scaffoldState = Scaffold.of(context);

      if (scaffoldState.isDrawerOpen) {
        Navigator.of(context).pop();
      }

      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;
      final authCubit = context.read<AuthCubit>();

      await authCubit.logout();

      if (!mounted) return;

      context.go('/sign-in');
    } catch (e) {
      debugPrint('Erro durante logout: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao fazer logout. Tente novamente.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  // ✅ DADOS DO MENU COM PERMISSÕES
  List<Map<String, dynamic>> _getMenuData() {
    return [
      {'type': 'section', 'title': 'Dashboard', 'index': 0},
      {
        'type': 'item',
        'title': 'Inicio',
        'route': '/dashboard',
        'index': 0,
        'iconPath': 'assets/images/package.png',
        'roles': null, // ✅ Todos podem acessar
      },
      {
        'type': 'item',
        'title': 'Pedidos',
        'route': '/orders',
        'index': 1,
        'iconPath': 'assets/images/package.png',
        'roles': null, // ✅ Todos podem acessar
      },
      {
        'type': 'item',
        'title': 'Desempenho',
        'route': '/performance',
        'index': 2,
        'iconPath': 'assets/images/package.png',
        'roles': [StoreAccessRole.owner, StoreAccessRole.manager], // ✅ OWNER/MANAGER
      },
      {'type': 'spacer'},
      {
        'type': 'item',
        'title': 'Cardápios',
        'route': '/products',
        'index': 4,
        'iconPath': 'assets/images/package.png',
        'roles': [StoreAccessRole.owner, StoreAccessRole.manager], // ✅ OWNER/MANAGER
      },
      {
        'type': 'item',
        'title': 'Promoções',
        'route': '/coupons',
        'index': 5,
        'iconPath': 'assets/images/6.png',
        'roles': [StoreAccessRole.owner, StoreAccessRole.manager], // ✅ OWNER/MANAGER
      },
      {'type': 'spacer'},
      {'type': 'section', 'title': 'Configuração da Loja', 'index': 10},
      {
        'type': 'item',
        'title': 'Minha loja',
        'route': '/settings',
        'index': 9,
        'iconPath': 'assets/images/33.png',
        'roles': [StoreAccessRole.owner, StoreAccessRole.manager], // ✅ OWNER/MANAGER
      },
      {
        'type': 'item',
        'title': 'Horários',
        'route': '/settings/hours',
        'index': 10,
        'iconPath': 'assets/images/calendar-edit.png',
        'roles': [StoreAccessRole.owner, StoreAccessRole.manager], // ✅ OWNER/MANAGER
      },
      {
        'type': 'item',
        'title': 'Forma de Pagamento',
        'route': '/payment-methods',
        'index': 11,
        'iconPath': 'assets/images/coins.png',
        'roles': [StoreAccessRole.owner, StoreAccessRole.manager], // ✅ OWNER/MANAGER
      },
      {
        'type': 'item',
        'title': 'Configurações de Entrega',
        'route': '/settings/shipping',
        'index': 12,
        'iconPath': 'assets/images/box.png',
        'roles': [StoreAccessRole.owner, StoreAccessRole.manager], // ✅ OWNER/MANAGER
      },
      {
        'type': 'item',
        'title': 'Cidades e Bairros',
        'route': '/settings/locations',
        'index': 13,
        'iconPath': 'assets/images/location-pin.png',
        'roles': [StoreAccessRole.owner, StoreAccessRole.manager], // ✅ OWNER/MANAGER
      },
      {'type': 'spacer'},
      {'type': 'section', 'title': 'Estoque', 'index': 17},
      {
        'type': 'item',
        'title': 'Estoque',
        'route': '/inventory',
        'index': 15,
        'iconPath': 'assets/images/database.png',
        'roles': [
          StoreAccessRole.owner,
          StoreAccessRole.manager,
          StoreAccessRole.stockManager
        ], // ✅ OWNER/MANAGER/STOCK_MANAGER
      },
      {'type': 'spacer'},
      {'type': 'section', 'title': 'Sistema', 'index': 21},
      {
        'type': 'item',
        'title': 'Chatbot',
        'route': '/chatbot',
        'index': 17,
        'iconPath': 'assets/images/user.png',
        'roles': [StoreAccessRole.owner, StoreAccessRole.manager], // ✅ OWNER/MANAGER
      },
      {
        'type': 'item',
        'title': 'Acessos',
        'route': '/accesses',
        'index': 18,
        'iconPath': 'assets/images/user.png',
        'roles': [StoreAccessRole.owner], // ✅ SÓ OWNER
      },
      {
        'type': 'item',
        'title': 'Dispositivos',
        'route': '/sessions',
        'index': 19,
        'iconPath': 'assets/images/user.png',
        'roles': null, // ✅ Todos podem acessar
      },
      {
        'type': 'item',
        'title': 'Minha assinatura',
        'route': '/manager',
        'index': 20,
        'iconPath': 'assets/images/rocket-launch.png',
        'roles': [StoreAccessRole.owner], // ✅ SÓ OWNER
      },
    ];
  }

  List<Widget> _buildMenuItemsFromData({
    required BuildContext context,
    required bool isExpanded,
    required dynamic activeStore, // ✅ ADICIONAR
  }) {
    final List<Widget> menuWidgets = [];
    final menuData = _getMenuData(); // ✅ Usa método que retorna dados com roles

    for (final itemData in menuData) {
      final String type = itemData['type'] as String;

      if (type == 'spacer') {
        menuWidgets.add(const SizedBox(height: 20));
        continue;
      }

      switch (type) {
        case 'section':
          if (isExpanded) {
            menuWidgets.add(_buildSectionTitle(
              itemData['title'] as String,
              selected: false,
            ));
          }
          break;
        case 'item':
          final String? iconPath = itemData['iconPath'] as String?;
          final String title = itemData['title'] as String;
          final String route = itemData['route'] as String;
          final int index = itemData['index'] as int;
          final List<StoreAccessRole>? requiredRoles =
          itemData['roles'] as List<StoreAccessRole>?;

          // ✅ VALIDAÇÃO DE PERMISSÃO
          if (requiredRoles != null) {
            final hasPermission =
            PermissionService.hasAnyRole(activeStore, requiredRoles);
            if (!hasPermission) {
              continue; // ✅ Não mostra o item se não tiver permissão
            }
          }

          menuWidgets.add(_buildMenuItem(
            context: context,
            title: title,
            route: route,
            index: index,
            iconPath: iconPath ?? 'assets/images/package.png',
            isExpanded: isExpanded,
          ));
          break;
      }
    }
    return menuWidgets;
  }

  Widget _buildSectionTitle(String title, {required bool selected}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: selected
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required String title,
    required String route,
    required int index,
    required String iconPath,
    required bool isExpanded,
    IconData? customIcon,
  }) {
    final isSelected = _isRouteActive(context, route);

    final Color primaryColor = Theme.of(context).primaryColor;
    final Color defaultIconColor =
        Theme.of(context).listTileTheme.iconColor ??
            Theme.of(context).iconTheme.color ??
            Colors.grey;
    final Color defaultTextColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    final Color iconColor = isSelected ? primaryColor : defaultIconColor;
    final Color textColor = isSelected ? primaryColor : defaultTextColor;
    final Color backgroundColor =
    isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent;
    final Border? border = isSelected
        ? Border.all(color: primaryColor.withOpacity(0.3), width: 1.0)
        : null;

    return InkWell(
      onTap: () {
        final fullRoute = '/stores/${widget.storeId}$route';
        _navigateAndCloseDrawer(context, fullRoute);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: isExpanded ? 48 : 55,
        width: isExpanded ? double.infinity : 60,
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: isExpanded ? null : border,
        ),
        child: isExpanded
            ? Row(
          children: [
            const SizedBox(width: 8),
            customIcon != null
                ? Icon(customIcon, size: 20, color: iconColor)
                : _buildIcon(iconPath, iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        )
            : Stack(
          children: [
            if (isSelected)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2.0,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: customIcon != null
                        ? Icon(customIcon, size: 20, color: iconColor)
                        : _buildIcon(iconPath, iconColor),
                  ),
                  const SizedBox(height: 4),
                  if (!isSelected)
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: defaultTextColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String iconPath, Color color) {
    try {
      return Image.asset(
        iconPath,
        height: 20,
        width: 20,
        color: color,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.error_outline,
            size: 20,
            color: color,
          );
        },
      );
    } catch (e) {
      return Icon(
        Icons.error_outline,
        size: 20,
        color: color,
      );
    }
  }
}