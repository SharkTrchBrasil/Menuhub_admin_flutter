import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';
import 'package:totem_pro_admin/pages/inventory/widgets/status_chip.dart';

import '../../../models/product.dart';

class InventoryTable extends StatelessWidget {
  final List<Product> products;
  final int storeId;
  // ❌ onStockChanged foi removido. A edição não é mais em linha.
  const InventoryTable({required this.products, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      clipBehavior: Clip.antiAlias,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Produto')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Estoque Atual'), numeric: true),
          DataColumn(label: Text('Ações')),
        ],
        rows: products.map((product) {
          return DataRow(cells: [
            DataCell(
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(product.images.first.url ?? '', width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported)),
                    ),
                    const SizedBox(width: 16),
                    Text(product.name),
                  ],
                )
            ),
            DataCell(StatusChip(status: product.stockStatus)),
            // ✅ CÉLULA SIMPLIFICADA: Apenas exibe o valor
            DataCell(
                Text(
                  product.controlStock ? (product.stockQuantity ?? 0).toString() : 'N/A',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                )
            ),
            DataCell(
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.grey[600]),
                  onPressed: () => context.go('/stores/$storeId/products/${product.id}'),
                )
            ),
          ]);
        }).toList(),
      ),
    );
  }
}
