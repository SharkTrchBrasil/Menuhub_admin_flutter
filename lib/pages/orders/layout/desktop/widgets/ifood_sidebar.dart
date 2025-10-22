// [Arquivo: ifood_sidebar.dart]

import 'package:flutter/material.dart';
// Remova a importação do go_router, não é mais necessária aqui

class IfoodSidebar extends StatelessWidget {
  // 1. Receba o estado e o callback
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

   IfoodSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  final List<SidebarItem> _items = [
    SidebarItem(Icons.receipt_long, 'Pedidos', isActive: true),
    SidebarItem(Icons.shopping_bag_outlined, 'Expedição'),
    SidebarItem(Icons.restaurant_menu, 'Cardápio'),
    SidebarItem(Icons.help_outline, 'Ajuda'),
    SidebarItem(Icons.settings, 'Configurações'),
  ];

  @override
  Widget build(BuildContext context) {
    // 2. Remova toda a lógica de _getSelectedIndex e _onItemTapped

    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Itens da sidebar
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;

            return _SidebarButton(
              icon: item.icon,
              label: item.label,
              // 3. Use o selectedIndex recebido por parâmetro
              isActive: index == selectedIndex,
              onTap: () {
                // 4. Chame o callback informando o índice
                onItemTapped(index);
              },
            );
          }).toList(),

          const Spacer(),

          // Divisor
          const Divider(height: 1),

          // Portal do Parceiro
          _SidebarButton(
            icon: Icons.business_center,
            label: 'Portal',
            isActive: false,
            onTap: () {
              // TODO: Adicionar navegação para o portal (isso sim pode usar context.go)
            },
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ... (Classes SidebarItem e _SidebarButton permanecem exatamente iguais) ...

class SidebarItem {
  final IconData icon;
  final String label;
  final bool isActive;

  SidebarItem(this.icon, this.label, {this.isActive = false});
}

class _SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Material(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}