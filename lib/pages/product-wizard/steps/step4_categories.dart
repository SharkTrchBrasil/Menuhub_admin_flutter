import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/models/category.dart';

import 'package:totem_pro_admin/widgets/app_text_field.dart';

import '../../../../cubits/store_manager_state.dart';
import '../../../../models/prodcut_category_links.dart';
import '../../../core/enums/bulk_action_type.dart';
import '../../categories/BulkCategoryPage.dart';
import '../../product_edit/widgets/category_link_wizard.dart';
import '../../product_groups/helper/side_panel_helper.dart';
import '../../products/widgets/product_categories_manager.dart';
import '../cubit/product_wizard_cubit.dart';
import '../cubit/product_wizard_state.dart';



class Step4Categories extends StatelessWidget {
  const Step4Categories({super.key});

  Future<void> _showAddCategoryWizard(BuildContext context) async {
    final wizardCubit = context.read<ProductWizardCubit>();
    final storesState = context.read<StoresManagerCubit>().state;

    if (storesState is! StoresManagerLoaded) {
      // ... (verificação de segurança)
      return;
    }

    final allCategories = storesState.activeStore?.relations.categories ?? [];

    // ✅ 1. MUDE O TIPO DE RETORNO ESPERADO AQUI
    // Antes: <ProductCategoryLink>
    // Agora: <List<ProductCategoryLink>>
    final newLinks = await showResponsiveSidePanelGroup<List<ProductCategoryLink>>(
      context,
      panel: BulkAddToCategoryWizard(
        storeId: storesState.activeStore!.core.id!,
        selectedProducts: [wizardCubit.state.productInCreation],
        allCategories: allCategories,
        actionType: BulkActionType.add, // Informa que a ação é de adicionar
      ),
    );

    // ✅ 2. ATUALIZE A LÓGICA PARA LIDAR COM A LISTA
    // Verificamos se a lista não é nula e não está vazia
    if (newLinks != null && newLinks.isNotEmpty && context.mounted) {
      // Como neste fluxo só adicionamos um link, pegamos o primeiro da lista
      wizardCubit.addCategoryLink(newLinks.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductWizardCubit, ProductWizardState>(
      builder: (context, state) {
        final cubit = context.read<ProductWizardCubit>();

        // A tela agora só precisa construir o widget reutilizável e conectar os fios
        return ProductCategoriesManager(
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

