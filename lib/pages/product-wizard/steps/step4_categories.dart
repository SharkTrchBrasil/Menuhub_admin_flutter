import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/models/category.dart';

import 'package:totem_pro_admin/widgets/app_text_field.dart';

import '../../../../cubits/store_manager_state.dart';
import '../../../../models/prodcut_category_links.dart';
import '../../product_edit/widgets/category_link_wizard.dart';
import '../../product_groups/helper/side_panel_helper.dart';
import '../../products/widgets/product_categories_manager.dart';
import '../cubit/product_wizard_cubit.dart';
import '../cubit/product_wizard_state.dart';



class Step4Categories extends StatelessWidget {
  const Step4Categories({super.key});

  // ✅ 1. LÓGICA DE NAVEGAÇÃO MOVIDA PARA UM MÉTODO AUXILIAR LIMPO
  Future<void> _showAddCategoryWizard(BuildContext context) async {
    final wizardCubit = context.read<ProductWizardCubit>();
    final storesState = context.read<StoresManagerCubit>().state;

    // ✅ 2. VERIFICAÇÃO DE SEGURANÇA
    if (storesState is! StoresManagerLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Aguarde os dados da loja serem carregados.")),
      );
      return;
    }

    // ✅ 3. ACESSO SEGURO À LISTA DE CATEGORIAS
    final allCategories = storesState.activeStore?.relations.categories ?? [];

    final newLink = await showResponsiveSidePanelGroup<ProductCategoryLink>(
      context,
      panel: CategoryLinkWizard(
        product: wizardCubit.state.productInCreation,
        allCategories: allCategories,
      ),
    );

    if (newLink != null && context.mounted) {
      wizardCubit.addCategoryLink(newLink);
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

          onTogglePause: (ProductCategoryLink value) {  },
        );
      },
    );
  }

}

