
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';
import 'package:totem_pro_admin/pages/inventory/widgets/status_chip.dart';


import '../../../models/products/product.dart';

class InventoryList extends StatelessWidget {
  final List<Product> products;
  final int storeId;
  // ❌ onStockChanged foi removido.
  const InventoryList({required this.products, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(product.images.first.url ?? '', width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, size: 50))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          StatusChip(status: product.stockStatus),
                        ],
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => context.
                    go('/stores/$storeId/products/${product.id}')),
                  ],
                ),
                const Divider(height: 24),
                // ✅ LINHA SIMPLIFICADA: Apenas exibe o valor
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Estoque Atual:', style: TextStyle(fontSize: 16)),
                    Text(
                      product.controlStock ? '${product.stockQuantity ?? 0} un.' : 'Não controlado',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
