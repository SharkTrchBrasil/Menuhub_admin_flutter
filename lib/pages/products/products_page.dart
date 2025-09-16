import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/pages/products/widgets/cardapy_tab.dart';
import 'package:totem_pro_admin/pages/products/widgets/complement_tab.dart';
// Renomeado de cardapy_tab
import 'package:totem_pro_admin/pages/products/widgets/page_header.dart';
import 'package:totem_pro_admin/pages/products/widgets/page_tab.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_tab.dart';

import 'package:totem_pro_admin/widgets/dot_loading.dart';

import '../../core/di.dart';
import '../../core/responsive_builder.dart';

import '../../repositories/category_repository.dart';
import '../../repositories/product_repository.dart';

import 'cubit/products_cubit.dart';


class CategoryProductPage extends StatefulWidget {
  final int storeId;
  const CategoryProductPage({super.key, required this.storeId});

  @override
  State<CategoryProductPage> createState() => CategoryProductPageState();
}

class CategoryProductPageState extends State<CategoryProductPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }




  Future<bool> hasContent() async {
    // ...
    final state = context
        .read<StoresManagerCubit>()
        .state;
    if (state is StoresManagerLoaded) {
      final hasCategories =
          state.activeStore?.relations.categories.isNotEmpty ?? false;
      if (!hasCategories && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Você precisa criar pelo menos uma categoria para finalizar.'),
              backgroundColor: Colors.orange),
        );
      }
      return hasCategories;
    }
    return false;
  }

  void _navigateToCreateCategory() {
    context.pushNamed(
      'category-new',
      pathParameters: {'storeId': widget.storeId.toString()},
    );
  }

  void _navigateToCreateProduct() {
    // O nome da rota pode ser 'product-new' ou 'product-create',
    // verifique o nome exato que você definiu no seu AppRouter.
    context.pushNamed(
      'product-create',
      pathParameters: {'storeId': widget.storeId.toString()},
    );
  }


  @override
  Widget build(BuildContext context) {
    final bool isMobile = ResponsiveBuilder.isMobile(context);
    final double appBarHeight = isMobile ? 40.0 : 80.0;

    // ✅ PASSO 1: FORNEÇA O CUBIT DE AÇÕES NO TOPO DA ÁRVORE DE WIDGETS DA TELA.
    return BlocProvider(
      create: (context) =>
          ProductsCubit(
            categoryRepository: getIt<CategoryRepository>(),
            // Se o ProductsCubit também for gerenciar produtos, adicione o repositório aqui:
             productRepository: getIt<ProductRepository>(),
          ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          floatingActionButton: isMobile
              ? FloatingActionButton(
            // A navegação para criar continua sendo uma ação de UI, o que está correto.
            onPressed: _navigateToCreateCategory,
            child: const Icon(Icons.add),
          )
              : null,
          // ✅ PASSO 2: ADICIONE O LISTENER PARA GERENCIAR O FEEDBACK VISUAL
          //    DE FORMA CENTRALIZADA PARA TODAS AS AÇÕES.
          body: BlocListener<ProductsCubit, ProductsState>(
            listener: (context, state) {



              if (state is ProductsActionSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message),
                      backgroundColor: Colors.green),
                );
              }
              else if (state is ProductsActionFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(state.error), backgroundColor: Colors.red),
                );
              }
            },


            child: BlocBuilder<StoresManagerCubit, StoresManagerState>(



              builder: (context, state) {
                if (state is! StoresManagerLoaded) {
                  return const Center(child: DotLoading());
                }

                final allCategories = state.activeStore?.relations.categories ??
                    [];
                final allProducts = state.activeStore?.relations.products ?? [];
                final allVariants = state.activeStore?.relations.variants ?? [];

                // O restante da sua lógica de UI continua exatamente igual...
                return NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return <Widget>[
                      SliverOverlapAbsorber(
                        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context),
                        sliver: SliverAppBar(
                          expandedHeight: appBarHeight,
                          backgroundColor: Theme
                              .of(context)
                              .scaffoldBackgroundColor,
                          foregroundColor: Theme
                              .of(context)
                              .colorScheme
                              .onBackground,
                          automaticallyImplyLeading: false,
                          flexibleSpace: FlexibleSpaceBar(
                            background: PageHeader(),
                            collapseMode: CollapseMode.pin,
                          ),
                          bottom: PageTabBar(),
                        ),
                      ),
                    ];
                  },
                  body: TabBarView(
                    children: [
                      MenuContentTab(
                        allCategories: allCategories,
                        storeId: widget.storeId,
                        allProducts: allProducts,
                      ),
                      ProductListTab(
                        storeId: widget.storeId,
                        products: allProducts,
                        allCategories: allCategories,
                        onAddProduct: _navigateToCreateProduct,
                      ),
                      VariantsTab(
                          variants: allVariants, storeId: widget.storeId),
                    ],
                  ),
                );
              },






            ),
          ),
        ),
      ),
    );
  }
}

// ✅ NOVO DELEGATE APENAS PARA A TABBAR
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final PageTabBar tabBar;

  const _SliverTabBarDelegate({required this.tabBar});

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor, // Garante um fundo sólido
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}