import 'package:flutter/material.dart';

class CustomAppBarWithDrawerOptions extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBarWithDrawerOptions({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70); // Altura da AppBar

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8), // Espaço externo
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24), // Borda ao redor
        borderRadius: BorderRadius.circular(12),
        color: Color(0xff060e19),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [



          // 🧭 Todas as opções do Drawer (colocadas como botões aqui)

              _buildDrawerOption(icon: Icons.home, label: 'Início', onTap: () {}),
              _buildDrawerOption(icon: Icons.receipt_long, label: 'Pedidos', onTap: () {}),
              _buildDrawerOption(icon: Icons.settings, label: 'Configurações', onTap: () {}),
              _buildDrawerOption(icon: Icons.logout, label: 'Sair', onTap: () {}),

        ],
      ),
    );
  }

  // Widget auxiliar para cada opção do drawer no AppBar
  Widget _buildDrawerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
