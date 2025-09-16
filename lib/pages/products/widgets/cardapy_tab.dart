
// Em: lib/pages/products/tabs/menu_content_tab.dart
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import '../../../core/extensions/colors.dart' as theme;
import 'category_card.dart';

import 'package:totem_pro_admin/pages/products/widgets/filter_bar.dart';
import '../../../core/responsive_builder.dart';

// O widget MenuContentTab agora é o ponto de entrada principal para esta aba
class MenuContentTab extends StatefulWidget {
  final List<Category> allCategories;
  final int storeId;
  final List<Product> allProducts;

  const MenuContentTab({
    super.key,
    required this.allCategories,
    required this.storeId,
    required this.allProducts,
  });

  @override
  State<MenuContentTab> createState() => _MenuContentTabState();
}

class _MenuContentTabState extends State<MenuContentTab> {
  final _searchController = TextEditingController();
  String _searchText = '';
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() => _searchText = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allCategories.isEmpty) {
      return _buildEmptyState();
    }


    // A lógica de filtro agora usa a lista limpa `widget.allProducts`
    final searchedProducts = _searchText.isEmpty
        ? widget.allProducts // Usa a lista correta
        : widget.allProducts.where((p) => p.name.toLowerCase().contains(_searchText)).toList();

    final categoryIdsWithMatchingProducts = searchedProducts
        .expand((product) => product.categoryLinks.map((link) => link.categoryId))
        .toSet();

    final List<Category> visibleCategories;
    if (_selectedCategory != null) {
      visibleCategories = [ _selectedCategory! ];
    } else if (_searchText.isNotEmpty) {
      visibleCategories = widget.allCategories.where((c) => categoryIdsWithMatchingProducts.contains(c.id)).toList();
    } else {
      visibleCategories = widget.allCategories;
    }

    final bool isMobile = ResponsiveBuilder.isMobile(context);
    final double headerHeight = isMobile ? 90.0 : 100.0;

    // ✅ ESTRUTURA PRINCIPAL ATUALIZADA PARA CUSTOMSCROLLVIEW
    return CustomScrollView(
      key: const PageStorageKey('menu_content_scroll'),
      slivers: [
        SliverPersistentHeader(
          pinned: true, // O filtro fica fixo no topo
          delegate: _SliverFilterDelegate(
            height: headerHeight,
            child: FilterBar(
              searchController: _searchController,
              categories: widget.allCategories,
              selectedValue: _selectedCategory,
              onAddCategory: _navigateToAddCategory,
              onReorder: (reordered) {/* TODO: Salvar nova ordem */},
              onCategoryChanged: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
          ),
        ),

        // CONTEÚDO DA LISTA
        if (visibleCategories.isEmpty)
          _buildNoResultsSliver()
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical:1 ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {

                  final category = visibleCategories[index];


                  final productsForCategory = category.productLinks
                      .map((link) => link.product)
                      .whereType<Product>()
                      .toList();


                  // Filtra os produtos da categoria se houver busca
                  final finalProducts = _searchText.isEmpty
                      ? productsForCategory
                      : productsForCategory.where((p) => p.name.toLowerCase().contains(_searchText)).toList();

                  if (_searchText.isNotEmpty && finalProducts.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CategoryCard(
                      storeId: widget.storeId,
                      category: category,
                      products: finalProducts,
                    ),
                  );
                },
                childCount: visibleCategories.length,
              ),
            ),
          ),
      ],
    );
  }

  void _navigateToAddCategory() {
    context.push('/stores/${widget.storeId}/categories/new');
  }

  void _handleReorder(List<Category> reorderedCategories) {
    print('Nova ordem salva!');
  }


  // Métodos de construção dos estados de "vazio" e "sem resultados"
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 24),
          const Text("Vamos criar seu cardápio!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text(
            "Comece adicionando a sua primeira categoria de produtos.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(

            onPressed: (){
              context.push('/stores/${widget.storeId}/categories/new');
            },
            icon: const Icon(Icons.add),
            label:  Text('Adicionar Primeira Categoria'),
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

  Widget _buildNoResultsSliver() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text("Nenhum item encontrado",
                style: TextStyle(fontSize: 18, color: Colors.grey[700])),
            const SizedBox(height: 8),
            const Text("Tente ajustar sua busca ou filtro.",
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }


}

// ✅ O DELEGATE AGORA É COMPARTILHADO E PODE SER MOVIDO PARA UM ARQUIVO DE WIDGETS
class _SliverFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverFilterDelegate({required this.child, required this.height});

  @override
  double get maxExtent => height;
  @override
  double get minExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: height,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverFilterDelegate oldDelegate) =>
      height != oldDelegate.height || child != oldDelegate.child;
}



// class MenuTabContainer extends StatelessWidget {
//   final List<Category> allCategories;
//
//   final int storeId;
//
//   const MenuTabContainer({
//     super.key,
//     required this.allCategories,
//
//     required this.storeId,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return NestedScrollView(
//       headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
//         // Esta é a parte de cima que rola e desaparece.
//         return <Widget>[
//           SliverOverlapAbsorber(
//             handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
//             sliver: SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Cardápio',
//                       style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Gerencie as categorias e produtos visíveis para seus clientes.',
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ];
//       },
//       // O corpo principal, que contém a lista e os filtros fixos.
//       body: Builder(
//         builder: (context) {
//           return MenuContentTab(
//             allCategories: allCategories,
//
//             storeId: storeId,
//           );
//         },
//       ),
//     );
//   }
// }
//
//
//
// class MenuContentTab extends StatefulWidget {
//   final List<Category> allCategories;
//
//   final int storeId;
//
//   const MenuContentTab({
//     super.key,
//     required this.allCategories,
//
//     required this.storeId,
//   });
//
//   @override
//   State<MenuContentTab> createState() => _MenuContentTabState();
// }
//
// class _MenuContentTabState extends State<MenuContentTab> {
//   final _searchController = TextEditingController();
//   String _searchText = '';
//   Category? _selectedCategory;
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(() {
//       if (mounted) {
//         setState(() => _searchText = _searchController.text.toLowerCase());
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     // ✅ CORREÇÃO 1: Filtra os produtos nulos ao criar a lista principal
//     final allProducts = widget.allCategories
//         .expand((category) => category.productLinks.map((link) => link.product))
//         .whereType<Product>() // ✨ ADICIONADO AQUI: Remove nulos e converte para List<Product>
//         .toList();
//
//
//
//     final searchedProducts = _searchText.isEmpty
//         ? allProducts
//         : allProducts
//         .where((p) => p.name.toLowerCase().contains(_searchText))
//         .toList();
//
//     final categoryIdsWithMatchingProducts = searchedProducts
//         .expand((product) => product.categoryLinks.map((link) => link.categoryId))
//         .toSet();
//
//     final List<Category> visibleCategories;
//     if (_selectedCategory != null) {
//       visibleCategories = [ _selectedCategory! ];
//     } else if (_searchText.isNotEmpty) {
//       visibleCategories = widget.allCategories
//           .where((c) => categoryIdsWithMatchingProducts.contains(c.id))
//           .toList();
//     } else {
//       // ✅ CORREÇÃO:
//       // Se não há filtro, mostra TODAS as categorias.
//       visibleCategories = widget.allCategories;
//     }
//
//
//
//     final bool isMobile = ResponsiveBuilder.isMobile(context);
//     final double headerHeight = isMobile ? 100.0 : 140.0;
//
//     return CustomScrollView(
//       key: const PageStorageKey('menu_content_scroll'),
//       primary: false,
//       slivers: [
//         SliverOverlapInjector(
//           handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
//         ),
//         SliverPersistentHeader(
//           pinned: true,
//           delegate: _MenuSliverFilterDelegate(
//             height: headerHeight,
//             child: FilterBar(
//               searchController: _searchController,
//               categories: widget.allCategories,
//               selectedValue: _selectedCategory,
//               onAddCategory: _navigateToAddCategory,
//               onReorder: _handleReorder,
//               onCategoryChanged: (category) {
//                 setState(() => _selectedCategory = category);
//               },
//             ),
//           ),
//         ),
//         if (visibleCategories.isEmpty)
//           _buildNoResultsSliver()
//         else
//           SliverPadding(
//             padding: EdgeInsets.fromLTRB(isMobile ? 14 : 24, 8, isMobile ? 14 : 24, 80),
//             sliver: SliverList(
//               delegate: SliverChildBuilderDelegate(
//                     (context, index) {
//                       final category = visibleCategories[index];
//
//                       // ✅ CORREÇÃO 2: Filtra os produtos nulos também na lista específica da categoria
//                       final allProductsInCategory = category.productLinks
//                           .map((link) => link.product)
//                           .whereType<Product>() // ✨ ADICIONADO AQUI TAMBÉM
//                           .toList();
//
//                       // 2. Aplica o filtro de busca de texto APENAS a essa lista.
//                       final productsForCategory = _searchText.isEmpty
//                           ? allProductsInCategory
//                           : allProductsInCategory
//                           .where((p) => p.name.toLowerCase().contains(_searchText))
//                           .toList();
//
//                       // =============================================================
//
//                       // ✅ CORREÇÃO DEFINITIVA APLICADA AQUI
//                       // Só esconda a categoria se uma busca estiver ativa E ela não tiver resultados.
//                       if (_searchText.isNotEmpty && productsForCategory.isEmpty) {
//                         return const SizedBox.shrink();
//                       }
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 16.0),
//                     child: CategoryCard(
//                       storeId: widget.storeId,
//                       category: category,
//                       products: productsForCategory,
//
//
//                     ),
//                   );
//                 },
//                 childCount: visibleCategories.length,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//
//
//   void _navigateToAddCategory() {
//     context.push('/stores/${widget.storeId}/categories/new');
//   }
//
//   void _handleReorder(List<Category> reorderedCategories) {
//     print('Nova ordem salva!');
//   }
//
//
//   // Métodos de construção dos estados de "vazio" e "sem resultados"
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
//           const SizedBox(height: 24),
//           const Text("Vamos criar seu cardápio!",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           const Text(
//             "Comece adicionando a sua primeira categoria de produtos.",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 16, color: Colors.grey),
//           ),
//           const SizedBox(height: 24),
//           ElevatedButton.icon(
//
//             onPressed: (){
//               context.push('/stores/${widget.storeId}/categories/new');
//             },
//             icon: const Icon(Icons.add),
//             label:  Text('Adicionar Primeira Categoria'),
//             style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: theme.primaryColor,
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNoResultsSliver() {
//     return SliverFillRemaining(
//       hasScrollBody: false,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
//             const SizedBox(height: 24),
//             Text("Nenhum item encontrado",
//                 style: TextStyle(fontSize: 18, color: Colors.grey[700])),
//             const SizedBox(height: 8),
//             const Text("Tente ajustar sua busca ou filtro.",
//                 style: TextStyle(fontSize: 16, color: Colors.grey)),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// // ✅ ETAPA 3: DELEGATE LOCAL E PRIVADO
// // Este delegate agora vive apenas neste arquivo, para melhor controle.
// class _MenuSliverFilterDelegate extends SliverPersistentHeaderDelegate {
//   final Widget child;
//   final double height;
//
//   _MenuSliverFilterDelegate({required this.child, required this.height});
//
//   @override
//   double get maxExtent => height;
//
//   @override
//   double get minExtent => height;
//
//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
//     // Correção para garantir que o container ocupe todo o espaço.
//     return Container(
//       height: height,
//       color: Theme.of(context).scaffoldBackgroundColor,
//       child: child,
//     );
//   }
//
//   @override
//   bool shouldRebuild(covariant _MenuSliverFilterDelegate oldDelegate) =>
//       height != oldDelegate.height || child != oldDelegate.child;
// }







