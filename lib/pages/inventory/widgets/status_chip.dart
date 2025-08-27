import 'package:flutter/material.dart';

import '../../../core/enums/inventory_stock.dart';

class StatusChip extends StatelessWidget {
  final ProductStockStatus status;
  const StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final Map<ProductStockStatus, dynamic> styles = {
      ProductStockStatus.inStock: {'label': 'Em Estoque', 'color': Colors.green.shade600},
      ProductStockStatus.lowStock: {'label': 'Estoque Baixo', 'color': Colors.orange.shade800},
      ProductStockStatus.outOfStock: {'label': 'Esgotado', 'color': Colors.red.shade700},
      ProductStockStatus.notControlled: {'label': 'Não Controlado', 'color': Colors.grey.shade500},
    };
    final style = styles[status]!;

    return Chip(
      label: Text(style['label']),
      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      backgroundColor: style['color'],
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}
