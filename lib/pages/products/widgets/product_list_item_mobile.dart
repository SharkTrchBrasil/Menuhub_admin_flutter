
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_svg/svg.dart';

import 'package:totem_pro_admin/pages/products/widgets/product_actions_shhet.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_image.dart';


import '../../../core/di.dart';
import '../../../core/enums/category_type.dart';

import '../../../models/category.dart';

import '../../../models/products/product.dart';
import '../../../repositories/product_repository.dart';
import '../cubit/products_cubit.dart';


class ProductListItemMobile extends StatefulWidget {
  final int storeId;
  final Product product;
  final Category parentCategory;
  final String displayPriceText;

  const ProductListItemMobile({
    super.key,
    required this.storeId,
    required this.product,
    required this.parentCategory,
    required this.displayPriceText,
  });

  @override
  State<ProductListItemMobile> createState() => _ProductListItemMobileState();
}

class _ProductListItemMobileState extends State<ProductListItemMobile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final link = widget.product.categoryLinks.firstWhere((l) => l.categoryId == widget.parentCategory.id);
    final isAvailableInThisCategory = link.isAvailable;
    final bool isCustomizable = widget.parentCategory.type == CategoryType.CUSTOMIZABLE;
    final Color textColor = isAvailableInThisCategory ? Colors.black : Colors.grey.shade500;
    final bool hasNoPrice = !isCustomizable && (link.price ?? widget.product.price ?? 0) == 0;

    return Container(
      decoration: BoxDecoration(
        color: isAvailableInThisCategory ? const Color(0xFFFFFFFF) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              children: [
                const SizedBox(width: 10),

                ProductImage(

                  imageUrl: (widget.product.images.isNotEmpty) ? widget.product.images.first.url : null,


                ),

             //   _buildDefaultImage(isAvailableInThisCategory),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: _buildPriceRow(isCustomizable, textColor),
                      ),
                    ],
                  ),
                ),

                ..._buildMobileActions(isCustomizable, isAvailableInThisCategory),
              ],
            ),
          ),

          if (hasNoPrice)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF8EB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Color(0xFF7A5200)),
                  const SizedBox(width: 8),
                  const Text(
                    "Item sem preço",
                    style: TextStyle(
                      color: Color(0xFF7A5200),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Color(0xFF7A5200)),
                ],
              ),
            ),
          if (_isExpanded) _buildComplementsList(),
        ],
      ),
    );
  }

  Widget _buildPriceRow(bool isCustomizable, Color textColor) {
    if (isCustomizable) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),

                if (widget.product.description != null && widget.product.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      widget.product.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 12
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              children: [
                Text(
                  'À partir de',
                  style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 12
                  ),
                ),
                Text(
                  'R\$ '+widget.displayPriceText,
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),

          Row(
            children: [
              Text(
                'R\$ ' + widget.displayPriceText,
                style: TextStyle(
                  color: textColor.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 8),
              if (widget.product.controlStock)
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 14,
                      color: textColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.product.stockQuantity ?? 0}',
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      );
    }
  }

  List<Widget> _buildMobileActions(bool isCustomizable, bool isAvailableInThisCategory) {
    return [
      IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(isAvailableInThisCategory ? Icons.pause_circle_outline : Icons.play_circle_outline,
            color: isAvailableInThisCategory ? Colors.orange : Colors.green),
        tooltip: isAvailableInThisCategory ? 'Pausar item' : 'Ativar item',
        onPressed: _toggleAvailabilityInCategory,
      ),
      IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert),
        tooltip: 'Mais ações',
        onPressed: () => _showMobileActionSheet(context, isCustomizable),
      ),
    ];
  }

  Future<void> _toggleAvailabilityInCategory() async {
    final bool currentLinkAvailability = widget.product.categoryLinks
        .firstWhere((link) => link.categoryId == widget.parentCategory.id)
        .isAvailable;

    await getIt<ProductRepository>().toggleLinkAvailability(
      storeId: widget.storeId,
      productId: widget.product.id!,
      categoryId: widget.parentCategory.id!,
      isAvailable: !currentLinkAvailability,
    );
  }

  Future<void> _removeProductFromCategory() async {
    try {
      await getIt<ProductRepository>().removeProductFromCategory(
        storeId: widget.storeId,
        productId: widget.product.id!,
        categoryId: widget.parentCategory.id!,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover da categoria: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }



  Widget _buildDefaultImage(bool isAvailable) {
    // ✅ LÓGICA CORRIGIDA AQUI
    // 1. Verifica se a lista de imagens não está vazia e pega a URL da primeira imagem.
    final coverImageUrl = (widget.product.images.isNotEmpty)
        ? widget.product.images.first.url
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            isAvailable ? Colors.transparent : Colors.grey,
            BlendMode.saturation,
          ),
          // 2. Usa a nova variável 'coverImageUrl' para decidir o que mostrar.
          child: coverImageUrl != null
              ? CachedNetworkImage(
            imageUrl: coverImageUrl, // Usa a URL da capa
            width: 60,
            height: 68,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
              : SizedBox(
            width: 60,
            height: 68,
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/burguer.svg',
                width: 42,
                height: 42,
                placeholderBuilder: (context) => const CircularProgressIndicator(strokeWidth: 2),
                semanticsLabel: 'Placeholder de produto',
              ),
            ),
          )
      ),
    );
  }

  Widget _buildComplementsList() {
    final links = widget.product.variantLinks;
    if (links == null || links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Grupos de Complementos Vinculados:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...widget.product.variantLinks!.map((link) {
            return Text('- ${link.variant.name}');
          }).toList(),
        ],
      ),
    );
  }

  void _showMobileActionSheet(BuildContext context, bool isCustomizable) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(25),
          topStart: Radius.circular(25),
        ),
      ),
      builder: (ctx) {
        return ProductActionsSheet(
          displayPrice: widget.displayPriceText,
          storeId: widget.storeId,
          product: widget.product,
          parentCategory: widget.parentCategory,
          productsCubit: context.read<ProductsCubit>(),
        );
      },
    );
  }
}