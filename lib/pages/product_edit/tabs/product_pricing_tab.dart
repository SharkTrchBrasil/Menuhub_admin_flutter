import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/models/products/prodcut_category_links.dart';

import '../../../core/enums/bulk_action_type.dart';
import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';
import '../../categories_bulk/BulkCategoryPage.dart';

// 1. IMPORTE O CUBIT E ESTADO CORRETOS
import '../cubit/edit_product_cubit.dart';
// (Remova os imports do ProductWizardCubit e ProductWizardState)

import '../../product_groups/helper/side_panel_helper.dart';
import '../../products/widgets/product_categories_manager.dart';
import '../widgets/category_link_wizard.dart';

class ProductPricingTab extends StatelessWidget {
  const ProductPricingTab({super.key});

  Future<void> _showAddCategoryWizard(BuildContext context) async {
    // 2. LEIA O CUBIT CORRETO
    final editCubit = context.read<EditProductCubit>();
    final storesState = context.read<StoresManagerCubit>().state;

    if (storesState is! StoresManagerLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aguarde os dados da loja serem carregados.")),
      );
      return;
    }

    final allCategories = storesState.activeStore?.relations.categories ?? [];

    final newLink = await showResponsiveSidePanelGroup<ProductCategoryLink>(
      context,
      panel: BulkAddToCategoryWizard(
        storeId: storesState.activeStore!.core.id!,
        // 3. PASSE O PRODUTO EM EDIÇÃO, NÃO O PRODUTO EM CRIAÇÃO
        selectedProducts: [editCubit.state.editedProduct],
        allCategories: allCategories,
        actionType: BulkActionType.add,
      ),
    );

    if (newLink != null && context.mounted) {
      // 4. CHAME O MÉTODO DO EDITCUBIT
      // (Certifique-se que este método exista no seu EditProductCubit)
      editCubit.addCategoryLink(newLink);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 5. USE O BLOCBUILDER DO CUBIT CORRETO
    return BlocBuilder<EditProductCubit, EditProductState>(
      // Opcional: otimize o buildWhen se precisar
      buildWhen: (prev, current) =>
      prev.editedProduct.categoryLinks != current.editedProduct.categoryLinks,
      builder: (context, state) {
        // 6. LEIA O CUBIT CORRETO
        final cubit = context.read<EditProductCubit>();

        // A tela agora só precisa construir o widget reutilizável e conectar os fios
        return ProductCategoriesManager(
          // 7. USE OS DADOS DO ESTADO CORRETO
          categoryLinks: state.editedProduct.categoryLinks ?? [],
          onAddCategory: () => _showAddCategoryWizard(context),

          // 8. CERTIFIQUE-SE QUE SEU EDITPRODUCTCUBIT TENHA ESTES MÉTODOS
          onUpdateLink: cubit.updateCategoryLink,
          onRemoveLink: cubit.removeCategoryLink,
          onTogglePause: (ProductCategoryLink value) {  },
        );
      },
    );
  }
}