
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_card_desktop.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_card_mobile.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/services/dialog_service.dart';

import '../../../core/enums/category_type.dart';

class ProductCardItem extends StatefulWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback onTap;
  final int storeId;

  const ProductCardItem({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.storeId,
  });

  @override
  State<ProductCardItem> createState() => _ProductCardItemState();
}

class _ProductCardItemState extends State<ProductCardItem> {

  @override
  Widget build(BuildContext context) {
    // O Card e o InkWell agora envolvem o ResponsiveBuilder
    return InkWell(
      onTap: widget.onTap,
      child: ResponsiveBuilder(
        mobileBuilder: (context, constraints) =>
            ProductCardMobile(
              storeId: widget.storeId,
             product: widget.product,
            isSelected: widget.isSelected,
              onTap: widget.onTap
            ),

        desktopBuilder: (context, constraints) => ProductCardDesktop(
            storeId: widget.storeId,
            product: widget.product,
            isSelected: widget.isSelected,
            onTap: widget.onTap ),
      ),
    );
  }




  List<Widget> _buildDesktopActions(bool isCustomizable) {
    final isAvailable = widget.product.available;
    return [
      IconButton(
        icon: Icon(
          isAvailable ? Icons.pause_circle_outline : Icons.play_circle_outline,
          color: isAvailable ? Colors.orange : Colors.green,
        ),
        tooltip: isAvailable ? 'Pausar item' : 'Ativar item',
        onPressed: _toggleAvailability,
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) {
          if (value == 'edit') {
    // ✅ LÓGICA DE NAVEGAÇÃO DINÂMICA
    if (isCustomizable) {
    // Navega para a tela de edição de SABORES
    context.go('/stores/${widget.storeId}/products/${widget.product.id}/edit-flavor', extra: widget.product);
    } else {
    // Navega para a tela de edição de ITENS SIMPLES
    context.go('/stores/${widget.storeId}/products/${widget.product.id}', extra: widget.product);
    }
    } else if (value == 'delete') {
            _deleteProduct(context);
    }









        },
        itemBuilder: (context) => [
          const PopupMenuItem<String>(value: 'edit', child: Text('Editar')),
          const PopupMenuItem<String>(value: 'delete', child: Text('Excluir')),
        ],
      ),
    ];
  }

  // --- MÉTODOS DE AÇÃO ---

  Future<void> _toggleAvailability() async {
    final updatedProduct = widget.product.copyWith(available: !widget.product.available);
    try {
      await getIt<ProductRepository>().updateProduct(widget.storeId, updatedProduct);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar produto: $e')),
        );
      }
    }
  }

  Future<void> _deleteProduct(BuildContext context) async {
    final confirmed = await DialogService.showConfirmationDialog(
      context,
      title: 'Confirmar Exclusão',
      content: 'Tem certeza que deseja excluir o produto "${widget.product.name}"?',
    );
    if (confirmed == true && context.mounted) {
      try {
        await getIt<ProductRepository>().deleteProduct(widget.storeId, widget.product.id!);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
        }
      }
    }
  }


}


