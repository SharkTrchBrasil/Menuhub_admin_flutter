import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/helpers/sidepanel.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/products/product.dart';
import 'package:totem_pro_admin/core/enums/category_type.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

import '../../pages/product_flavors/flavor_edit_panel.dart';
import '../../pages/products/widgets/product_panel.dart';

/// Exibe um painel lateral para editar um produto.
///
/// Este helper decide inteligentemente qual painel exibir (simples vs. sabor)
/// com base no TIPO da categoria pai do produto.
void showEditProductPanel({
  required BuildContext context,
  required Product product,
  required int storeId,
  Category? parentCategory,
  VoidCallback? onSaveSuccess,
}) {
  Category? resolvedParentCategory = parentCategory;

  // ✅ Se a categoria pai não foi fornecida, vamos encontrá-la
  if (resolvedParentCategory == null) {
    if (product.categoryLinks.isNotEmpty) {
      resolvedParentCategory = product.categoryLinks.first.category;
    }
  }

  // Se não encontrarmos nenhuma categoria, não podemos continuar
  if (resolvedParentCategory == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro Crítico: O produto não está associado a nenhuma categoria.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // ✅ Verifica o TIPO da categoria pai
  final bool isFlavor = resolvedParentCategory.type == CategoryType.CUSTOMIZABLE;

  // ✅ NOVO: Busca os dados da loja do StoresManagerCubit
  final storesManagerCubit = context.read<StoresManagerCubit>();
  final storesState = storesManagerCubit.state;

  if (storesState is! StoresManagerLoaded) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro: Dados da loja não carregados.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  final activeStore = storesState.activeStore;
  if (activeStore == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro: Loja ativa não encontrada.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // ✅ Extrai as listas necessárias
  final allStoreVariants = activeStore.relations.variants ?? [];
  final allStoreProducts = activeStore.relations.products ?? [];

  final Widget panelToOpen;

  if (isFlavor) {
    // Se é um sabor, ABRE O PAINEL DE EDIÇÃO DE SABOR
    panelToOpen = FlavorEditPanel(
      storeId: storeId,
      product: product,
      parentCategory: resolvedParentCategory,
      onSaveSuccess: () {
        Navigator.of(context).pop();
        onSaveSuccess?.call();
      },
      onCancel: () => Navigator.of(context).pop(),
    );
  } else {
    // ✅ CORRIGIDO: Passa os dados necessários para ProductEditPanel
    panelToOpen = ProductEditPanel(
      storeId: storeId,
      product: product,
      allStoreVariants: allStoreVariants, // ✅ Passa as variantes
      allStoreProducts: allStoreProducts, // ✅ Passa os produtos
      onSaveSuccess: () {
        Navigator.of(context).pop();
        onSaveSuccess?.call();
      },
      onCancel: () => Navigator.of(context).pop(),
    );
  }

  showResponsiveSidePanel(context, panelToOpen);
}