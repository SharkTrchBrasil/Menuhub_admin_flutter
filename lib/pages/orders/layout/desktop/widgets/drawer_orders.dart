import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/models/store/store.dart';

import '../../../../../cubits/store_manager_cubit.dart';

class OrdersDrawerLayout extends StatelessWidget {
  final int storeId;
  final Store? activeStore;
  final int selectedIndex; // ✅ Índice selecionado (ao invés de rota)
  final ValueChanged<int> onItemTapped; // ✅ Callback para mudança de índice
  final Widget child;

  const OrdersDrawerLayout({
    super.key,
    required this.storeId,
    required this.activeStore,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.child,
  });

  // ✅ Lista de itens do drawer (sem rotas, apenas dados)
  List<DrawerItem> get _drawerItems => [
    DrawerItem(
      label: 'Pedidos',
      icon: Icons.receipt_long,
    ),
    DrawerItem(
      label: 'Expedição',
      icon: Icons.shopping_bag_outlined,
    ),
    DrawerItem(
      label: 'Cardápio',
      icon: Icons.restaurant_menu,
    ),
    DrawerItem(
      label: 'Ajuda',
      icon: Icons.help_outline,
    ),
    DrawerItem(
      label: 'Configurações',
      icon: Icons.settings,
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

          // ✅ Botão Voltar para Dashboard (esse SIM usa navegação)
          IconButton(
            icon: const Icon(Icons.arrow_back_outlined),
            onPressed: () {
              // Navega para o dashboard da loja (sai da área de pedidos)
              context.go('/stores/$storeId/dashboard');
            },
            tooltip: 'Voltar para Dashboard',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {

    final storeId = context.read<StoresManagerCubit>().state.activeStore?.core.id;
    return Drawer(
      width: 80,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ✅ Itens do drawer com navegação por índice
            ..._drawerItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: _DrawerButton(
                  icon: item.icon,
                  label: item.label,
                  isActive: index == selectedIndex,
                  onTap: () {
                    // ✅ Fecha o drawer
                    Navigator.pop(context);
                    // ✅ Chama o callback com o índice
                    onItemTapped(index);
                  },
                ),
              );
            }).toList(),

            const Spacer(),

            // ✅ Divisor
            const Divider(height: 1),

            // ✅ Botão Voltar para Dashboard
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: _DrawerButton(
                icon: Icons.dashboard,
                label: 'Dashboard',
                isActive: false,
                onTap: () {
                  // Fecha o drawer
                  Navigator.pop(context);
                  // Navega para o dashboard (sai da área de pedidos)
                  context.go('/stores/$storeId/dashboard');
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

// ✅ Model simplificado (sem rotas)
class DrawerItem {
  final String label;
  final IconData icon;

  DrawerItem({
    required this.label,
    required this.icon,
  });
}