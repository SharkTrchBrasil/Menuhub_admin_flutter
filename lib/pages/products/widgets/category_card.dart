import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/pages/product-wizard/product_creation_panel.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_list_item.dart';
import 'package:totem_pro_admin/services/dialog_service.dart';
import '../../../core/enums/category_type.dart';
import '../../../core/helpers/sidepanel.dart';
import '../../../cubits/store_manager_cubit.dart';
import '../../../models/products/product.dart';
import '../../categories/widgets/category_card_header.dart';
import '../../categories/widgets/empty_category.dart';
import '../../product_flavors/flavor_creation_panel.dart';
import '../cubit/products_cubit.dart';
import '../../categories/category_panel.dart';

class CategoryCard extends StatefulWidget {
  final int storeId;
  final Category category;
  final List<Product> products;

  const CategoryCard({
    super.key,
    required this.storeId,
    required this.category,
    required this.products,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _isEditingName = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategoryName() {
    if (_nameController.text.trim().isEmpty || _nameController.text == widget.category.name) {
      setState(() => _isEditingName = false);
      return;
    }
    context.read<ProductsCubit>().updateCategoryName(
      widget.storeId,
      widget.category,
      _nameController.text,
    );
    setState(() => _isEditingName = false);
  }

  void _toggleCategoryStatus() {
    context.read<ProductsCubit>().toggleCategoryStatus(widget.storeId, widget.category);
  }

  Future<void> _deleteCategory() async {
    final confirmed = await DialogService.showConfirmationDialog(
      context,
      title: 'Confirmar Exclusão',
      content: 'Tem certeza que deseja excluir a categoria "${widget.category.name}"?',
    );
    if (confirmed == true && context.mounted) {
      context.read<ProductsCubit>().deleteCategory(widget.storeId, widget.category);
    }
  }

  void _openAddItemPanel() {
    final bool isCustomizable = widget.category.type == CategoryType.CUSTOMIZABLE;
    final Widget panelToOpen = isCustomizable
        ? FlavorCreationPanel(
      storeId: widget.storeId,
      category: widget.category,
      onSaveSuccess: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sabor criado com sucesso!"), backgroundColor: Colors.green),
        );
      },
      onCancel: () => Navigator.of(context).pop(),
    )
        : ProductCreationPanel(
      storeId: widget.storeId,
      category: widget.category,
      onSaveSuccess: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Produto criado com sucesso!"), backgroundColor: Colors.green),
        );
      },
      onCancel: () => Navigator.of(context).pop(),
    );
    showResponsiveSidePanel(context, panelToOpen);
  }

  void _navigateToEditCategory() {
    showResponsiveSidePanel(
      context,
      CategoryPanel(
        storeId: widget.storeId,
        category: widget.category,
        onSaveSuccess: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: const Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          CategoryCardHeader(
            category: widget.category,
            productCount: widget.products.length,
            isEditingName: _isEditingName,
            nameController: _nameController,
            onEditName: () => setState(() => _isEditingName = true),
            onSaveName: _saveCategoryName,
            onCancelEditName: () {
              _nameController.text = widget.category.name;
              setState(() => _isEditingName = false);
            },
            onAddItem: _openAddItemPanel,
            onToggleStatus: _toggleCategoryStatus,
            onEditCategory: _navigateToEditCategory,
            onDeleteCategory: _deleteCategory,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.products.isEmpty
                ? EmptyCategoryCardContent(onAddItem: _openAddItemPanel)
                : ListView.separated(
              itemCount: widget.products.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final product = widget.products[index];
                String displayPriceText;

                // ✅ --- INÍCIO DA LÓGICA DE PREÇO CORRIGIDA ---
                if (widget.category.type == CategoryType.CUSTOMIZABLE) {
                  // 1. Encontra o grupo de tamanhos na categoria.
                  final sizeGroup = widget.category.optionGroups
                      .firstWhereOrNull((g) => g.minSelection == 1 && g.maxSelection == 1);

                  // 2. Cria um mapa de ID da opção para o status de disponibilidade.
                  final activeOptionIds = sizeGroup != null
                      ? {for (var item in sizeGroup.items.where((i) => i.isActive)) item.id}
                      : <int?>{};

                  // 3. Filtra os preços do produto para incluir apenas aqueles
                  //    que são maiores que zero E pertencem a uma opção ATIVA.
                  final activePrices = product.prices
                      .where((price) => price.price > 0 && activeOptionIds.contains(price.sizeOptionId))
                      .map((price) => price.price)
                      .toList();

                  if (activePrices.isNotEmpty) {
                    final minPrice = activePrices.reduce((a, b) => a < b ? a : b);
                    final formattedPrice = (minPrice / 100).toStringAsFixed(2).replaceAll('.', ',');
                    displayPriceText = 'R\$ $formattedPrice';
                  } else {
                    displayPriceText = 'Preço indisponível';
                  }
                } else {
                  // Lógica para categorias gerais (continua a mesma e está correta)
                  final link = product.categoryLinks.firstWhereOrNull(
                        (link) => link.categoryId == widget.category.id,
                  );
                  final priceInCents = link?.price ?? product.price ?? 0;
                  if (priceInCents > 0) {
                    final formattedPrice = (priceInCents / 100).toStringAsFixed(2).replaceAll('.', ',');
                    displayPriceText = 'R\$ $formattedPrice';
                  } else {
                    displayPriceText = 'Preço a definir';
                  }
                }
                // ✅ --- FIM DA LÓGICA DE PREÇO CORRIGIDA ---

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ProductListItem(
                    key: ValueKey(product.id),
                    storeId: widget.storeId,
                    product: product,
                    parentCategory: widget.category,
                    displayPriceText: displayPriceText,
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
            ),
          ),
        ],
      ),
    );
  }
}