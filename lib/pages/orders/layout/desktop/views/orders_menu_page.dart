import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/products/product.dart';
import 'package:totem_pro_admin/core/enums/category_type.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';

import '../../../../../widgets/fixed_header.dart';

class OrdersMenuPage extends StatefulWidget {
  const OrdersMenuPage({super.key});

  @override
  State<OrdersMenuPage> createState() => _OrdersMenuPageState();
}

class _OrdersMenuPageState extends State<OrdersMenuPage> {
  final TextEditingController _searchController = TextEditingController();
  Category? _selectedCategory;
  final Set<String> _loadingProducts = {}; // Para controlar loading de cada produto

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final store = state.activeStore;
        if (store == null) {
          return const Center(child: Text('Nenhuma loja selecionada'));
        }

        final allCategories = store.relations.categories;
        final allProducts = store.relations.products;

        return Container(
color: Colors.white,
          child: Column(
            children: [
              _buildHeader(context, store, allCategories),
              Expanded(
                child: _buildContent(allCategories, allProducts, store.core.id!),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════
  Widget _buildHeader(BuildContext context, dynamic store, List<Category> categories) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,

      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FixedHeader(
            title: 'Cardápio',
            subtitle: 'Gerencie a disponibilidade dos itens rapidamente',
            actions: [
              DsButton(
                label: 'Gestão completa',
                onPressed: () => context.go('/stores/${store.core.id}/products'),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSearchField(),
              ),
              const SizedBox(width: 12),
              if (categories.isNotEmpty) _buildCategoryDropdown(categories),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Buscar item do cardápio',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {});
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(List<Category> categories) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Category?>(
          hint: Text('Todas as categorias', style: TextStyle(color: Colors.grey.shade700)),
          value: _selectedCategory,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
          items: [
            const DropdownMenuItem<Category?>(
              value: null,
              child: Text('Todas as categorias'),
            ),
            ...categories.map((cat) => DropdownMenuItem<Category?>(
              value: cat,
              child: Text(cat.name, overflow: TextOverflow.ellipsis),
            )),
          ],
          onChanged: (category) => setState(() => _selectedCategory = category),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CONTEÚDO PRINCIPAL
  // ═══════════════════════════════════════════════════════════
  Widget _buildContent(List<Category> allCategories, List<Product> allProducts, int storeId) {
    if (allCategories.isEmpty) {
      return _buildEmptyState();
    }

    final searchText = _searchController.text.toLowerCase();
    final searchedProducts = searchText.isEmpty
        ? allProducts
        : allProducts.where((p) => p.name.toLowerCase().contains(searchText)).toList();

    final categoryIdsWithMatchingProducts = searchedProducts
        .expand((product) => product.categoryLinks.map((link) => link.categoryId))
        .toSet();

    final List<Category> visibleCategories;
    if (_selectedCategory != null) {
      visibleCategories = [_selectedCategory!];
    } else if (searchText.isNotEmpty) {
      visibleCategories = allCategories
          .where((c) => categoryIdsWithMatchingProducts.contains(c.id))
          .toList();
    } else {
      visibleCategories = allCategories;
    }

    if (visibleCategories.isEmpty) {
      return _buildNoResults();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: visibleCategories.length,
      itemBuilder: (context, index) {
        final category = visibleCategories[index];
        final productIdsInCategory = category.productLinks.map((link) => link.productId).toSet();

        final productsForCategory = allProducts
            .where((p) => productIdsInCategory.contains(p.id))
            .toList();

        final finalProducts = searchText.isEmpty
            ? productsForCategory
            : productsForCategory
            .where((p) => p.name.toLowerCase().contains(searchText))
            .toList();

        if (searchText.isNotEmpty && finalProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildCategorySection(category, finalProducts, storeId);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SEÇÃO DE CATEGORIA
  // ═══════════════════════════════════════════════════════════
  Widget _buildCategorySection(Category category, List<Product> products, int storeId) {
    final activeCount = products.where((p) {
      final link = p.categoryLinks.firstWhereOrNull((l) => l.categoryId == category.id);
      return link?.isAvailable ?? false;
    }).length;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: const Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header da categoria
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),

                      ],
                    ),
                  ),

                  Text(
                    '${products.length} ${products.length == 1 ? 'item' : 'itens'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),

                 // _buildStatusBadge(activeCount, products.length),



                ],
              ),
            ),

            // Lista de produtos
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(height: 20),
              itemBuilder: (_, index) => _buildProductTile(products[index], category, storeId),
            ),
          ],
        ),
      ),
    );
  }


  // ═══════════════════════════════════════════════════════════
  // TILE DE PRODUTO
  // ═══════════════════════════════════════════════════════════
  Widget _buildProductTile(Product product, Category category, int storeId) {
    final link = product.categoryLinks.firstWhereOrNull((l) => l.categoryId == category.id);
    final isAvailable = link?.isAvailable ?? false;
    final hasImage = product.images.isNotEmpty;
    final productKey = '${product.id}_${category.id}';
    final isLoading = _loadingProducts.contains(productKey);

    // ✅ Lógica de preço correta extraída do category_card
    String displayPriceText;
    if (category.type == CategoryType.CUSTOMIZABLE) {
      final sizeGroup = category.optionGroups
          .firstWhereOrNull((g) => g.minSelection == 1 && g.maxSelection == 1);

      final activeOptionIds = sizeGroup != null
          ? {for (var item in sizeGroup.items.where((i) => i.isActive)) item.id}
          : <int?>{};

      final activePrices = product.prices
          .where((price) => price.price > 0 && activeOptionIds.contains(price.sizeOptionId))
          .map((price) => price.price)
          .toList();

      if (activePrices.isNotEmpty) {
        final minPrice = activePrices.reduce((a, b) => a < b ? a : b);
        final formattedPrice = (minPrice / 100).toStringAsFixed(2).replaceAll('.', ',');
        displayPriceText = 'R\$ $formattedPrice';
      } else {
        displayPriceText = 'Preço indisponível';
      }
    } else {
      final priceInCents = link?.price ?? product.price ?? 0;
      if (priceInCents > 0) {
        final formattedPrice = (priceInCents / 100).toStringAsFixed(2).replaceAll('.', ',');
        displayPriceText = 'R\$ $formattedPrice';
      } else {
        displayPriceText = 'Sem preço';
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xFFFFFFFF) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Imagem
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: hasImage
                ? Image.network(
              product.images.first.url ?? '',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
            )
                : _buildPlaceholderImage(),
          ),

          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isAvailable ? const Color(0xFF1A1A1A) : Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (product.description != null && product.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),

                Row(
                  children: [
                    if (category.type == CategoryType.CUSTOMIZABLE)
                      const Text('À partir de ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                     displayPriceText,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Toggle com loading
          Column(
            children: [
              if (isLoading)
                const SizedBox(
                  width: 48,
                  height: 31,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                Switch(
                  value: isAvailable,
                  onChanged: (value) => _toggleProductAvailability(
                    storeId: storeId,
                    product: product,
                    category: category,
                    newAvailability: value,
                  ),

                ),
              const SizedBox(height: 4),
              Text(
                isAvailable ? 'Ativo' : 'Pausado',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isAvailable ? Colors.green[700] : Colors.orange[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TOGGLE AVAILABILITY
  // ═══════════════════════════════════════════════════════════
  Future<void> _toggleProductAvailability({
    required int storeId,
    required Product product,
    required Category category,
    required bool newAvailability,
  }) async {
    final productKey = '${product.id}_${category.id}';

    setState(() {
      _loadingProducts.add(productKey);
    });

    try {
      await getIt<ProductRepository>().toggleLinkAvailability(
        storeId: storeId,
        productId: product.id!,
        categoryId: category.id!,
        isAvailable: newAvailability,
      );

      if (mounted) {
        // Força atualização do StoresManagerCubit para recarregar os dados
      //  context.read<StoresManagerCubit>().refreshActiveStore();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newAvailability
                  ? '${product.name} foi ativado'
                  : '${product.name} foi pausado',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: newAvailability ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar disponibilidade: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingProducts.remove(productKey);
        });
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════

  Widget _buildPlaceholderImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(Icons.restaurant, color: Colors.grey[400], size: 32),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'Nenhum produto cadastrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Acesse a Gestão Completa para adicionar produtos',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'Nenhum resultado encontrado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tente buscar por outro termo ou ajuste o filtro',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}