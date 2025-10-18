// inventory_table.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';
import 'package:totem_pro_admin/pages/inventory/widgets/status_chip.dart';

import '../../../core/helpers/edit_product_sidepanel.dart';
import '../../../models/products/product.dart';
import '../../products/cubit/products_cubit.dart';
import 'adjust_stock_dialog.dart';

class InventoryTable extends StatelessWidget {
  final List<Product> products;
  final int storeId;

  const InventoryTable({required this.products, required this.storeId});

  // ✨ NOVO: Função para abrir o diálogo de ajuste ✨
  void _showAdjustStockDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder:
          (_) => BlocProvider.value(
            value: context.read<ProductsCubit>(),
            child: AdjustStockDialog(product: product, storeId: storeId),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return _buildEmptyState(context);
    }

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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey[50]),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
            columns: const [
              DataColumn(label: _TableHeader('Produto')),
              DataColumn(label: _TableHeader('Status')),
              DataColumn(label: _TableHeader('Estoque Atual'), numeric: true),
              DataColumn(label: _TableHeader('Última Atualização')),
              DataColumn(label: _TableHeader('Ações')),
            ],
            rows:
                products
                    .map((product) => _buildDataRow(context, product))
                    .toList(),
          ),
        ),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, Product product) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              _buildProductImage(product),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.ean != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.ean!,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        DataCell(StatusChip(status: product.stockStatus)),
        DataCell(
          Center(
            child: Text(
              product.controlStock
                  ? (product.stockQuantity ?? 0).toString()
                  : 'N/A',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _getStockColor(product),
                fontSize: 16,
              ),
            ),
          ),
        ),
        DataCell(
          Text(
            _formatDate(DateTime.now()),
            // Substitua por product.updatedAt se existir
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        DataCell(
          Row(
            children: [
              // Botão para ir para a página de detalhes do produto
              IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  size: 20,
                  color: Colors.blue.shade700,
                ),
                tooltip: 'Editar Produto Completo',
                onPressed: () {
                  showEditProductPanel(
                    context: context,
                    product: product,
                    storeId: storeId,
                    // Não passamos `parentCategory` aqui
                  );
                },
              ),
              const SizedBox(width: 8),
              // Botão para abrir o novo diálogo de ajuste de estoque
              IconButton(
                icon: Icon(
                  Icons.inventory_2_outlined,
                  size: 20,
                  color: Colors.purple.shade700,
                ),
                tooltip: 'Gerenciar Estoque',
                onPressed: () => _showAdjustStockDialog(context, product),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage(Product product) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product.images.first.url ?? '',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) => Icon(
                Icons.inventory_2_outlined,
                color: Colors.grey[400],
                size: 20,
              ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Nenhum produto encontrado',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente ajustar os filtros ou termos de busca',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _TableHeader extends StatelessWidget {
  final String text;

  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey[700],
          fontSize: 14,
        ),
      ),
    );
  }
}
