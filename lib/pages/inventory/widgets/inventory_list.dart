// inventory_list.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';
import 'package:totem_pro_admin/pages/inventory/widgets/status_chip.dart';

import '../../../models/products/product.dart';

class InventoryList extends StatelessWidget {
  final List<Product> products;
  final int storeId;

  const InventoryList({required this.products, required this.storeId});




  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(context, product);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.go('/stores/$storeId/products/${product.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildProductImage(product),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          StatusChip(status: product.stockStatus),
                          const SizedBox(height: 8),
                          _buildStockInfo(context, product),
                        ],
                      ),
                    ),
                    _buildActionButton(context, product),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(Product product) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          product.images.first.url ?? '',
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.inventory_2_outlined,
            color: Colors.grey[400],
            size: 30,
          ),
        ),
      ),
    );
  }

  Widget _buildStockInfo(BuildContext context, Product product) {
    return Row(
      children: [
        Icon(
          Icons.inventory_2_outlined,
          size: 16,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Text(
          'Estoque: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          product.controlStock ? '${product.stockQuantity ?? 0} un.' : 'Não controlado',
          style: TextStyle(
            color: _getStockColor(product),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, Product product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[600]),
        onPressed: () => context.go('/stores/$storeId/products/${product.id}'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum produto encontrado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros ou termos de busca',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }




  Color _getStockColor(Product product) {
    if (!product.controlStock) return Colors.grey;
    if (product.stockQuantity == 0) return Colors.red;
    if (product.stockQuantity! < 10) return Colors.orange;
    return Colors.green;
  }
}