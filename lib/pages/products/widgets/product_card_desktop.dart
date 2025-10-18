import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_image.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_panel.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';

import '../../../core/di.dart';
import '../../../core/enums/category_type.dart';
import '../../../core/enums/product_status.dart';

import '../../../core/helpers/edit_product_sidepanel.dart';
import '../../../core/helpers/sidepanel.dart';
import '../../../models/products/product.dart';
import '../../../repositories/product_repository.dart';
import '../../../services/dialog_service.dart';
import '../../product_flavors/flavor_edit_panel.dart';

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

  // ✨ CÓDIGO NOVO E REATORADO USANDO O HELPER ✨
  void _openEditPanel() {
    // Fecha o BottomSheet que está aberto, se necessário.
    Navigator.of(context).pop();

    // Chama o helper global passando as informações necessárias
    showEditProductPanel(
      context: context,
      product: widget.product,
      storeId: widget.storeId,
      parentCategory:  widget.product.categoryLinks.first.category!, // Passa a categoria pai do contexto atual
      onSaveSuccess: () {
        // Você pode adicionar qualquer lógica extra aqui após o salvamento.
        // Por exemplo, atualizar a UI ou mostrar uma mensagem.
        print('Produto salvo, painel fechado!');
      },
    );
  }





  @override
  Widget build(BuildContext context) {
    final bool isActive = widget.product.status == ProductStatus.ACTIVE;
    final bool hasCategory = widget.product.categoryLinks.isNotEmpty;
    final bool isCustomizable = hasCategory &&
        widget.product.categoryLinks.first.category?.type == CategoryType.CUSTOMIZABLE;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Color(0xFFF5F5F5),
        ),
        child: Row(
          children: [
            // Checkbox de seleção - MESMA LARGURA DO HEADER
            SizedBox(
              width: 30, // ✅ MESMO VALOR DO HEADER
              child: Checkbox(
                value: widget.isSelected,
                onChanged: (_) => widget.onTap(),
                activeColor: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(width: 16), // ✅ MESMO ESPAÇAMENTO DO HEADER

            // Imagem do produto - FIXO (não tem no header)
            ProductImage(
              imageUrl: (widget.product.images.isNotEmpty) ? widget.product.images.first.url : null,
            ),
            const SizedBox(width: 16),

            // Informações do produto - MESMO FLEX DO HEADER
            Expanded(
              flex: 3, // ✅ ALTERADO DE 1 PARA 3 (igual ao header)
              child: _ProductInfoDesktop(
                product: widget.product,
                isActive: isActive,
              ),
            ),

            // Disponível em (categorias) - MESMO FLEX DO HEADER
            Expanded(
              flex: 1, // ✅ MANTIDO 1 (igual ao header)
              child: Text(
                '${widget.product.categoryLinks.first.category?.name}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.start,
              ),
            ),

            Expanded(
              flex: 1,
              child: Text(
                widget.product.controlStock
                    ? '${widget.product.stockQuantity}'
                    : 'Desabilitado', // ou o texto que você quiser quando for false
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.green, // opcional: cor diferente para "Ilimitado"
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Vendas - MESMO FLEX DO HEADER
            Expanded(
              flex: 1, // ✅ MANTIDO 1 (igual ao header)
              child: Text(
                '${widget.product.soldCount}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center, // ✅ ADICIONADO ALINHAMENTO CENTRAL
              ),
            ),

            // Ações - MESMA LARGURA DO HEADER
            SizedBox(
              width: 140, // ✅ MESMA LARGURA DO HEADER
              child: _DesktopActions(
                product: widget.product,
                storeId: widget.storeId,
                isActive: isActive,
                isCustomizable: isCustomizable,
                onToggle: widget.onStatusToggle,
                onEdit: () => _openEditPanel(),
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

        // // Informações adicionais (vendidos, estoque)
        // const SizedBox(height: 8),
        // Row(
        //   children: [
        //     Text(
        //       'VENDIDOS: ${product.soldCount}',
        //       style: const TextStyle(
        //         fontSize: 12,
        //         color: Colors.grey,
        //       ),
        //     ),
        //     const SizedBox(width: 16),
        //     Text(
        //       product.controlStock ? 'ESTOQUE: ${product.stockQuantity}' : 'ESTOQUE: Ilimitado',
        //       style: TextStyle(
        //         fontSize: 12,
        //         color: product.controlStock ? Colors.grey : Colors.green,
        //       ),
        //     ),
        //   ],
        // ),
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
  final VoidCallback onEdit; // Novo callback


  const _DesktopActions({
    required this.product,
    required this.storeId,
    required this.isActive,
    required this.isCustomizable,
    required this.onToggle,
    required this.onEdit,
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
          onPressed: onEdit,
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