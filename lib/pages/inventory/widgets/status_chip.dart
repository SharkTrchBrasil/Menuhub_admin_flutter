// status_chip.dart
import 'package:flutter/material.dart';
import '../../../core/enums/inventory_stock.dart';

class StatusChip extends StatelessWidget {
  final ProductStockStatus status;
  const StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final Map<ProductStockStatus, dynamic> styles = {
      ProductStockStatus.inStock: {
        'label': 'Em Estoque',
        'color': Colors.green,
        'icon': Icons.check_circle_outline,
      },
      ProductStockStatus.lowStock: {
        'label': 'Estoque Baixo',
        'color': Colors.orange,
        'icon': Icons.warning_amber_outlined,
      },
      ProductStockStatus.outOfStock: {
        'label': 'Esgotado',
        'color': Colors.red,
        'icon': Icons.error_outline,
      },
      ProductStockStatus.notControlled: {
        'label': 'Não Controlado',
        'color': Colors.grey,
        'icon': Icons.remove_circle_outline,
      },
    };

    final style = styles[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: style['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: style['color'].withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            style['icon'],
            size: 12,
            color: style['color'],
          ),
          const SizedBox(width: 4),
          Text(
            style['label'],
            style: TextStyle(
              color: style['color'],
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}