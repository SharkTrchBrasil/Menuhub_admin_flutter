import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/pages/products/widgets/category_card.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_search_bar.dart';
import 'package:totem_pro_admin/repositories/category_repository.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/constdata/app_colors.dart';
import 'package:totem_pro_admin/services/dialog_service.dart';
import 'package:totem_pro_admin/services/subscription/subscription_service.dart';

import '../../core/responsive_builder.dart';
import '../../widgets/appbarcode.dart';

class CategoryProductPage extends StatefulWidget {
  final int storeId;

  const CategoryProductPage({super.key, required this.storeId});

  @override
  // ✅ TORNAR A CLASSE STATE PÚBLICA (REMOVER O '_')
  State<CategoryProductPage> createState() => CategoryProductPageState();
}

// ✅ CLASSE DE ESTADO PÚBLICA
class CategoryProductPageState extends State<CategoryProductPage> {
  final _searchController = TextEditingController();
  String _searchText = '';
  String? _selectedCategoryId; // Alterado para usar o ID da categoria

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ MÉTODO PÚBLICO QUE O WIZARD VAI CHAMAR
  // Ele verifica se o passo foi "concluído", ou seja, se existe ao menos uma categoria.
  Future<bool> hasContent() async {
    final state = context.read<StoresManagerCubit>().state;
    if (state is StoresManagerLoaded) {
      final hasCategories = state.activeStore?.relations.categories.isNotEmpty ?? false;
      if (!hasCategories) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Você precisa criar pelo menos uma categoria para finalizar.'), backgroundColor: Colors.orange),
        );
      }
      return hasCategories;
    }
    return false; // Se o estado não estiver carregado, considera como não concluído.
  }

  // ✅ FUNÇÃO PARA NAVEGAR PARA A TELA DE CRIAÇÃO
  void _navigateToCreateCategory() {
    // Navega para a página de criação que já projetamos.
    // Adapte a rota se for diferente no seu GoRouter.
    context.go('/stores/${widget.storeId}/categories');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: BlocBuilder<StoresManagerCubit, StoresManagerState>(
        builder: (context, state) {
          if (state is! StoresManagerLoaded) {
            return const Scaffold(body: Center(child: DotLoading()));
          }

          final allCategories = state.activeStore?.relations.categories ?? [];
          final allProducts = state.activeStore?.relations.products ?? [];

          // --- Lógica de Filtros ---
          final searchedProducts =
              _searchText.isEmpty
                  ? allProducts
                  : allProducts
                      .where((p) => p.name.toLowerCase().contains(_searchText))
                      .toList();

          final filteredProducts =
              _selectedCategoryId == null
                  ? searchedProducts
                  : searchedProducts
                      .where(
                        (p) => p.category?.id.toString() == _selectedCategoryId,
                      )
                      .toList();

          final visibleCategoryIds =
              filteredProducts.map((p) => p.category?.id).toSet();
          final visibleCategories =
              allCategories
                  .where(
                    (c) =>
                        _searchText.isEmpty && _selectedCategoryId == null
                            ? true
                            : visibleCategoryIds.contains(c.id),
                  )
                  .toList();


          return Scaffold(
            // ✅ DETALHE: AppBar condicional para aparecer só no mobile

            backgroundColor: Colors.white,
            // ✅ CORREÇÃO PRINCIPAL: Substitua o Padding por este bloco
            body: Center(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final isMobile = constraints.maxWidth < 600;

                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 0 : 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isMobile ? double.infinity : 1000,
                      ),
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: SizedBox(height: 30),
                          ),

                          // 1. Cabeçalho da Página (não fixo)
                          SliverToBoxAdapter(
                            child: Padding(
                              // O padding interno agora controla o espaçamento no mobile
                              padding: const EdgeInsets.fromLTRB(
                                24.0,
                                24.0,
                                24.0,
                                0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Cardápio da Loja',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Edite e controle os itens que compõem o seu cardápio digital.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color:Colors.grey
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),

                          // 2. Barra de Filtros (FIXA NO TOPO AO ROLAR)
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _SliverFilterBarDelegate(
                              child: FilterBar(
                                searchController: _searchController,
                                categories: allCategories,
                                selectedValue: _selectedCategoryId,
                                onCategoryChanged: (categoryId) {
                                  setState(() {
                                    _selectedCategoryId = categoryId;
                                  });
                                },
                              ),
                            ),
                          ),


                          if (visibleCategories.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false, // Importante para o Center funcionar bem
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Ícone para dar um apelo visual
                                      Icon(
                                        Icons.location_city_outlined,
                                        size: 80,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 24),

                                      // O mesmo texto de antes
                                      Text(
                                        _searchText.isNotEmpty ||
                                            _selectedCategoryId != null
                                            ? "Nenhum item encontrado com os filtros aplicados."
                                            : "Você ainda não tem categorias cadastradas.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 24),

                                      // O botão que chama a função para adicionar uma nova cidade
                                      ElevatedButton.icon(
                                        onPressed: _navigateToCreateCategory, // Chama a mesma função do FAB
                                        icon: const Icon(Icons.add),
                                        label: const Text('Adicionar Primeira Cidade'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),









                          // Lógica do estado vazio
                          if (allCategories.isEmpty) // Verificação simplificada
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.category_outlined, size: 80, color: Colors.grey[400]),
                                    const SizedBox(height: 24),
                                    const Text(
                                      "Vamos criar seu cardápio!",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      "Comece adicionando a sua primeira categoria de produtos.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 24),

                                    // ✅ BOTÃO CORRIGIDO
                                    ElevatedButton.icon(
                                      onPressed: _navigateToCreateCategory, // Chama a função de navegação
                                      icon: const Icon(Icons.add),
                                      label: const Text('Adicionar Primeira Categoria'),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )




                          else
                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(
                                24.0,
                                16.0,
                                24.0,
                                24.0,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final category = visibleCategories[index];
                                  final productsForCategory =
                                      filteredProducts
                                          .where(
                                            (p) =>
                                                p.category?.id == category.id,
                                          )
                                          .toList();
                                  return CategoryCard(
                                    storeId: widget.storeId,
                                    category: category,
                                    products: productsForCategory,
                                    totalProductCount: allProducts.length,
                                  );
                                }, childCount: visibleCategories.length),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ✅ ADICIONE O FLOATINGACTIONBUTTON AQUI
            floatingActionButton:
                ResponsiveBuilder.isMobile(context)
                    ? FloatingActionButton(
                      onPressed: () {
                        // Navega para a tela de criação de um novo produto
                        // Adapte a rota se necessário
                        context.go('/stores/${widget.storeId}/products/new');
                      },
                      child: const Icon(Icons.add),
                    )
                    : null, // Não mostra o FAB no desktop
          );
        },
      ),
    );
  }
}

// DELEGATE PARA O SLIVERPERSISTENTHEADER
class _SliverFilterBarDelegate extends SliverPersistentHeaderDelegate {
  final FilterBar child;

  _SliverFilterBarDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      // Cor de fundo para quando a barra estiver flutuando
      child: child,
    );
  }

  @override
  double get maxExtent => 80.0; // Altura total da barra de filtro com padding

  @override
  double get minExtent => 80.0; // Altura da barra quando fixada no topo

  @override
  bool shouldRebuild(covariant _SliverFilterBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
