
// Substitua o conteúdo do seu arquivo da aba "Cardápio" por este código completo.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/pages/products/widgets/category_card.dart';
import 'package:totem_pro_admin/pages/products/widgets/filter_bar.dart';
import '../../../core/responsive_builder.dart';
import '../../../themes/ds_theme_switcher.dart';
import '../../../core/extensions/colors.dart' as theme;


// ✅ ETAPA 1: WIDGET PRINCIPAL DA ABA
// Este é o widget que você deve colocar na sua TabBarView.
class MenuTabContainer extends StatelessWidget {
  final List<Category> allCategories;
  final List<Product> allProducts;
  final int storeId;

  const MenuTabContainer({
    super.key,
    required this.allCategories,
    required this.allProducts,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        // Esta é a parte de cima que rola e desaparece.
        return <Widget>[
          SliverOverlapAbsorber(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            sliver: SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cardápio',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gerencie as categorias e produtos visíveis para seus clientes.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      // O corpo principal, que contém a lista e os filtros fixos.
      body: Builder(
        builder: (context) {
          return MenuContent(
            allCategories: allCategories,
            allProducts: allProducts,
            storeId: storeId,
          );
        },
      ),
    );
  }
}


// ✅ ETAPA 2: CONTEÚDO DO SCROLL INTERNO
// Este widget agora é usado exclusivamente dentro do `body` do NestedScrollView.
class MenuContent extends StatefulWidget {
  final List<Category> allCategories;
  final List<Product> allProducts;
  final int storeId;

  const MenuContent({
    super.key,
    required this.allCategories,
    required this.allProducts,
    required this.storeId,
  });

  @override
  State<MenuContent> createState() => _MenuContentState();
}

class _MenuContentState extends State<MenuContent> {
  final _searchController = TextEditingController();
  String _searchText = '';
  Category? _selectedCategory;

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

// Em lib/pages/products/widgets/menu_content.dart

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<DsThemeSwitcher>().theme;

    // 1. Filtrar produtos pelo texto da busca (esta parte não muda)
    final searchedProducts = _searchText.isEmpty
        ? widget.allProducts
        : widget.allProducts
        .where((p) => p.name.toLowerCase().contains(_searchText))
        .toList();

    // 2. Lógica para decidir quais CATEGORIAS serão visíveis
    final List<Category> visibleCategories;
    if (_selectedCategory != null) {
      // Se um filtro de categoria está ativo, mostra apenas ela
      visibleCategories = widget.allCategories
          .where((c) => c.id == _selectedCategory!.id)
          .toList();
    } else if (_searchText.isNotEmpty) {
      // ✅ CORREÇÃO 1: Lógica de busca por texto
      // Se estamos buscando, precisamos encontrar todas as categorias
      // que contêm os produtos encontrados na busca.

      // Usamos `expand` para achatar a lista de listas de categorias de cada produto
      // e `map` para pegar o ID de cada categoria vinculada.
      final categoryIdsWithMatchingProducts = searchedProducts
          .expand((product) => product.categoryLinks.map((link) => link.category.id))
          .toSet(); // `.toSet()` remove duplicatas

      visibleCategories = widget.allCategories
          .where((c) => categoryIdsWithMatchingProducts.contains(c.id))
          .toList();
    } else {
      // Se não há filtro, mostra todas as categorias
      visibleCategories = widget.allCategories;
    }

    if (widget.allCategories.isEmpty) {
      return _buildEmptyState();
    }

    final bool isMobile = ResponsiveBuilder.isMobile(context);
    final double headerHeight = isMobile ? 100.0 : 140.0;

    return CustomScrollView(
      key: const PageStorageKey('menu_content_scroll'),
      primary: false,
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _MenuSliverFilterDelegate(
            height: headerHeight,
            child: FilterBar(
              searchController: _searchController,
              categories: widget.allCategories,
              selectedValue: _selectedCategory,
              onAddCategory: _navigateToAddCategory,
              onReorder: _handleReorder,
              onCategoryChanged: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
          ),
        ),
        if (visibleCategories.isEmpty)
          _buildNoResultsSliver()
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(isMobile ? 14 : 24, 8, isMobile ? 14 : 24, 80),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final category = visibleCategories[index];

                      final productsForCategory = searchedProducts
                          .where((p) => p.categoryLinks.any((link) => link.category.id == category.id))
                          .toList();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: CategoryCard(
                      storeId: widget.storeId,
                      category: category,
                      products: productsForCategory,
                      totalProductCount: widget.allProducts.length,
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
    context.push('/stores/${widget.storeId}/categories');
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
            // A ação de navegar agora deve ser pega do widget pai se necessário
            // ou gerenciada de outra forma (ex: via Cubit/Bloc)
            onPressed: (){
              // Exemplo: context.read<NavigationCubit>().goToCreateCategory();
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


// ✅ ETAPA 3: DELEGATE LOCAL E PRIVADO
// Este delegate agora vive apenas neste arquivo, para melhor controle.
class _MenuSliverFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _MenuSliverFilterDelegate({required this.child, required this.height});

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    // Correção para garantir que o container ocupe todo o espaço.
    return Container(
      height: height,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _MenuSliverFilterDelegate oldDelegate) =>
      height != oldDelegate.height || child != oldDelegate.child;
}







