import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/helpers/sidepanel.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/products/product.dart';
import 'package:totem_pro_admin/core/enums/category_type.dart'; // ✅ 1. Importar o enum de tipo de categoria

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
  Category? parentCategory, // A categoria pai, se já for conhecida (ex: clicando em um produto dentro de uma categoria)
  VoidCallback? onSaveSuccess,
}) {
  Category? resolvedParentCategory = parentCategory;

  // ✅ 2. LÓGICA CORRIGIDA: Se a categoria pai não foi fornecida, vamos encontrá-la.
  // Um "sabor" geralmente tem apenas um link de categoria, que é sua categoria customizável.
  if (resolvedParentCategory == null) {
    if (product.categoryLinks.isNotEmpty) {
      // Pega a categoria do primeiro link como fallback.
      // Em um cenário ideal, o produto teria um `primaryCategoryId` para desambiguação.
      resolvedParentCategory = product.categoryLinks.first.category;
    }
  }

  // Se, mesmo após a busca, não encontrarmos nenhuma categoria, não podemos continuar.
  if (resolvedParentCategory == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Erro Crítico: O produto não está associado a nenhuma categoria.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  // ✅ 3. A DECISÃO FINAL E CORRETA:
  // Verificamos o TIPO da categoria pai resolvida.
  final bool isFlavor = resolvedParentCategory.type == CategoryType.CUSTOMIZABLE;

  final Widget panelToOpen;

  if (isFlavor) {
    // Se é um sabor, ABRE O PAINEL DE EDIÇÃO DE SABOR
    panelToOpen = FlavorEditPanel(
      storeId: storeId,
      product: product,
      parentCategory: resolvedParentCategory, // Passamos a categoria que encontramos
      onSaveSuccess: () {
        Navigator.of(context).pop();
        onSaveSuccess?.call();
      },
      onCancel: () => Navigator.of(context).pop(),
    );
  } else {
    // Se não é um sabor (ou seja, pertence a uma categoria GENERAL),
    // ABRE O PAINEL DE EDIÇÃO DE PRODUTO SIMPLES.
    panelToOpen = ProductEditPanel(
      storeId: storeId,
      product: product,
      onSaveSuccess: () {
        Navigator.of(context).pop();
        onSaveSuccess?.call();
      },
      onCancel: () => Navigator.of(context).pop(),
    );
  }

  showResponsiveSidePanel(context, panelToOpen);
}