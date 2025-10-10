import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/models/category.dart';

import 'package:totem_pro_admin/pages/products/widgets/prduct_filter.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_card_item.dart';
import 'package:totem_pro_admin/pages/products/widgets/sliver_filter.dart';
import 'package:totem_pro_admin/pages/products/widgets/table_header.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import '../../../core/enums/bulk_action_type.dart';
import '../../../core/responsive_builder.dart';
import '../../../models/products/product.dart';
import '../../../widgets/fixed_header.dart';
import '../../../widgets/fixed_header_small.dart';
import '../../product_groups/helper/side_panel_helper.dart';
import '../../categories_bulk/BulkCategoryPage.dart';
import '../cubit/products_cubit.dart';

// Enum para as opções de ordenação
enum SortOption { nameAsc, nameDesc, priceAsc, priceDesc }

// ===================================================================
// WIDGET PRINCIPAL DA ABA "PRODUTOS"
// ===================================================================
class ProductListTab extends StatefulWidget {
  final List<Product> products;
  final List<Category> allCategories;
  final VoidCallback onAddProduct;
  final int storeId;

  const ProductListTab({
    super.key,
    required this.products,
    required this.allCategories,
    required this.onAddProduct,
    required this.storeId,
  });

  @override
  State<ProductListTab> createState() => _ProductListTabState();
}

class _ProductListTabState extends State<ProductListTab> {
  // --- Estados do Widget ---
  final _searchController = TextEditingController();
  String _searchText = '';
  SortOption _sortOption = SortOption.nameAsc;
  final Set<int> _selectedProductIds = {};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() => _searchText = _searchController.text.toLowerCase());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _sortProducts(List<Product> products) {
    products.sort((a, b) {
      switch (_sortOption) {
        case SortOption.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case SortOption.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());

        case SortOption.priceAsc:
          // Se o preço for nulo, consideramos como infinito para que vá para o final.
          return (a.price ?? double.infinity).compareTo(
            b.price ?? double.infinity,
          );

        case SortOption.priceDesc:
          // A mesma lógica, mas com a ordem invertida.
          return (b.price ?? double.infinity).compareTo(
            a.price ?? double.infinity,
          );
      }
    });
  }

  void _toggleProductSelection(int productId) {
    setState(() {
      if (_selectedProductIds.contains(productId)) {
        _selectedProductIds.remove(productId);
      } else {
        _selectedProductIds.add(productId);
      }
    });
  }

  void _toggleSelectAll(List<Product> visibleProducts) {
    setState(() {
      final allVisibleIds = visibleProducts.map((p) => p.id!).toSet();
      if (_selectedProductIds.containsAll(allVisibleIds) &&
          _selectedProductIds.isNotEmpty) {
        _selectedProductIds.clear();
      } else {
        _selectedProductIds.addAll(allVisibleIds);
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ordenar por',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                RadioListTile<SortOption>(
                  title: const Text('Nome A-Z'),
                  value: SortOption.nameAsc,
                  groupValue: _sortOption,
                  onChanged:
                      (v) => setState(() {
                        _sortOption = v!;
                        Navigator.pop(context);
                      }),
                ),
                RadioListTile<SortOption>(
                  title: const Text('Nome Z-A'),
                  value: SortOption.nameDesc,
                  groupValue: _sortOption,
                  onChanged:
                      (v) => setState(() {
                        _sortOption = v!;
                        Navigator.pop(context);
                      }),
                ),
                RadioListTile<SortOption>(
                  title: const Text('Menor Preço'),
                  value: SortOption.priceAsc,
                  groupValue: _sortOption,
                  onChanged:
                      (v) => setState(() {
                        _sortOption = v!;
                        Navigator.pop(context);
                      }),
                ),
                RadioListTile<SortOption>(
                  title: const Text('Maior Preço'),
                  value: SortOption.priceDesc,
                  groupValue: _sortOption,
                  onChanged:
                      (v) => setState(() {
                        _sortOption = v!;
                        Navigator.pop(context);
                      }),
                ),
              ],
            ),
          ),
    );
  }

  void _showAddToCategoryWizard(List<Product> selectedProducts) {
    showResponsiveSidePanelGroup(
      context,
      panel: BulkAddToCategoryWizard(
        storeId: widget.storeId,
        selectedProducts: selectedProducts,
        allCategories: widget.allCategories,
        actionType: BulkActionType.move,
      ),
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
    required VoidCallback onConfirm,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor:
                      isDestructive
                          ? Colors.red
                          : Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  onConfirm();
                  Navigator.of(ctx).pop();
                },
                child: Text(confirmText),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = widget.products
        .where((p) => p.name.toLowerCase().contains(_searchText))
        .toList();
    _sortProducts(filteredProducts);

    final isAllSelected = _selectedProductIds.length == filteredProducts.length && filteredProducts.isNotEmpty;
    final bool hasSelection = _selectedProductIds.isNotEmpty;
    final double persistentHeaderHeight = hasSelection ? 128.0 : 120.0;

    // ✅ ESTRUTURA CORRIGIDA: APENAS OS FILTROS FICAM PINNED
    return CustomScrollView(
      key: const PageStorageKey('product_list_view_scroll'),
      slivers: [
        // ✅ FIXEDHEADERSMALL - DEVE ROLAR PARA CIMA (NÃO PINNED)
        if(ResponsiveBuilder.isDesktop(context))
          SliverToBoxAdapter(
            child: FixedHeaderSmall(
              title: 'Produtos do seu cardápio (${widget.products.length})',
              subtitle: 'Adicione, pause ou ative os produtos.',
              actions: [
                DsButton(
                  label: 'Adicionar produto',
                  onPressed: widget.onAddProduct,
                )
              ],
            ),
          ),

        // ✅ FILTROS - FICAM FIXOS NO TOPO (PINNED)
        SliverPersistentHeader(
          pinned: true, // 🔥 APENAS ESTE FICA PINNED
          delegate: SliverFilterBarDelegateProduct(
            height: persistentHeaderHeight,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  child: ProductFilters(
                    searchController: _searchController,
                    sortOption: _sortOption,
                    onSortChanged: (value) {
                      if (value != null) setState(() => _sortOption = value);
                    },
                    onFilterTap: _showFilterBottomSheet,
                  ),
                ),
                TableHeader(
                  selectedCount: _selectedProductIds.length,
                  isAllSelected: isAllSelected,
                  onSelectAll: () => _toggleSelectAll(filteredProducts),
                  onPause: () => _showConfirmationDialog(
                    title: 'Pausar produtos',
                    content: 'Tem certeza que deseja pausar os ${_selectedProductIds.length} produtos selecionados?',
                    confirmText: 'Pausar produtos',
                    onConfirm: () {
                      context.read<StoresManagerCubit>().pauseProducts(_selectedProductIds.toList());
                      setState(() => _selectedProductIds.clear());
                    },
                  ),
                  onActivate: () => _showConfirmationDialog(
                    title: 'Ativar produtos',
                    content: 'Tem certeza que deseja ativar os ${_selectedProductIds.length} produtos selecionados?',
                    confirmText: 'Ativar produtos',
                    onConfirm: () {
                      context.read<StoresManagerCubit>().activateProducts(_selectedProductIds.toList());
                      setState(() => _selectedProductIds.clear());
                    },
                  ),
                  onRemove: () => _showConfirmationDialog(
                    title: 'Arquivar produtos',
                    content: 'Os produtos arquivados não aparecerão no seu cardápio, mas poderão ser restaurados. Deseja arquivar os ${_selectedProductIds.length} produtos selecionados?',
                    confirmText: 'Sim, Arquivar',
                    isDestructive: false,
                    onConfirm: () {
                      context.read<StoresManagerCubit>().archiveProducts(_selectedProductIds.toList());
                      setState(() => _selectedProductIds.clear());
                    },
                  ),
                  onAddToCategory: () {
                    final selectedProducts = widget.products
                        .where((p) => _selectedProductIds.contains(p.id))
                        .toList();
                    _showAddToCategoryWizard(selectedProducts);
                    setState(() => _selectedProductIds.clear());
                  },
                ),
              ],
            ),
          ),
        ),

        // ✅ CONTEÚDO DA LISTA
        if (filteredProducts.isEmpty)
          SliverFillRemaining(
            child: NoResultsState(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final product = filteredProducts[index];
                  final isSelected = _selectedProductIds.contains(product.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: ProductCardItem(
                      product: product,
                      isSelected: isSelected,
                      onTap: () {
                        if (product.id != null) {
                          _toggleProductSelection(product.id!);
                        }
                      },
                      storeId: widget.storeId,
                      onStatusToggle: () {
                        context.read<ProductsCubit>().toggleProductStatus(widget.storeId, product);
                      },
                    ),
                  );
                },
                childCount: filteredProducts.length,
              ),
            ),
          ),
      ],
    );
  }




}

class NoResultsState extends StatelessWidget {
  const NoResultsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64.0, horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Nenhum produto encontrado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tente ajustar os termos da sua busca ou filtros.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
