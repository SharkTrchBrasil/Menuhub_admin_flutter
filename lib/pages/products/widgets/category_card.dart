import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_list_item.dart';

import '../../../constdata/app_colors.dart';
import '../../../core/di.dart';
import '../../../cubits/store_manager_cubit.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../repositories/category_repository.dart';
import '../../../services/dialog_service.dart';
import '../../../services/subscription/subscription_service.dart';
import '../products_page.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_list_item.dart';

import '../../../constdata/app_colors.dart';
import '../../../core/di.dart';
import '../../../core/responsive_builder.dart';
import '../../../cubits/store_manager_cubit.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../repositories/category_repository.dart';
import '../../../services/dialog_service.dart';
import '../../../services/subscription/subscription_service.dart';
import '../products_page.dart';


class CategoryCard extends StatelessWidget {
  final int storeId;
  final Category category;
  final List<Product> products;
  final int totalProductCount;

  const CategoryCard({
    super.key,
    required this.storeId,
    required this.category,
    required this.products,
    required this.totalProductCount,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ CORREÇÃO: Lógica do menu movida para uma variável
    final Widget menuWidget;
    if (ResponsiveBuilder.isDesktop(context)) {
      // No desktop, o widget é o PopupMenuButton
      menuWidget = _buildDesktopPopupMenu(context);
    } else {
      // No mobile, o widget é um IconButton que CHAMA a função
      menuWidget = IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showCategoryActionSheet(context),
      );
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: const Color(0xFFF5F5F5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Aumentei um pouco o padding para melhor visualização
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${category.name} (${products.length} ${products.length == 1 ? "item" : "itens"})',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark), // Aumentei a fonte
                  ),
                ),
                // ✅ A variável com o widget correto é inserida aqui
                menuWidget,
              ],
            ),

            // Lista de produtos construída dinamicamente
            if (products.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'Nenhum item nesta categoria.',
                    style: TextStyle(color: AppColors.textLight),
                  ),
                ),
              )
            else
              ListView.separated(
                itemCount: products.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final product = products[index];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ProductListItem(
                      key: ValueKey(product.id),
                      storeId: storeId,
                      product: product,
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
              ),


          ],
        ),
      ),
    );
  }

  void _showCategoryActionSheet(BuildContext context) {






    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(25),
          topStart: Radius.circular(25),
        ),
      ),

      builder: (ctx) {
        padding: EdgeInsetsDirectional.only(
          start: 20,
          end: 20,
          bottom: 30,
          top: 8,
        );

        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Ações da categoria',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),


              // Lista de Ações
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Adicionar item', style: TextStyle(fontWeight: FontWeight.w600),),
                onTap: () {
                  Navigator.of(ctx).pop();
                  // Passamos o objeto 'category' do card para a próxima tela
                  context.go(
                    '/stores/$storeId/products/new',
                    extra: category, // ⇐ A MÁGICA ESTÁ AQUI
                  );
                },
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: Icon(category.active ? Icons.pause_circle_outline : Icons.play_circle_outline),
                  title: Text(category.active ? 'Pausar categoria' : 'Ativar categoria', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    // TODO: Implementar lógica de pausar/ativar categoria
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funcionalidade a ser implementada.')),
                    );
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Editar categoria', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  DialogService.showCategoryDialog(context, storeId, categoryId: category.id);
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Remover categoria',  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                  onTap: () {

                    _deleteCategory(ctx, storeId, category);


                  },
                ),
              ),
            ],
          ),
        );
      },
    );



  }

  // WIDGET PARA O MENU POPUP DO DESKTOP
  Widget _buildDesktopPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'add') {
          context.go('/stores/$storeId/products/new', extra: category);
        } else if (value == 'edit') {
          DialogService.showCategoryDialog(context, storeId, categoryId: category.id);
        }
        // Adicionar outras ações aqui...
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'add', child: Text('Adicionar item')),
        const PopupMenuItem(value: 'edit', child: Text('Editar categoria')),
        const PopupMenuItem(value: 'pause', child: Text('Pausar categoria')),
        const PopupMenuItem(value: 'delete', child: Text('Remover categoria')),
      ],
    );
  }

  void _onAddProductPressed(BuildContext context, Category category, int currentProductCount) {
    final accessControl = getIt<AccessControlService>();
    final limitResult = accessControl.checkLimit(LimitType.products, currentProductCount);

    if (limitResult.isAllowed) {






    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Limite de produtos atingido.')));
    }
  }
}

Future<void> _deleteCategory(BuildContext context, int storeId, Category category) async {
  final confirmed = await DialogService.showConfirmationDialog(
    context,
    title: 'Confirmar Exclusão',
    content: 'Tem certeza que deseja excluir a categoria "${category.name}" e todos os seus produtos?',
  );
  if (confirmed == true && context.mounted) {
    try {
      await getIt<CategoryRepository>().deleteCategory(storeId, category.id!);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Categoria "${category.name}" excluída.')));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
      }
    }
  }




}


