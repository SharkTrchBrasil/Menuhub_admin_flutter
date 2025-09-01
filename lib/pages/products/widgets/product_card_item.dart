// Substitua o conteúdo do seu arquivo ProductCardItem.dart por este.

import 'package:brasil_fields/brasil_fields.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/services/dialog_service.dart';

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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.isSelected ? Theme.of(context).primaryColor : const Color(0xFFEBEBEB),
          width: widget.isSelected ? 1.5 : 1,
        ),
      ),
      color: widget.isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.white,
      clipBehavior: Clip.antiAlias, // Garante que o InkWell respeite as bordas
      child: InkWell(
        onTap: widget.onTap,
        child: ResponsiveBuilder(
          mobileBuilder: (context, constraints) => _buildMobileLayout(context),
          desktopBuilder: (context, constraints) => _buildDesktopLayout(context),
        ),
      ),
    );
  }

  // ✅ NOVO LAYOUT PARA DESKTOP (baseado em colunas)
  Widget _buildDesktopLayout(BuildContext context) {
    final bool isAvailable = widget.product.available;
    final Color textColor = isAvailable ? const Color(0xFF151515) : Colors.grey.shade500;
    final textStyle = TextStyle(color: textColor, fontSize: 14);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: widget.isSelected,
            onChanged: (_) => widget.onTap(),
            activeColor: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 12),
          // Coluna "Produto" - flex: 4
          Expanded(
            flex: 4,
            child: Row(
              children: [
                _buildProductImage(isAvailable),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.product.name,
                        style: textStyle.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.product.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.product.description,
                          style: textStyle.copyWith(fontSize: 12, color: textColor.withOpacity(0.7)),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Coluna "Categoria" - flex: 2
          Expanded(
            flex: 2,
            child: Builder( // Usamos um Builder para a lógica
              builder: (context) {
                // ✅ VERIFICA SE A LISTA DE VÍNCULOS NÃO ESTÁ VAZIA
                final bool hasCategories = widget.product.categoryLinks.isNotEmpty;

                // ✅ PEGA O NOME DA PRIMEIRA CATEGORIA DA LISTA
                final categoryName = hasCategories
                    ? widget.product.categoryLinks.first.category.name
                    : 'Sem Categoria';

                return Text(categoryName, style: textStyle);
              },
            ),
          ),
          //na "Visualizações" - flex: 1 (PLACEHOLDER)
          Expanded(
            flex: 1,
            child: Text('---', style: textStyle, textAlign: TextAlign.center),
          ),
          // Coluna "Vendas" - flex: 1 (PLACEHOLDER)
          Expanded(
            flex: 1,
            child: Text('---', style: textStyle, textAlign: TextAlign.center),
          ),
          // Coluna "Ações" - Largura fixa
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildDesktopActions(),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ LAYOUT ANTIGO, AGORA ESPECÍFICO PARA MOBILE
  Widget _buildMobileLayout(BuildContext context) {
    final bool isAvailable = widget.product.available;
    final Color textColor = isAvailable ? const Color(0xFF151515) : Colors.grey.shade500;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductImage(isAvailable),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16, color: textColor),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.description,
                  style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 12, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Text(
                  UtilBrasilFields.obterReal((widget.product.price ?? 0) / 100),
                  style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 48,
            child: _buildMobileActions(),
          )
        ],
      ),
    );
  }


  // --- MÉTODOS DE CONSTRUÇÃO DE UI ---

  Widget _buildProductImage(bool isAvailable) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          isAvailable ? Colors.transparent : Colors.grey,
          BlendMode.saturation,
        ),
        child: widget.product.image?.url != null && widget.product.image!.url!.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: widget.product.image!.url!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholderImage(),
          errorWidget: (context, url, error) => _buildPlaceholderImage(),
        )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFEBEBEB),
      child: const Icon(Icons.image_outlined, color: Color(0xFFA3A3A3), size: 40),
    );
  }

  Widget _buildMobileActions() {
    if (widget.isSelected) {
      return Checkbox(
        value: true,
        onChanged: (_) => widget.onTap(),
        activeColor: Theme.of(context).primaryColor,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.more_vert),
        tooltip: 'Mais ações',
        onPressed: () => _showMobileActionSheet(context),
      );
    }
  }

  List<Widget> _buildDesktopActions() {
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
            context.go('/stores/${widget.storeId}/products/${widget.product.id}', extra: widget.product);
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
      await getIt<ProductRepository>().saveProduct(widget.storeId, updatedProduct);
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

  void _showMobileActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final isAvailable = widget.product.available;
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.product.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Divider(),
                  ListTile(
                    leading: Icon(isAvailable ? Icons.pause : Icons.play_arrow, color: isAvailable ? Colors.orange : Colors.green),
                    title: Text(isAvailable ? 'Pausar item' : 'Ativar item'),
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await _toggleAvailability();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Editar item'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.go('/stores/${widget.storeId}/products/${widget.product.id}', extra: widget.product);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('Remover item', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _deleteProduct(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}