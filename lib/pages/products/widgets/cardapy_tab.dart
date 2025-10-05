import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/models/category.dart';

import '../../../core/extensions/colors.dart' as theme;
import '../../../models/products/product.dart';
import 'category_card.dart';

class MenuContentTab extends StatelessWidget {
  final List<Category> allCategories;
  final int storeId;
  final List<Product> allProducts;
  // ✅ 1. RECEBE OS DADOS DE FILTRO DO PAI
  final String searchText;
  final Category? selectedCategory;
  final VoidCallback onNavigateToAddCategory;

  const MenuContentTab({
    super.key,
    required this.allCategories,
    required this.storeId,
    required this.allProducts,
    required this.searchText,
    this.selectedCategory,
    required this.onNavigateToAddCategory,
  });

  @override
  Widget build(BuildContext context) {
    if (allCategories.isEmpty) {
      return _buildEmptyState();
    }

    // Lógica de filtro agora usa os parâmetros recebidos
    final searchedProducts = searchText.isEmpty
        ? allProducts
        : allProducts.where((p) => p.name.toLowerCase().contains(searchText.toLowerCase())).toList();

    final categoryIdsWithMatchingProducts = searchedProducts
        .expand((product) => product.categoryLinks.map((link) => link.categoryId))
        .toSet();

    final List<Category> visibleCategories;
    if (selectedCategory != null) {
      visibleCategories = [selectedCategory!];
    } else if (searchText.isNotEmpty) {
      visibleCategories = allCategories.where((c) => categoryIdsWithMatchingProducts.contains(c.id)).toList();
    } else {
      visibleCategories = allCategories;
    }

    // ✅ 2. REMOVIDO O `COLUMN` E O `FILTERBAR`. USA SÓ O LISTVIEW.
    return visibleCategories.isEmpty
        ? _buildNoResults()
        : ListView.builder(
    //  padding: const EdgeInsets.all(16.0), // Padding geral para a lista
      itemCount: visibleCategories.length,
      itemBuilder: (context, index) {
        final category = visibleCategories[index];
        final productIdsInCategory = category.productLinks.map((link) => link.productId).toSet();
        final productsForCategory = allProducts.where((p) => productIdsInCategory.contains(p.id)).toList();
        final finalProducts = searchText.isEmpty
            ? productsForCategory
            : productsForCategory.where((p) => p.name.toLowerCase().contains(searchText.toLowerCase())).toList();

        if (searchText.isNotEmpty && finalProducts.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: CategoryCard(
            storeId: storeId,
            category: category,
            products: finalProducts,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          const Text("Vamos criar seu cardápio!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Comece adicionando a sua primeira categoria de produtos.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            // ✅ 3. USA O CALLBACK RECEBIDO
            onPressed: onNavigateToAddCategory,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Primeira Categoria'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: theme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
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
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          Text("Nenhum item encontrado", style: TextStyle(fontSize: 18, color: Colors.grey[700])),
          const SizedBox(height: 8),
          const Text("Tente ajustar sua busca ou filtro.", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }
}