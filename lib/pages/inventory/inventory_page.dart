import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';
import 'package:totem_pro_admin/pages/inventory/widgets/inventory_filter_search.dart';
import 'package:totem_pro_admin/pages/inventory/widgets/inventory_list.dart';
import 'package:totem_pro_admin/pages/inventory/widgets/inventory_table.dart';
import 'package:totem_pro_admin/pages/inventory/widgets/inventry_dashboard.dart';
import 'package:totem_pro_admin/pages/inventory/widgets/stock_operation_dialog.dart';

// Importações do seu projeto (verifique os caminhos)
import '../../core/enums/inventory_stock.dart';
import '../../cubits/store_manager_cubit.dart';
import '../../cubits/store_manager_state.dart';
import '../../models/product.dart';
// Removi DI e Repository daqui, a página não deve chamá-los diretamente
import '../../widgets/app_page_header.dart';
import '../../core/responsive_builder.dart';
import '../../widgets/fixed_header.dart';



class InventoryPage extends StatefulWidget {
  final int storeId;
  const InventoryPage({super.key, required this.storeId});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String _activeFilter = 'Todos';
  String _searchTerm = '';

  List<Product> _getFilteredProducts(List<Product> allProducts) {
    // Agora o filtro considera todos os produtos, não apenas os com controle de estoque
    final statusFiltered = () {
      switch (_activeFilter) {
        case 'Estoque Baixo':
          return allProducts.where((p) => p.stockStatus == ProductStockStatus.lowStock).toList();
        case 'Esgotado':
          return allProducts.where((p) => p.stockStatus == ProductStockStatus.outOfStock).toList();
        default: // 'Todos'
          return allProducts;
      }
    }();

    if (_searchTerm.isEmpty) {
      return statusFiltered;
    }
    return statusFiltered.where((p) => p.name.toLowerCase().contains(_searchTerm.toLowerCase())).toList();
  }

  // ✅ NOVO: Lógica para chamar os dialogs
  void _showAddStockDialog(BuildContext context, List<Product> allProducts) {
    showDialog(
      context: context,
      builder: (_) => StockOperationDialog(
        title: 'Adicionar Entrada no Estoque',
        products: allProducts,
        operationType: StockOperationType.add,
        onConfirm: (product, quantity, cost) {
          // TODO: Chamar o Cubit para registrar a entrada
          // Ex: context.read<StoresManagerCubit>().addStockEntry(
          //   productId: product.id!,
          //   quantity: quantity,
          //   costPrice: cost,
          // );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Entrada de $quantity un. de ${product.name} registrada!')),
          );
        },
      ),
    );
  }

  void _showTransferStockDialog(BuildContext context, List<Product> allProducts) {
    // Para transferência, só mostramos produtos que têm estoque
    final productsInStock = allProducts.where((p) => (p.stockQuantity ?? 0) > 0).toList();
    showDialog(
      context: context,
      builder: (_) => StockOperationDialog(
        title: 'Realizar Baixa / Transferência',
        products: productsInStock,
        operationType: StockOperationType.remove,
        onConfirm: (product, quantity, _) { // Custo é ignorado aqui
          // TODO: Chamar o Cubit para registrar a baixa
          // Ex: context.read<StoresManagerCubit>().removeStock(
          //   productId: product.id!,
          //   quantity: quantity,
          // );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Baixa de $quantity un. de ${product.name} registrada!')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final allProducts = state.activeStore?.relations.products ?? [];
        final filteredProducts = _getFilteredProducts(allProducts);

        final stockControlled = allProducts.where((p) => p.controlStock).toList();
        final lowStockCount = stockControlled.where((p) => p.stockStatus == ProductStockStatus.lowStock).length;
        final outOfStockCount = stockControlled.where((p) => p.stockStatus == ProductStockStatus.outOfStock).length;
        final inStockCount = stockControlled.length - lowStockCount - outOfStockCount;

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ HEADER MODIFICADO com botões de ação
                FixedHeader(
                  title: 'Controle de Estoque',
                  subtitle: 'Monitore e ajuste as quantidades dos seus produtos.',
                  actions: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.remove_circle_outline),
                      label: const Text('Realizar Baixa'),
                      onPressed: () => _showTransferStockDialog(context, allProducts),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Adicionar Entrada'),
                      onPressed: () => _showAddStockDialog(context, allProducts),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                InventoryDashboard(
                  inStockCount: inStockCount,
                  lowStockCount: lowStockCount,
                  outOfStockCount: outOfStockCount,
                ),
                const SizedBox(height: 24),
                InventoryFiltersAndSearch(
                  activeFilter: _activeFilter,
                  onFilterChanged: (newFilter) => setState(() => _activeFilter = newFilter),
                  onSearchChanged: (term) => setState(() => _searchTerm = term),
                ),
                const SizedBox(height: 24),
                Text('${filteredProducts.length} produtos encontrados', style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 8),
                ResponsiveBuilder(
                  desktopBuilder: (_, __) => InventoryTable(
                    storeId: widget.storeId,
                    products: filteredProducts,
                  ),
                  mobileBuilder: (_, __) => InventoryList(
                    storeId: widget.storeId,
                    products: filteredProducts,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}












