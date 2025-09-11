import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_image.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';

import '../../../core/di.dart';
import '../../../core/enums/category_type.dart';
import '../../../models/product.dart';
import '../../../repositories/product_repository.dart';
import '../../../services/dialog_service.dart';

class ProductCardMobile extends StatefulWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback onTap;
  final int storeId;

  const ProductCardMobile({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.storeId,
  });

  @override
  State<ProductCardMobile> createState() => _ProductCardMobileState();
}

class _ProductCardMobileState extends State<ProductCardMobile> {
  @override
  Widget build(BuildContext context) {
    final bool isAvailable = widget.product.available;
    final bool hasCategory = widget.product.categoryLinks.isNotEmpty;
    final bool isCustomizable = hasCategory &&
        widget.product.categoryLinks.first.category?.type == CategoryType.CUSTOMIZABLE;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: widget.product.available ? Colors.white :Color(0xFFFFF8EB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? Theme.of(context).primaryColor // Vermelho iFood
                  : Colors.grey,
              width: widget.isSelected ? 0.5 : 0.5,
            ),



          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com imagem e informações principais
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagem do produto - Container com altura fixa
                    Container(
                      width: 70,
                      height: 70,
                      child: ProductImage(product: widget.product),
                    ),

                    const SizedBox(width: 12),

                    // Informações do produto - Alinhada com a imagem
                    Expanded(
                      child: Container(
                        height: 70, // mesma altura da imagem
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center, // centraliza verticalmente
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!widget.product.available)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 14,
                                      height: 14,
                                      padding: const EdgeInsets.all(1),
                                      child: const Icon(
                                        Icons.info_outline,
                                        color: Color(0xFFE7A74E),
                                        size: 10,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Pausado',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFFE7A74E),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.product.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (widget.product.description?.isNotEmpty ?? false) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.product.description!,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                        height: 1.1,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Botão de opções - Alinhado com o topo
                    SizedBox(
                      height: 70, // mesma altura da imagem
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: _buildMobileActions(context, isCustomizable),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Detalhes do produto
              _buildProductDetails(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context) {
    // ✅ LÓGICA PARA DETERMINAR O TEXTO DO ESTOQUE
    final String stockText;
    if (widget.product.controlStock) {
      stockText = widget.product.stockQuantity.toString();
    } else {
      stockText = 'Ilimitado';
    }

    // ✅ LÓGICA PARA DETERMINAR O TEXTO DAS CATEGORIAS
    final int categoryCount = widget.product.categoryLinks.length;
    final String categoryText = '$categoryCount ${categoryCount == 1 ? "categoria" : "categorias"}';

    return Column(
      children: [
        // Grid de informações - layout responsivo
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.8,
          children: [
            // VENDAS
            _InfoItem(
              title: 'VENDAS',
              value: widget.product.soldCount.toString(),
              valueStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            // ESTOQUE
            _InfoItem(
              title: 'ESTOQUE',
              value: stockText,
              valueStyle: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: stockText == 'Ilimitado' ? Colors.green : Colors.black,
              ),
            ),

            // DISPONÍVEL EM
            _InfoItem(
              title: 'DISPONÍVEL EM',
              value: categoryText,
              valueStyle: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),

            // AÇÕES
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'AÇÕES',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: _ActionButtons(
                    product: widget.product,
                    storeId: widget.storeId,
                    onStateChanged: () => setState(() {}),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileActions(BuildContext context, bool isCustomizable) {
    if (widget.isSelected) {
      return Checkbox(
        value: true,
        onChanged: (_) => widget.onTap(),
        activeColor: Theme.of(context).primaryColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.more_vert, size: 20),
        iconSize: 20,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        tooltip: 'Mais ações',
        onPressed: () => _showMobileActionSheet(context, isCustomizable),
      );
    }
  }

  void _showMobileActionSheet(BuildContext context, bool isCustomizable) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                _ActionButtonItem(
                  icon: Icons.visibility,
                  text: 'Ver detalhes',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    if (isCustomizable) {
                      context.push(
                        '/stores/${widget.storeId}/products/${widget.product.id}/edit-flavor',
                        extra: widget.product,
                      );
                    } else {
                      context.push(
                        '/stores/${widget.storeId}/products/${widget.product.id}',
                        extra: widget.product,
                      );
                    }
                  },
                ),
                _ActionButtonItem(
                  icon: widget.product.available ? Icons.pause : Icons.play_arrow,
                  text: widget.product.available ? 'Pausar produto' : 'Ativar produto',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _toggleAvailability(context);
                  },
                ),
                _ActionButtonItem(
                  icon: Icons.copy,
                  text: 'Duplicar produto',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    // Implementar duplicação aqui
                  },
                ),
                const Divider(height: 20),
                _ActionButtonItem(
                  icon: Icons.delete_outline,
                  text: 'Remover',
                  color: Colors.red,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _deleteProduct(context);
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _toggleAvailability(BuildContext context) async {
    try {
      final updatedProduct = widget.product.copyWith(available: !widget.product.available);
      await getIt<ProductRepository>().updateProduct(widget.storeId, updatedProduct);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedProduct.available
                ? 'Produto ativado com sucesso'
                : 'Produto pausado com sucesso',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar produto: $e'),
            duration: const Duration(seconds: 3),
          ),
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

    if (confirmed == true && mounted) {
      try {
        await getIt<ProductRepository>().deleteProduct(widget.storeId, widget.product.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produto excluído com sucesso'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir: $e'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;
  final TextStyle valueStyle;

  const _InfoItem({
    required this.title,
    required this.value,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: valueStyle,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _ActionButtonItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButtonItem({
    required this.icon,
    required this.text,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: color ?? Theme.of(context).primaryColor,
        size: 20,
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: color ?? Colors.black,
        ),
      ),
      onTap: onTap,
    );
  }
}

class _ActionButtons extends StatefulWidget {
  final Product product;
  final int storeId;
  final VoidCallback onStateChanged;

  const _ActionButtons({
    required this.product,
    required this.storeId,
    required this.onStateChanged,
  });

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {


  @override
  Widget build(BuildContext context) {

    return
 IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        widget.product.available ? Icons.pause : Icons.play_arrow,
        size: 18,
        color: widget.product.available
            ? Colors.orange
            :  Colors.green
      ),
      onPressed: _toggleAvailability,
      tooltip: widget.product.available ? 'Pausar produto' : 'Ativar produto',
    );
  }

  Future<void> _toggleAvailability() async {


    try {
      final updatedProduct = widget.product.copyWith(available: !widget.product.available);
      await getIt<ProductRepository>().updateProduct(widget.storeId, updatedProduct);
      widget.onStateChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {

      }
    }
  }
}