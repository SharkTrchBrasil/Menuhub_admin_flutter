import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/products/prodcut_category_links.dart';
import 'package:totem_pro_admin/pages/product_groups/helper/side_panel_helper.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_categories_manager.dart';
import 'package:totem_pro_admin/core/enums/bulk_action_type.dart';
import 'package:totem_pro_admin/pages/categories_bulk/BulkCategoryPage.dart';

// ✅ USA O WIZARD CUBIT AO INVÉS DO EDIT CUBIT
import '../cubit/product_wizard_cubit.dart';
import '../cubit/product_wizard_state.dart';

class WizardPricingTab extends StatelessWidget {
  const WizardPricingTab({super.key});

  Future<void> _showAddCategoryWizard(BuildContext context) async {
    // ✅ USA O WIZARD CUBIT
    final wizardCubit = context.read<ProductWizardCubit>();
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
        // ✅ USA O PRODUTO DO WIZARD
        selectedProducts: [wizardCubit.state.productInCreation],
        allCategories: allCategories,
        actionType: BulkActionType.add,
      ),
    );

    if (newLinks != null && newLinks.isNotEmpty && context.mounted) {
      for (final link in newLinks) {
        wizardCubit.addCategoryLink(link);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ USA O BLOC BUILDER DO WIZARD
    return BlocBuilder<ProductWizardCubit, ProductWizardState>(
      builder: (context, state) {
        final cubit = context.read<ProductWizardCubit>();

        return ProductCategoriesManager(
          // ✅ USA OS DADOS DO WIZARD STATE
          categoryLinks: state.categoryLinks,
          onAddCategory: () => _showAddCategoryWizard(context),
          onUpdateLink: cubit.updateCategoryLink,
          onRemoveLink: cubit.removeCategoryLink,
          onTogglePause: cubit.toggleLinkAvailability,
        );
      },
    );
  }
}