import 'package:flutter/material.dart';

class IfoodSidebar extends StatefulWidget {
  const IfoodSidebar({super.key});

  @override
  State<IfoodSidebar> createState() => _IfoodSidebarState();
}

class _IfoodSidebarState extends State<IfoodSidebar> {
  int _selectedIndex = 0;

  final List<SidebarItem> _items = [
    SidebarItem(Icons.receipt_long, 'Pedidos', isActive: true),
    SidebarItem(Icons.shopping_bag_outlined, 'Expedição'),
    SidebarItem(Icons.restaurant_menu, 'Cardápio'),
    SidebarItem(Icons.help_outline, 'Ajuda'),
    SidebarItem(Icons.settings, 'Configurações'),
  ];

  @override
  Widget build(BuildContext context) {
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
              isActive: index == _selectedIndex,
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
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
            onTap: () {},
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

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