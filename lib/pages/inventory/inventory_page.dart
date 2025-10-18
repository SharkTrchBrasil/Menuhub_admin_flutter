// inventory_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/core/extensions/extensions.dart';

import 'package:totem_pro_admin/pages/inventory/widgets/inventory_filter_search.dart';
import 'package:totem_pro_admin/pages/inventory/widgets/inventory_list.dart';
import 'package:totem_pro_admin/pages/inventory/widgets/inventory_table.dart';
import 'package:totem_pro_admin/pages/inventory/widgets/inventry_dashboard.dart';
import 'package:totem_pro_admin/pages/inventory/widgets/stock_operation_dialog.dart';

import '../../core/di.dart';
import '../../core/enums/inventory_stock.dart';
import '../../cubits/store_manager_cubit.dart';
import '../../cubits/store_manager_state.dart';
import '../../models/products/product.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/product_repository.dart';
import '../../widgets/app_page_header.dart';
import '../../core/responsive_builder.dart';
import '../products/cubit/products_cubit.dart';

class InventoryPage extends StatelessWidget {
  final int storeId;
  const InventoryPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    // ✅ 1. PROVENDO O PRODUCTS CUBIT PARA A TELA E SEUS FILHOS
    return BlocProvider(
      create: (context) => ProductsCubit(
        categoryRepository: getIt<CategoryRepository>(),
        productRepository: getIt<ProductRepository>(),
      ),
      child: _InventoryView(storeId: storeId),
    );
  }
}

// Extrai a view para um widget separado para ter acesso ao context com o provider
class _InventoryView extends StatefulWidget {
  final int storeId;
  const _InventoryView({required this.storeId});

  @override
  State<_InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<_InventoryView> {
  String _activeFilter = 'Todos';
  String _searchTerm = '';

  List<Product> _getFilteredProducts(List<Product> allProducts) {
    final statusFiltered = () {
      switch (_activeFilter) {
        case 'Estoque Baixo':
          return allProducts.where((p) => p.stockStatus == ProductStockStatus.lowStock).toList();
        case 'Esgotado':
          return allProducts.where((p) => p.stockStatus == ProductStockStatus.outOfStock).toList();
        default:
          return allProducts;
      }
    }();

    if (_searchTerm.isEmpty) {
      return statusFiltered;
    }
    return statusFiltered.where((p) => p.name.toLowerCase().contains(_searchTerm.toLowerCase())).toList();
  }

  void _showAddStockDialog(BuildContext context, List<Product> allProducts) {
    // Filtra para mostrar apenas produtos que controlam estoque
    final stockControlledProducts = allProducts.where((p) => p.controlStock).toList();

    showDialog(
      context: context,
      // Passa o context do ProductsCubit para o Dialog
      builder: (_) => BlocProvider.value(
        value: context.read<ProductsCubit>(),
        child: StockOperationDialog(
          title: 'Adicionar Entrada no Estoque',
          products: stockControlledProducts,
          operationType: StockOperationType.add,
          // ✅ 2. A MÁGICA ACONTECE AQUI
          onConfirm: (product, quantity, cost) {
            // ✅ 3. AGORA PASSAMOS O CUSTO PARA O CUBIT
            context.read<ProductsCubit>().addStockMovement(
              storeId: widget.storeId,
              product: product,
              quantity: quantity,
              operationType: StockOperationType.add,
              cost: cost, // Passando o custo recebido do diálogo
            );
          },
        ),
      ),
    );
  }

  void _showTransferStockDialog(BuildContext context, List<Product> allProducts) {
    final productsInStock = allProducts.where((p) => p.controlStock && (p.stockQuantity ?? 0) > 0).toList();
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductsCubit>(),
        child: StockOperationDialog(
          title: 'Realizar Baixa / Transferência',
          products: productsInStock,
          operationType: StockOperationType.remove,
          // ✅ 3. E AQUI TAMBÉM
          onConfirm: (product, quantity, _) {
            context.read<ProductsCubit>().addStockMovement(
              storeId: widget.storeId,
              product: product,
              quantity: quantity,
              operationType: StockOperationType.remove,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductsCubit, ProductsState>(
      // ✅ 4. OUVINTE PARA MOSTRAR SNACKBARS DE SUCESSO/ERRO
      listener: (context, state) {
        if (state is ProductsActionSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
        }
        if (state is ProductsActionFailure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.red));
        }
      },
      child: BlocBuilder<StoresManagerCubit, StoresManagerState>(
        builder: (context, state) {
          if (state is! StoresManagerLoaded) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Carregando estoque...',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final allProducts = state.activeStore?.relations.products ?? [];
          final filteredProducts = _getFilteredProducts(allProducts);

          final stockControlled = allProducts.where((p) => p.controlStock).toList();
          final lowStockCount = stockControlled.where((p) => p.stockStatus == ProductStockStatus.lowStock).length;
          final outOfStockCount = stockControlled.where((p) => p.stockStatus == ProductStockStatus.outOfStock).length;
          final inStockCount = stockControlled.length - lowStockCount - outOfStockCount;

          return Scaffold(
            backgroundColor: Colors.grey[50],
            body: Column(
              children: [
                // ... (O resto da sua UI continua exatamente igual)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Controle de Estoque',
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Monitore e ajuste as quantidades dos seus produtos',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  _buildActionButton(
                                    context,
                                    icon: Icons.remove_circle_outline,
                                    label: 'Realizar Baixa',
                                    color: Colors.orange,
                                    onPressed: () => _showTransferStockDialog(context, allProducts),
                                  ),
                                  const SizedBox(width: 12),
                                  _buildActionButton(
                                    context,
                                    icon: Icons.add_circle_outline,
                                    label: 'Adicionar Entrada',
                                    color: Colors.green,
                                    onPressed: () => _showAddStockDialog(context, allProducts),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Quick Stats no Header
                          Row(
                            children: [
                              _buildQuickStat(
                                context,
                                value: allProducts.length,
                                label: 'Total Produtos',
                                icon: Icons.inventory_2_outlined,
                              ),
                              const SizedBox(width: 20),
                              _buildQuickStat(
                                context,
                                value: lowStockCount,
                                label: 'Estoque Baixo',
                                icon: Icons.warning_amber_outlined,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 20),
                              _buildQuickStat(
                                context,
                                value: outOfStockCount,
                                label: 'Esgotados',
                                icon: Icons.error_outline,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Conteúdo Principal
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dashboard Gráfico
                        InventoryDashboard(
                          inStockCount: inStockCount,
                          lowStockCount: lowStockCount,
                          outOfStockCount: outOfStockCount,
                        ),
                        const SizedBox(height: 24),
                        // Filtros e Busca
                        Container(
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
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Produtos em Estoque',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${filteredProducts.length} produtos encontrados',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              InventoryFiltersAndSearch(
                                activeFilter: _activeFilter,
                                onFilterChanged: (newFilter) => setState(() => _activeFilter = newFilter),
                                onSearchChanged: (term) => setState(() => _searchTerm = term),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Lista/Tabela de Produtos
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(BuildContext context, {
    required int value,
    required String label,
    required IconData icon,
    Color color = Colors.white,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value.toString(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}