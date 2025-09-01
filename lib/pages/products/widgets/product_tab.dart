import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/pages/products/widgets/prduct_filter.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_card_item.dart';
import 'package:totem_pro_admin/pages/products/widgets/sliver_filter.dart';
import 'package:totem_pro_admin/pages/products/widgets/table_header.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import '../../../core/responsive_builder.dart';
import '../../../widgets/fixed_header.dart';
import 'move_category.dart';

// Enum para as opções de ordenação
enum SortOption { nameAsc, nameDesc, priceAsc, priceDesc }

// ===================================================================
// WIDGET PRINCIPAL DA ABA "PRODUTOS"
// ===================================================================
class ProductListView extends StatefulWidget {
  final List<Product> products;
  final List<Category> allCategories;
  final VoidCallback onAddProduct;
  final int storeId;

  const ProductListView({
    super.key,
    required this.products,
    required this.allCategories,
    required this.onAddProduct,
    required this.storeId
  });

  @override
  State<ProductListView> createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
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

  // --- Lógica de Negócio ---

  // DENTRO DA CLASSE _ProductListViewState

  void _sortProducts(List<Product> products) {
    products.sort((a, b) {
      switch (_sortOption) {
        case SortOption.nameAsc:
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        case SortOption.nameDesc:
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());

      // ✅ --- CORREÇÃO APLICADA AQUI --- ✅
      // Trocamos 'basePrice' pelo novo campo 'price'.
      // Como 'price' é obrigatório, não precisamos mais do '?? 0'.
        case SortOption.priceAsc:
          return a.price.compareTo(b.price);
        case SortOption.priceDesc:
          return b.price.compareTo(a.price);
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
      if (_selectedProductIds.containsAll(allVisibleIds) && _selectedProductIds.isNotEmpty) {
        _selectedProductIds.clear();
      } else {
        _selectedProductIds.addAll(allVisibleIds);
      }
    });
  }

  // --- Métodos de UI (Dialogs) ---

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ordenar por', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            RadioListTile<SortOption>(
              title: const Text('Nome A-Z'),
              value: SortOption.nameAsc,
              groupValue: _sortOption,
              onChanged: (v) => setState(() { _sortOption = v!; Navigator.pop(context); }),
            ),
            RadioListTile<SortOption>(
              title: const Text('Nome Z-A'),
              value: SortOption.nameDesc,
              groupValue: _sortOption,
              onChanged: (v) => setState(() { _sortOption = v!; Navigator.pop(context); }),
            ),
            RadioListTile<SortOption>(
              title: const Text('Menor Preço'),
              value: SortOption.priceAsc,
              groupValue: _sortOption,
              onChanged: (v) => setState(() { _sortOption = v!; Navigator.pop(context); }),
            ),
            RadioListTile<SortOption>(
              title: const Text('Maior Preço'),
              value: SortOption.priceDesc,
              groupValue: _sortOption,
              onChanged: (v) => setState(() { _sortOption = v!; Navigator.pop(context); }),
            ),
          ],
        ),
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
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: isDestructive ? Colors.red : Theme.of(context).primaryColor,
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

  void _showMoveToCategoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => MoveToCategoryDialog(
        allCategories: widget.allCategories,
        selectedProductIds: _selectedProductIds.toList(),
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

    // ✅ ALTURA DINÂMICA: A altura do header fixo muda se há itens selecionados
    final bool hasSelection = _selectedProductIds.isNotEmpty;
    final double persistentHeaderHeight = hasSelection ? 140.0 : 140.0;

    // ✅ ESTRUTURA PRINCIPAL ALTERADA PARA CUSTOMSCROLLVIEW
    return CustomScrollView(
      key: const PageStorageKey('product_list_view_scroll'),
      slivers: [

    if(ResponsiveBuilder.isDesktop(context))
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: FixedHeader(
              title: 'Produtos (${widget.products.length})',
              subtitle:
              'Adicione, pause ou ative os produtos.',
              actions: [
                DsButton(
                  label: 'Adicionar produto',
                  onPressed: widget.onAddProduct,
                )
              ],
            ),
          ),
        ),


        // Filtros que ficam FIXOS no topo
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverFilterBarDelegateProduct(
            height: persistentHeaderHeight, // Altura para acomodar os filtros e a barra de seleção
            child: Column(
              children: [
                ProductFilters(
                  searchController: _searchController,
                  sortOption: _sortOption,
                  onSortChanged: (value) {
                    if (value != null) setState(() => _sortOption = value);
                  },
                  onFilterTap: _showFilterBottomSheet,
                ),
                TableHeader(
                  selectedCount: _selectedProductIds.length,
                  isAllSelected: isAllSelected,
                  onSelectAll: () => _toggleSelectAll(filteredProducts),
                  onPause: () => _showConfirmationDialog(
                    title: 'Pausar produtos',
                    content: 'Tem certeza que deseja pausar os ${_selectedProductIds.length} produtos selecionados?',
                    confirmText: 'Pausar produtos',
                    onConfirm: () => context.read<StoresManagerCubit>().pauseProducts(_selectedProductIds.toList()),
                  ),
                  onActivate: () => _showConfirmationDialog(
                    title: 'Ativar produtos',
                    content: 'Tem certeza que deseja ativar os ${_selectedProductIds.length} produtos selecionados?',
                    confirmText: 'Ativar produtos',
                    onConfirm: () => context.read<StoresManagerCubit>().activateProducts(_selectedProductIds.toList()),
                  ),
                  onRemove: () => _showConfirmationDialog(
                    title: 'Remover produtos',
                    content: 'Esta ação não pode ser desfeita. Tem certeza que deseja remover os ${_selectedProductIds.length} produtos selecionados?',
                    confirmText: 'Sim, Remover',
                    isDestructive: true,
                    onConfirm: () => context.read<StoresManagerCubit>().removeProducts(_selectedProductIds.toList()),
                  ),
                  onAddToCategory: _showMoveToCategoryDialog,
                ),
               // const Divider(height: 1, thickness: 1),
              ],
            ),
          ),
        ),

        // Conteúdo da lista (Grid de cards)
        if (filteredProducts.isEmpty)
          SliverFillRemaining(
            child: NoResultsState(),
          )
        else
        // Substitua seu SliverPadding por este código mais limpo e automático

        // ✅ CÓDIGO CORRIGIDO (com SliverList)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(2, 16, 2, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final product = filteredProducts[index];
                  final isSelected = _selectedProductIds.contains(product.id);
                  // Adicionamos um Padding para criar o espaçamento vertical
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

