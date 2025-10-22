import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/models/store/store.dart';

class OrdersDrawerLayout extends StatelessWidget {
  final int storeId;
  final Store? activeStore;
  final String currentRoute;
  final Widget child;

  const OrdersDrawerLayout({
    super.key,
    required this.storeId,
    required this.activeStore,
    required this.currentRoute,
    required this.child,
  });

  // ✅ Mapear cada item do drawer para sua rota
  List<DrawerItem> get _drawerItems => [
    DrawerItem(
      label: 'Pedidos',
      icon: Icons.receipt_long,
      route: '/stores/$storeId/orders/list',
    ),
    DrawerItem(
      label: 'Expedição',
      icon: Icons.shopping_bag_outlined,
      route: '/stores/$storeId/orders/shipping',
    ),
    DrawerItem(
      label: 'Cardápio',
      icon: Icons.restaurant_menu,
      route: '/stores/$storeId/orders/menu',
    ),
    DrawerItem(
      label: 'Ajuda',
      icon: Icons.help_outline,
      route: '/stores/$storeId/orders/help',
    ),
    DrawerItem(
      label: 'Configurações',
      icon: Icons.settings,
      route: '/stores/$storeId/orders/settings',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Drawer na esquerda
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // ✅ Header customizado
          _buildHeader(context),
          // ✅ Conteúdo
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // ✅ Botão Menu
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),

          // ✅ Título
          const Text(
            'Gestão de Pedidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          // ✅ Info da loja
          if (activeStore != null)
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: activeStore!.media?.image?.url != null
                      ? NetworkImage(activeStore!.media!.image!.url!)
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: activeStore!.media?.image?.url == null
                      ? const Icon(Icons.store, size: 18)
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      activeStore!.core.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      activeStore!.core.phone ?? 'Sem telefone',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),

          const SizedBox(width: 16),

          // ✅ Botões de ação
          IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () => context.go('/hub'),
            tooltip: 'Voltar',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: 80,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ✅ Itens do drawer
            ..._drawerItems.map((item) {
              final isActive = currentRoute.contains(item.route.split('/').last);

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: _DrawerButton(
                  icon: item.icon,
                  label: item.label,
                  isActive: isActive,
                  onTap: () {
                    context.go(item.route);
                    Navigator.pop(context); // Fecha o drawer
                  },
                ),
              );
            }).toList(),

            const Spacer(),

            // ✅ Divisor
            const Divider(height: 1),

            // ✅ Portal do Parceiro
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: _DrawerButton(
                icon: Icons.business_center,
                label: 'Loja',
                isActive: false,
                onTap: () {
                  context.go('/stores/$storeId/dashboard');
                  Navigator.pop(context); // Fecha o drawer após navegar
                },
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ✅ Botão personalizado do drawer
class _DrawerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? const Color(0xFFEA1D2C).withOpacity(0.1) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? const Color(0xFFEA1D2C) : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? const Color(0xFFEA1D2C) : Colors.grey[600],
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Model simples
class DrawerItem {
  final String label;
  final IconData icon;
  final String route;

  DrawerItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}