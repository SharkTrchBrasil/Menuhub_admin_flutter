import 'package:flutter/material.dart';

// WIDGET PARA OS BOTÕES DE TIPO DE PEDIDO (BALCÃO, DELIVERY, ETC)
class OrderTypeTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const OrderTypeTab({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = Colors.blue[700];
    final unselectedColor = Colors.grey[600];
    final selectedBgColor = Colors.blue[50];
    final unselectedBgColor = Colors.grey[200];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: isSelected ? selectedBgColor : unselectedBgColor,
          foregroundColor: isSelected ? selectedColor : unselectedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? selectedColor : unselectedColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 8),
            // Badge de contagem
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : Colors.grey[400],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

