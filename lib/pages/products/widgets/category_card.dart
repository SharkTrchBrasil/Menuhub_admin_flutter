import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_list_item.dart';

import 'package:totem_pro_admin/services/dialog_service.dart';

import '../../categories/widgets/category_card_header.dart';
import '../../categories/widgets/empty_category.dart';
import '../cubit/products_cubit.dart';


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
  // ✨ 1. Estado para controlar a edição do nome
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
    // A validação continua aqui, pois é controle de UI
    if (_nameController.text.trim().isEmpty || _nameController.text == widget.category.name) {
      setState(() => _isEditingName = false);
      return;
    }
    // Delega a ação para o Cubit
    context.read<ProductsCubit>().updateCategoryName(
      widget.storeId,
      widget.category,
      _nameController.text,
    );
    // A UI local é atualizada imediatamente
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
      // Apenas notifica o Cubit sobre a intenção de deletar
      context.read<ProductsCubit>().deleteCategory(widget.storeId, widget.category);
    }
  }




  void _navigateToAddItem() async {
    // 2. Espera o resultado da navegação (a tela do wizard)
    final result = await context.push<bool>(
      '/stores/${widget.storeId}/products/create',
      extra: widget.category,
    );

    // 3. Reage ao resultado DEPOIS que a tela do wizard foi fechada
    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Produto criado com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _navigateToEditCategory() {

    context.goNamed(
      'category-edit', // Chama a rota de edição pelo nome
      pathParameters: {
        'storeId': widget.storeId.toString(),
        'categoryId': widget.category.id.toString(),
      },
      extra: widget.category, // Continuamos enviando o 'extra' para o carregamento rápido!
    );


  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // ✨ 3. O cabeçalho agora é um widget separado e mais rico
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
            onAddItem: _navigateToAddItem,
            onToggleStatus: _toggleCategoryStatus,
            onEditCategory: _navigateToEditCategory,
            onDeleteCategory: () => _deleteCategory(),
          ),

          // A lista de produtos
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: widget.products.isEmpty
                ? EmptyCategoryCardContent(onAddItem: _navigateToAddItem)
                : ListView.separated(
              itemCount: widget.products.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final product = widget.products[index];

                // ✅ --- A LÓGICA PARA ENCONTRAR O PREÇO CORRETO VIVE AQUI ---
                int priceForThisCategory = 0;
                try {


                  // ✅ --- LÓGICA ROBUSTA PARA ENCONTRAR O PREÇO ---
// Usa 'firstWhereOrNull' que retorna o link ou `null` se não encontrar. Não lança exceção.
                  final link = product.categoryLinks.firstWhereOrNull(
                        (link) => link.categoryId == widget.category.id,
                  );

// Se o link não for encontrado (o produto não pertence a esta categoria),
// podemos simplesmente não renderizar o item ou mostrar um preço padrão.
                  final int priceForThisCategory = link?.price ?? product.price ?? 0;
// ✅ --- FIM DA LÓGICA ---


                } catch (e) {
                  // Se não encontrar (caso raro), usa o preço base ou 0 como fallback
                  priceForThisCategory = product.price ?? 0;
                }






                return Container(
                  decoration: BoxDecoration(
                   // color: widget.category.active ? const Color(0xFFF5F5F5) :const Color(0xFFFFFFFF)  ,
                    borderRadius: BorderRadius.circular(8),
                 //   border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: ProductListItem(
                    key: ValueKey(product.id),
                    storeId: widget.storeId,
                    product: product,
                    parentCategory: widget.category,
                    displayPrice: priceForThisCategory,

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



