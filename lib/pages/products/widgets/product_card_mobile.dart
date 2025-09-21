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

class ProductCardMobile extends StatefulWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback onTap;
  final int storeId;
  final VoidCallback? onStatusChanged; // ✅ Callback para notificar mudanças

  const ProductCardMobile({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.storeId,
    this.onStatusChanged,
  });

  @override
  State<ProductCardMobile> createState() => _ProductCardMobileState();
}

class _ProductCardMobileState extends State<ProductCardMobile> {
  bool _isUpdating = false; // ✅ Estado para controlar loading

  @override
  Widget build(BuildContext context) {
    final bool isProductActive = widget.product.status == ProductStatus.ACTIVE;
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
            color: isProductActive ? Colors.white : Color(0xFFFFF8EB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isSelected
                  ? Theme.of(context).primaryColor
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
                    // Imagem do produto
                    Container(
                      width: 70,
                      height: 70,
                      child: ProductImage(

                        imageUrl: (widget.product.images.isNotEmpty) ? widget.product.images.first.url : null,


                      ),
                    ),
                    const SizedBox(width: 12),

                    // Informações do produto
                    Expanded(
                      child: Container(
                        height: 70,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!isProductActive)
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

                    // Botão de opções
                    SizedBox(
                      height: 70,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: _buildMobileActions(context, isCustomizable, isProductActive),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Detalhes do produto
              _buildProductDetails(context, isProductActive),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductDetails(BuildContext context, bool isActive) {
    final String stockText = widget.product.controlStock
        ? widget.product.stockQuantity.toString()
        : 'Ilimitado';

    // ✅ MOSTRAR NOMES DAS CATEGORIAS EM VEZ DA QUANTIDADE
    final String categoryText = _getCategoryNames();

    return Column(
      children: [
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

            // DISPONÍVEL EM - ✅ AGORA MOSTRA OS NOMES
            _InfoItem(
              title: 'DISPONÍVEL EM',
              value: categoryText,
              valueStyle: const TextStyle(
                fontSize: 11, // ✅ Tamanho menor para caber mais texto
                color: Colors.black87,
                fontWeight: FontWeight.w500,
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
                  child: _isUpdating
                      ? const DotLoading(size: 15) // ✅ Loading durante atualização
                      : _ActionButtons(
                    isActive: isActive,
                    onToggle: () => _toggleStatus(context),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // ✅ MÉTODO PARA OBTER NOMES DAS CATEGORIAS
  String _getCategoryNames() {
    if (widget.product.categoryLinks.isEmpty) {
      return 'Nenhuma';
    }

    // Pega até 2 categorias para não ficar muito longo
    final categoryNames = widget.product.categoryLinks
        .take(2)
        .map((link) => link.category?.name ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    if (categoryNames.isEmpty) {
      return 'Nenhuma';
    }

    String result = categoryNames.join(', ');

    // Se tiver mais categorias, adiciona "..."
    if (widget.product.categoryLinks.length > 2) {
      result += '...';
    }

    return result;
  }

  Widget _buildMobileActions(BuildContext context, bool isCustomizable, bool isActive) {
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
        onPressed: () => _showMobileActionSheet(context, isCustomizable, isActive),
      );
    }
  }

  void _showMobileActionSheet(BuildContext context, bool isCustomizable, bool isActive) {
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
                      context.pushNamed(
                        'flavor-edit',
                        pathParameters: {'storeId': '${widget.storeId}', 'productId': '${widget.product.id}'},
                        extra: widget.product,
                      );
                    } else {
                      context.pushNamed(
                        'product-edit',
                        pathParameters: {'storeId': '${widget.storeId}', 'productId': '${widget.product.id}'},
                        extra: widget.product,
                      );
                    }
                  },
                ),
                _ActionButtonItem(
                  icon: isActive ? Icons.pause : Icons.play_arrow,
                  text: isActive ? 'Pausar produto' : 'Ativar produto',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _toggleStatus(context);
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
                    _archiveProduct(context);
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

  // ✅ MÉTODO ATUALIZADO PARA TOGGLE STATUS
  Future<void> _toggleStatus(BuildContext context) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final newStatus = widget.product.status == ProductStatus.ACTIVE
          ? ProductStatus.INACTIVE
          : ProductStatus.ACTIVE;

      final updatedProduct = widget.product.copyWith(status: newStatus);

      await getIt<ProductRepository>().updateProduct(widget.storeId, updatedProduct, deletedImageIds: []);

      // ✅ Notifica o parent widget sobre a mudança
      if (widget.onStatusChanged != null) {
        widget.onStatusChanged!();
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e'))
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _archiveProduct(BuildContext context) async {
    final confirmed = await DialogService.showConfirmationDialog(
      context,
      title: 'Confirmar Arquivamento',
      content: 'Tem certeza que deseja arquivar o produto "${widget.product.name}"? Ele será movido para a lixeira.',
    );

    if (confirmed == true && mounted) {
      try {
        await getIt<ProductRepository>().archiveProduct(widget.storeId, widget.product.id!);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao arquivar: $e')));
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
        Flexible(
          child: Text(
            value,
            style: valueStyle,
            textAlign: TextAlign.center,
            maxLines: 2, // ✅ Permite 2 linhas para os nomes das categorias
            overflow: TextOverflow.ellipsis,
          ),
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

class _ActionButtons extends StatelessWidget {
  final bool isActive;
  final VoidCallback onToggle;

  const _ActionButtons({
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      icon: Icon(
        isActive ? Icons.pause : Icons.play_arrow,
        size: 18,
        color: isActive ? Colors.orange : Colors.green,
      ),
      onPressed: onToggle,
      tooltip: isActive ? 'Pausar produto' : 'Ativar produto',
    );
  }
}