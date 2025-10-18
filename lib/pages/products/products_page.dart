import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/pages/categories/category_panel.dart';

import 'package:totem_pro_admin/pages/products/widgets/cardapy_tab.dart';
import 'package:totem_pro_admin/pages/product-wizard/product_creation_panel.dart';
import 'package:totem_pro_admin/pages/products/widgets/sliver_persistent_header_delegate.dart';
import 'package:totem_pro_admin/pages/products/widgets/universal_filter_bar.dart';
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

  // ✅ CONTROLLERS SEPARADOS POR TAB
  final _searchControllerCardapio = TextEditingController();
  final _searchControllerProdutos = TextEditingController();
  final _searchControllerComplementos = TextEditingController();

  Category? _selectedCategory;


  @override
  void initState() {
    super.initState();
    final tabCount = widget.isInWizard ? 1 : 3;
    _tabController = TabController(length: tabCount, vsync: this);
    _tabController.addListener(() {
      if (mounted && _tabController.indexIsChanging) {
        setState(() => _currentTabIndex = _tabController.index);
        // ✅ LIMPA SELEÇÃO DE CATEGORIA AO TROCAR DE TAB
        setState(() => _selectedCategory = null);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchControllerCardapio.dispose();
    _searchControllerProdutos.dispose();
    _searchControllerComplementos.dispose();
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


  void _navigateToCreateCategory() {
    showResponsiveSidePanel(
      context,
      CategoryPanel(
          storeId: widget.storeId,
          onSaveSuccess: () {
            Navigator.of(context).pop();
          }
      ),
    );
  }



  void _openAddItemPanel() {


    final Widget panelToOpen =
    ProductCreationPanel(
      storeId: widget.storeId,
      onSaveSuccess: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produto criado com sucesso!"), backgroundColor: Colors.green),
        );

      },
      onCancel: () => Navigator.of(context).pop(),
    );

    showResponsiveSidePanel(context, panelToOpen);
  }



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
                        delegate: SliverPersistentHeaderDelegateWrapper(
                          minHeight: 28,
                          maxHeight: 28,
                          child: PageTabBar(
                            controller: _tabController,
                            isInWizard: widget.isInWizard,
                          ),
                        ),
                      ),

                      // ✅ FILTRO APENAS PARA ABA CARDÁPIO
                      if (_currentTabIndex == 0 && allCategories.isNotEmpty)
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: SliverPersistentHeaderDelegateWrapper(
                            minHeight: 64,
                            maxHeight: 64,
                            child: UniversalFilterBar(
                              searchController: _searchControllerCardapio,
                              searchHint: 'Buscar item no cardápio',
                              customFilterWidget: _buildCategoryDropdown(allCategories),
                              desktopActions: [
                                DsButton(
                                  label: 'Adicionar Categoria',
                                  style: DsButtonStyle.secondary,
                                  onPressed: _navigateToCreateCategory,
                                ),
                              ],
                              onMobileFilterTap: () => _showCategoryFilterSheet(context, allCategories),
                            ),
                          ),
                        ),
                    ];
                  },
                  body: Column(
                    children: [
                      // ✅ DIVIDER APENAS PARA ABA CARDÁPIO
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
                              searchText: _searchControllerCardapio.text,
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

  Widget _buildCategoryDropdown(List<Category> categories) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Category?>(
          hint: const Text('Todas'),
          value: _selectedCategory,
          isExpanded: true,
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

  void _showCategoryFilterSheet(BuildContext context, List<Category> categories) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Filtrar por Categoria',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: const Text('Todas as categorias'),
                  selected: _selectedCategory == null,
                  onTap: () {
                    setState(() => _selectedCategory = null);
                    Navigator.pop(ctx);
                  },
                ),
                ...categories.map((cat) => ListTile(
                  title: Text(cat.name),
                  selected: _selectedCategory?.id == cat.id,
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    Navigator.pop(ctx);
                  },
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}