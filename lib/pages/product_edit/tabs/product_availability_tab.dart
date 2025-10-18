import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/products/prodcut_category_links.dart';
import 'package:totem_pro_admin/pages/product_edit/cubit/edit_product_cubit.dart';
import 'package:totem_pro_admin/pages/product_groups/helper/side_panel_helper.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_categories_manager.dart';
import 'package:totem_pro_admin/core/enums/bulk_action_type.dart';
import 'package:totem_pro_admin/pages/categories_bulk/BulkCategoryPage.dart';

// ✅ PASSO 1: O NOME DA CLASSE FOI CORRIGIDO
// Renomeado de 'ProductPricingTab' para 'ProductAvailabilityTab'
class ProductAvailabilityTab extends StatelessWidget {
  const ProductAvailabilityTab({super.key});

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

    final newLinks = await showResponsiveSidePanelGroup<List<ProductCategoryLink>>(
      context,
      panel: BulkAddToCategoryWizard(
        storeId: storesState.activeStore!.core.id!,
        selectedProducts: [editCubit.state.editedProduct],
        allCategories: allCategories,
        actionType: BulkActionType.add,
      ),
    );

    if (newLinks != null && newLinks.isNotEmpty && context.mounted) {
      // Adiciona todos os links retornados pelo wizard
      for (final link in newLinks) {
        editCubit.addCategoryLink(link);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ PASSO 2: ESTE WIDGET CONTINUA USANDO EditProductCubit, O QUE ESTÁ CORRETO
    // PARA O FLUXO DE EDIÇÃO.
    return BlocBuilder<EditProductCubit, EditProductState>(
      builder: (context, state) {
        final cubit = context.read<EditProductCubit>();

        // Usa o widget reutilizável, conectando-o ao EditProductCubit
        return ProductCategoriesManager(
          categoryLinks: state.editedProduct.categoryLinks,
          onAddCategory: () => _showAddCategoryWizard(context),
          onUpdateLink: cubit.updateCategoryLink,
          onRemoveLink: cubit.removeCategoryLink,
          // Conecta o callback ao método correto no cubit de edição.
          onTogglePause: cubit.togglePauseInCategory,
        );
      },
    );
  }
}