import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_image.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';

import '../../../core/di.dart';
import '../../../core/enums/category_type.dart';
import '../../../core/enums/product_status.dart';
import '../../../models/product.dart';
import '../../../repositories/product_repository.dart';
import '../../../services/dialog_service.dart';

class ProductCardDesktop extends StatefulWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback onTap;
  final int storeId;
  final VoidCallback onStatusToggle;

  const ProductCardDesktop({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.storeId,
    required this.onStatusToggle,
  });

  @override
  State<ProductCardDesktop> createState() => _ProductCardDesktopState();
}

class _ProductCardDesktopState extends State<ProductCardDesktop> {
  @override
  Widget build(BuildContext context) {
    // ✅ LÓGICA CENTRALIZADA AQUI (igual à versão mobile)
    final bool isActive = widget.product.status == ProductStatus.ACTIVE;
    final bool hasCategory = widget.product.categoryLinks.isNotEmpty;
    final bool isCustomizable = hasCategory &&
        widget.product.categoryLinks.first.category?.type == CategoryType.CUSTOMIZABLE;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : const Color(0xFFFFF8EB),
          border: Border.all(
            color: widget.isSelected
                ? Theme.of(context).primaryColor
                : const Color(0xFFEBEBEB),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Checkbox de seleção
            SizedBox(
              width: 60,
              child: Checkbox(
                value: widget.isSelected,
                onChanged: (_) => widget.onTap(),
                activeColor: Theme.of(context).primaryColor,
              ),
            ),

            // Imagem do produto
            SizedBox(
              width: 100,
              child: ProductImage(

                imageUrl: (widget.product.images.isNotEmpty) ? widget.product.images.first.url : null,


              ),
            ),

            // Informações do produto
            Expanded(
              flex: 3,
              child: _ProductInfoDesktop(
                product: widget.product,
                isActive: isActive,
              ),
            ),

            // Classificação (simplificado - você pode adaptar conforme sua necessidade)
            Expanded(
              flex: 1,
              child: Text(
                hasCategory ? 'Categorizado' : 'Sem categoria',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),

            // Disponível em (categorias)
            Expanded(
              flex: 1,
              child: Text(
                '${widget.product.categoryLinks.length} ${widget.product.categoryLinks.length == 1 ? "categoria" : "categorias"}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),

            // Ações
            SizedBox(
              width: 120,
              child: _DesktopActions(
                product: widget.product,
                storeId: widget.storeId,
                isActive: isActive,
                isCustomizable: isCustomizable,
                onToggle: widget.onStatusToggle,
              ),
            ),
          ],
        ),
      ),
    );
  }




}

class _ProductInfoDesktop extends StatelessWidget {
  final Product product;
  final bool isActive;

  const _ProductInfoDesktop({
    required this.product,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status indicator
        if (!isActive)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  padding: const EdgeInsets.all(2),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFFE7A74E),
                    size: 12,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Pausado',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFE7A74E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // Nome do produto
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        // Descrição
        if (product.description?.isNotEmpty ?? false) ...[
          const SizedBox(height: 4),
          Text(
            product.description!,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // Informações adicionais (vendidos, estoque)
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              'VENDIDOS: ${product.soldCount}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              product.controlStock ? 'ESTOQUE: ${product.stockQuantity}' : 'ESTOQUE: Ilimitado',
              style: TextStyle(
                fontSize: 12,
                color: product.controlStock ? Colors.grey : Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DesktopActions extends StatelessWidget {
  final Product product;
  final int storeId;
  final bool isActive;
  final bool isCustomizable;
  final VoidCallback onToggle;

  const _DesktopActions({
    required this.product,
    required this.storeId,
    required this.isActive,
    required this.isCustomizable,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Botão de pausar/ativar
        IconButton(
          icon: Icon(
            isActive ? Icons.pause : Icons.play_arrow,
            size: 20,
          ),
          color: isActive ? const Color(0xFFEA1D2C) : Colors.green,
          onPressed: onToggle,
          tooltip: isActive ? 'Pausar produto' : 'Ativar produto',
        ),

        // Botão de editar
        IconButton(
          icon: const Icon(Icons.edit, size: 20),
          color: Colors.grey,
          onPressed: () {
            if (isCustomizable) {
              context.push(
                '/stores/$storeId/products/${product.id}/edit-flavor',
                extra: product,
              );
            } else {
              context.push(
                '/stores/$storeId/products/${product.id}',
                extra: product,
              );
            }
          },
          tooltip: 'Editar produto',
        ),

        // Botão de mais opções
        PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: const Text('Duplicar produto'),
              onTap: () {
                // Implementar duplicação aqui
              },
            ),
            PopupMenuItem(
              child: const Text('Remover', style: TextStyle(color: Colors.red)),
              onTap: () {
                Future.delayed(Duration.zero, () {
                  _showArchiveDialog(context);
                });
              },
            ),
          ],
          icon: const Icon(Icons.more_vert, size: 20),
          tooltip: 'Mais ações',
        ),
      ],
    );
  }

  void _showArchiveDialog(BuildContext context) {
    DialogService.showConfirmationDialog(
      context,
      title: 'Confirmar Arquivamento',
      content: 'Tem certeza que deseja arquivar o produto "${product.name}"? Ele será movido para a lixeira.',
    ).then((confirmed) {
      if (confirmed == true) {
        getIt<ProductRepository>().archiveProduct(storeId, product.id!);
      }
    });
  }
}