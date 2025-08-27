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

import '../../cubits/scaffold_ui_cubit.dart';


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
  @override
  void initState() {
    super.initState();
    // ✅ É AQUI QUE A MÁGICA ACONTECE!
    // Ao iniciar a tela, avisamos ao AppShell para NÃO construir uma AppBar.
    // Usamos addPostFrameCallback para garantir que o Cubit já exista no contexto.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScaffoldUiCubit>().setAppBar(null);
    });
  }
  Future<bool> hasContent() async {
    // ...
    final state = context.read<StoresManagerCubit>().state;
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
    context.push('/stores/${widget.storeId}/categories');
  }


  void _navigateToCreateProduct() {
    context.push('/stores/${widget.storeId}/products/new');
  }
  void _navigateToCreateVariant() {
    context.push('/stores/${widget.storeId}/variants/new');
  }

  @override
  Widget build(BuildContext context) {



    return DefaultTabController(
      length: 3,
      child: Scaffold(

        body: BlocBuilder<StoresManagerCubit, StoresManagerState>(
          builder: (context, state) {
            if (state is! StoresManagerLoaded) {
              return const Center(child: DotLoading());
            }

            final allCategories = state.activeStore?.relations.categories ?? [];
            final allProducts = state.activeStore?.relations.products ?? [];
            final allVariants = state.activeStore?.relations.variants ?? []; // ✅ Obtenha os variants
            return NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                // ✅ ESTRUTURA DO CABEÇALHO CORRIGIDA E MAIS ROBUSTA
                return <Widget>[
                  SliverOverlapAbsorber(
                    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                    sliver: SliverAppBar(
                      // Usamos uma SliverAppBar invisível para agrupar os cabeçalhos
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      foregroundColor: Theme.of(context).colorScheme.onBackground,
                      pinned: true, // A TabBar será fixada
                      automaticallyImplyLeading: false,
                      // O conteúdo que rola para cima (seu PageHeader)
                      flexibleSpace: FlexibleSpaceBar(
                        background: PageHeader(),
                        collapseMode: CollapseMode.pin,
                      ),
                      // A parte de baixo da AppBar, que será a TabBar
                      bottom: PageTabBar(),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  MenuContent(
                    allCategories: allCategories,
                    allProducts: allProducts,
                    storeId: widget.storeId,
                  ),
                  ProductListView(
                    storeId: widget.storeId,
                    products: allProducts,
                    allCategories: allCategories,
                    onAddProduct: _navigateToCreateProduct,
                  ),
                  // ✅ Conecte o novo widget aqui
                  VariantsTabView(variants: allVariants, storeId: widget.storeId,),

                ],
              ),
            );
          },
        ),
        floatingActionButton: Builder(builder: (context) {
          final tabIndex = DefaultTabController.of(context).index;
          if (tabIndex == 0) { // Aba Cardápio
            return FloatingActionButton(
              onPressed: _navigateToCreateCategory,
              tooltip: 'Adicionar Categoria',
              child: const Icon(Icons.add),
            );
          }
          if (tabIndex == 1) { // Aba Produtos
            return SizedBox.shrink();
          }
          if (tabIndex == 2) { // ✅ Aba Complementos
            return FloatingActionButton(
              onPressed: _navigateToCreateVariant,
              tooltip: 'Adicionar Grupo de Complementos',
              child: const Icon(Icons.add),
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    );
  }
}


