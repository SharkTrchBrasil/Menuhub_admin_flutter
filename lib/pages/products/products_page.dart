import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/pages/categories/category_panel.dart';
// ✅ 1. IMPORT DO FILTER_BAR NECESSÁRIO AQUI AGORA
import 'package:totem_pro_admin/pages/products/widgets/filter_bar.dart';
import 'package:totem_pro_admin/pages/products/widgets/cardapy_tab.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_creation_panel.dart';
import 'package:totem_pro_admin/pages/products/widgets/sliver_persistent_header_delegate.dart';
import 'package:totem_pro_admin/pages/variants/tabs/complement_tab.dart';
import 'package:totem_pro_admin/pages/products/widgets/page_tab.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_tab.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/models/category.dart';


import '../../core/helpers/sidepanel.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/product_repository.dart';
import '../variants/cubits/variants_tab_cubit.dart';
import 'cubit/products_cubit.dart';

class CategoryProductPage extends StatefulWidget {
  final int storeId;
  final bool isInWizard;

  const CategoryProductPage({
    super.key,
    required this.storeId,
    this.isInWizard = false,
  });

  @override
  State<CategoryProductPage> createState() => CategoryProductPageState();
}

class CategoryProductPageState extends State<CategoryProductPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  // ✅ 2. ESTADO PARA O FILTRO MOVIDO PARA CÁ
  final _searchController = TextEditingController();
  Category? _selectedCategory;


  @override
  void initState() {
    super.initState();
    final tabCount = widget.isInWizard ? 1 : 3;
    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(() {
      if (mounted && _tabController.indexIsChanging) {
        setState(() => _currentTabIndex = _tabController.index);
      }
    });
    // O listener do searchController pode ficar aqui para forçar a reconstrução
    _searchController.addListener(() {
      if(mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> hasContent() async {
    final state = context.read<StoresManagerCubit>().state;
    if (state is StoresManagerLoaded) {
      final hasCategories = state.activeStore?.relations.categories.isNotEmpty ?? false;
      if (!hasCategories && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Você precisa criar pelo menos uma categoria para finalizar.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return hasCategories;
    }
    return false;
  }


  // Em CategoryProductPageState dentro de products_page.dart

  void _navigateToCreateCategory() {
    showResponsiveSidePanel( // Supondo que você tenha uma função assim
      context,
      CategoryPanel(
          storeId: widget.storeId,
          // Não passa categoria, indicando que é uma criação
          onSaveSuccess: () {
            Navigator.of(context).pop(); // Fecha o painel

          }
      ),
    );
  }



  void _openAddItemPanel() {


    final Widget panelToOpen =
    ProductCreationPanel(
      storeId: widget.storeId,
      onSaveSuccess: () {
        Navigator.of(context).pop(); // Fecha o painel
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produto criado com sucesso!"), backgroundColor: Colors.green),
        );

      },
      onCancel: () => Navigator.of(context).pop(),
    );

    // Abre o painel escolhido
    showResponsiveSidePanel(context, panelToOpen);
  }



// ... imports e código anterior ...

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductsCubit(
        categoryRepository: getIt<CategoryRepository>(),
        productRepository: getIt<ProductRepository>(),
      ),
      child: Scaffold(
        body: BlocListener<ProductsCubit, ProductsState>(
          listener: (context, state) {
            if (state is ProductsActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.green));
            } else if (state is ProductsActionFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error), backgroundColor: Colors.red));
            }
          },
          child: BlocBuilder<StoresManagerCubit, StoresManagerState>(
            builder: (context, state) {
              if (state is! StoresManagerLoaded) {
                return const Center(child: DotLoading());
              }

              final allCategories = state.activeStore?.relations.categories ?? [];
              final allProducts = state.activeStore?.relations.products ?? [];

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: ResponsiveBuilder.isDesktop(context) ? 24: 14.0),
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: FixedHeader(
                          showActionsOnMobile: true,
                          title: 'Cardápio',
                          subtitle: 'Gerencie suas categorias, produtos e complementos.',
                          actions: [
                            if(!ResponsiveBuilder.isDesktop(context))
                              DsButton(
                                label: 'Adicionar',
                                style: DsButtonStyle.secondary,
                                onPressed: _openAddItemPanel,
                              )
                          ],
                        ),
                      ),
                      SliverPersistentHeader(
                     //   pinned: true,
                        delegate: SliverPersistentHeaderDelegateWrapper(
                          minHeight: 28,
                          maxHeight: 28,
                          child: PageTabBar(
                            controller: _tabController,
                            isInWizard: widget.isInWizard,
                          ),
                        ),
                      ),
                      // ✅ 5. FILTERBAR MOVIDO PARA CÁ, COMO UM SLIVER PINNED
                      if (_currentTabIndex == 0 && allCategories.isNotEmpty)
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: SliverPersistentHeaderDelegateWrapper(
                            minHeight: 100,
                            maxHeight: 100,
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 1.0),
                              child: FilterBar(
                                searchController: _searchController,
                                categories: allCategories,
                                selectedValue: _selectedCategory,
                                onAddCategory: _navigateToCreateCategory,
                                onReorder: (reordered) { /* TODO */ },
                                onCategoryChanged: (category) {
                                  setState(() => _selectedCategory = category);
                                },
                              ),
                            ),
                          ),
                        ),
                    ];
                  },
                  body: Column(
                    children: [
                      // ✅ DIVIDER QUE ROLA JUNTO COM O CONTEÚDO
                      if (_currentTabIndex == 0 && allCategories.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18.0),
                          child: Container(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            child: const Divider(height: 1),
                          ),
                        ),
                      // ✅ CONTEÚDO DAS TABS
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            MenuContentTab(
                              allCategories: allCategories,
                              storeId: widget.storeId,
                              allProducts: allProducts,
                              searchText: _searchController.text,
                              selectedCategory: _selectedCategory,
                              onNavigateToAddCategory: _navigateToCreateCategory,
                            ),
                            if (!widget.isInWizard)
                              ProductListTab(
                                storeId: widget.storeId,
                                products: allProducts,
                                allCategories: allCategories,
                                onAddProduct: _openAddItemPanel,
                              ),
                            if (!widget.isInWizard)
                              BlocProvider<VariantsTabCubit>(
                                create: (context) {
                                  final allMasterVariants = state.activeStore?.relations.variants ?? [];
                                  final usedVariantIds = allProducts.expand((p) => p.variantLinks ?? []).map((l) => l.variant.id).toSet();
                                  final linkedVariants = allMasterVariants.where((v) => usedVariantIds.contains(v.id)).toList();
                                  linkedVariants.sort((a, b) => a.name.compareTo(b.name));
                                  return VariantsTabCubit(
                                    initialVariants: linkedVariants,
                                    productRepository: getIt<ProductRepository>(),
                                    storeId: widget.storeId,
                                  );
                                },
                                child: VariantsTab(storeId: widget.storeId),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }


}