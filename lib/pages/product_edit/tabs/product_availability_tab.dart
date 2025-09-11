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

    final newLink = await showResponsiveSidePanelGroup<ProductCategoryLink>(
      context,
      panel: CategoryLinkWizard(
        // Passa o produto que está sendo editado
        product: editCubit.state.editedProduct,
        allCategories: allCategories,
      ),
    );

    if (newLink != null && context.mounted) {
      // Chama o método do EditProductCubit
      editCubit.addCategoryLink(newLink);
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