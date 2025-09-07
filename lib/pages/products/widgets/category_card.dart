import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_list_item.dart';
import 'package:totem_pro_admin/repositories/category_repository.dart';
import 'package:totem_pro_admin/services/dialog_service.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import '../../../core/di.dart';
import '../../../core/responsive_builder.dart';
import 'package:bot_toast/bot_toast.dart';

import '../../categories/widgets/category_card_header.dart';
import '../../categories/widgets/empty_category.dart';


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

  // ✨ 2. Lógica para salvar o nome editado
  Future<void> _saveCategoryName() async {
    if (_nameController.text.trim().isEmpty || _nameController.text == widget.category.name) {
      setState(() => _isEditingName = false);
      return;
    }

    final updatedCategory = widget.category.copyWith(name: _nameController.text.trim());
    final result = await getIt<CategoryRepository>().updateCategory(widget.storeId, updatedCategory);

    result.fold(
          (error) => BotToast.showText(text: "Erro ao salvar: $error"),
          (success) {
        BotToast.showText(text: "Categoria atualizada!");

      },
    );
    setState(() => _isEditingName = false);
  }

  // Lógica para pausar/ativar a categoria
  Future<void> _toggleCategoryStatus() async {
    // 1. Cria uma cópia da categoria com o status invertido
    final updatedCategory = widget.category.copyWith(active: !widget.category.active);

    // Mostra um feedback de carregamento
    BotToast.showLoading();

    // 2. Chama o repositório para salvar a mudança no backend
    final result = await getIt<CategoryRepository>().updateCategory(widget.storeId, updatedCategory);

    BotToast.closeAllLoading();

    result.fold(
          (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
        }
      },
          (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Status da categoria atualizado!")));
          // 3. Avisa o Cubit global para atualizar a UI de todo o app

        }
      },
    );
  }


  Future<void> _deleteCategory(BuildContext context, int storeId, Category category) async {
    final confirmed = await DialogService.showConfirmationDialog(
      context,
      title: 'Confirmar Exclusão',
      content: 'Tem certeza que deseja excluir a categoria "${category.name}"?',
    );

    if (confirmed == true && context.mounted) {
      BotToast.showLoading();
      final result = await getIt<CategoryRepository>().deleteCategory(storeId, category.id!);
      BotToast.closeAllLoading();

      result.fold(
            (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir: error'), backgroundColor: Colors.red));
          }
        },
            (success) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Categoria "${category.name}" excluída.')));
            // Avisa o Cubit global para atualizar a UI

          }
        },
      );
    }
  }




  // Em _CategoryCardState

  void _navigateToAddItem() async { // ✨ 1. Transforma o método em async
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
    context.push('/stores/${widget.storeId}/categories/${widget.category.id}', extra: widget.category);
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
            onDeleteCategory: () => _deleteCategory(context, widget.storeId, widget.category),
          ),

          // A lista de produtos
          Padding(
            padding: const EdgeInsets.all(16.0),
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
                  // Encontra o link específico para esta categoria
                  final link = product.categoryLinks.firstWhere(
                        (link) => link.categoryId == widget.category.id,
                  );
                  priceForThisCategory = link.price; // Pega o preço do link
                } catch (e) {
                  // Se não encontrar (caso raro), usa o preço base ou 0 como fallback
                  priceForThisCategory = product.price ?? 0;
                }
                // ✅ --- FIM DA LÓGICA ---






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



