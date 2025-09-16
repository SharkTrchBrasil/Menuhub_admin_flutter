import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/prodcut_category_links.dart';
import 'package:totem_pro_admin/pages/product_edit/cubit/edit_product_cubit.dart';
import 'package:totem_pro_admin/pages/product_edit/widgets/category_link_wizard.dart';
import 'package:totem_pro_admin/pages/product_groups/helper/side_panel_helper.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_categories_manager.dart';

import '../../../core/enums/bulk_action_type.dart';
import '../../categories/BulkCategoryPage.dart';

// Sugestão: Renomeie a classe para refletir sua função
class ProductPricingTab extends StatelessWidget {
  const ProductPricingTab({super.key});

  // Este método agora usa o EditProductCubit
  Future<void> _showAddCategoryWizard(BuildContext context) async {
    final editCubit = context.read<EditProductCubit>();
    final storesState = context.read<StoresManagerCubit>().state;

    if (storesState is! StoresManagerLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aguarde os dados da loja serem carregados.")),
      );
      return;
    }

    final allCategories = storesState.activeStore?.relations.categories ?? [];

    // ✅ 1. CORREÇÃO APLICADA AQUI: ESPERA UMA LISTA
    final newLinks = await showResponsiveSidePanelGroup<List<ProductCategoryLink>>(
      context,
      panel: BulkAddToCategoryWizard(
        storeId: storesState.activeStore!.core.id!,
        selectedProducts: [editCubit.state.editedProduct],
        allCategories: allCategories,
        actionType: BulkActionType.add,
      ),
    );

    // ✅ 2. CORREÇÃO APLICADA AQUI: TRATA O RESULTADO COMO UMA LISTA
    if (newLinks != null && newLinks.isNotEmpty && context.mounted) {
      // Como neste fluxo só adicionamos um link, pegamos o primeiro da lista.
      editCubit.addCategoryLink(newLinks.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ouve o EditProductCubit
    return BlocBuilder<EditProductCubit, EditProductState>(
      builder: (context, state) {
        final cubit = context.read<EditProductCubit>();

        // Usa o widget reutilizável, conectando-o ao EditProductCubit
        return ProductCategoriesManager(
          categoryLinks: state.editedProduct.categoryLinks,
          onAddCategory: () => _showAddCategoryWizard(context),
          onUpdateLink: cubit.updateCategoryLink,
          onRemoveLink: cubit.removeCategoryLink,
          onTogglePause: (ProductCategoryLink value) {  },
        );
      },
    );
  }
}