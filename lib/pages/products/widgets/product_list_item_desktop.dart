import 'package:brasil_fields/brasil_fields.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_image.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_panel.dart';


import '../../../core/di.dart';
import '../../../core/enums/category_type.dart';

import '../../../core/helpers/sidepanel.dart';
import '../../../models/category.dart';

import '../../../models/products/product.dart';
import '../../../repositories/product_repository.dart';
import '../../product_flavors/flavor_edit_panel.dart';
import '../cubit/products_cubit.dart';


class ProductListItemDesktop extends StatefulWidget {
  final int storeId;
  final Product product;
  final Category parentCategory;
  final String displayPriceText;

  const ProductListItemDesktop({
    super.key,
    required this.storeId,
    required this.product,
    required this.parentCategory,
    required this.displayPriceText,
  });

  @override
  State<ProductListItemDesktop> createState() => _ProductListItemDesktopState();
}

class _ProductListItemDesktopState extends State<ProductListItemDesktop> {
  bool _isExpanded = false;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final FocusNode _priceFocusNode;
  late final FocusNode _stockFocusNode;

  @override
  void initState() {
    super.initState();

    _priceController = TextEditingController(text: _getInitialPriceText());
    _stockController = TextEditingController(
      text: widget.product.stockQuantity?.toString() ?? '0',
    );

    _priceFocusNode = FocusNode();
    _stockFocusNode = FocusNode();
    _priceFocusNode.addListener(_onPriceFocusChange);
    _stockFocusNode.addListener(_onStockFocusChange);
  }

  String _getInitialPriceText() {
    if (widget.parentCategory.type == CategoryType.CUSTOMIZABLE) {
      return widget.displayPriceText;
    }
    final link = widget.product.categoryLinks
        .firstWhere((l) => l.categoryId == widget.parentCategory.id);
    return UtilBrasilFields.obterReal(link.price / 100);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    _priceFocusNode.removeListener(_onPriceFocusChange);
    _priceFocusNode.dispose();
    _stockFocusNode.removeListener(_onStockFocusChange);
    _stockFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProductListItemDesktop oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.displayPriceText != oldWidget.displayPriceText) {
      _priceController.text = _getInitialPriceText();
    }

    if (widget.product.stockQuantity != oldWidget.product.stockQuantity) {
      _stockController.text = widget.product.stockQuantity?.toString() ?? '0';
    }
  }

  void _onPriceFocusChange() {
    if (!_priceFocusNode.hasFocus) _updatePrice();
  }

  void _onStockFocusChange() {
    if (!_stockFocusNode.hasFocus) _updateStock();
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

  Future<void> _updatePrice() async {
    final originalPriceText = widget.displayPriceText;
    final newPriceText = _priceController.text;

    if (originalPriceText != newPriceText) {
      try {
        final priceInCents = (UtilBrasilFields.converterMoedaParaDouble(newPriceText) * 100).toInt();

        await getIt<ProductRepository>().updateProductCategoryPrice(
          storeId: widget.storeId,
          productId: widget.product.id!,
          categoryId: widget.parentCategory.id!,
          newPrice: priceInCents,
        );
      } catch (e) {
        if (mounted) {
          setState(() {
            _priceController.text = originalPriceText;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar o preço: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _deactivateAndClearStock() async {
    if (widget.product.stockQuantity == 0 && !widget.product.controlStock) return;

    final updatedProduct = widget.product.copyWith(
      stockQuantity: 0,
      controlStock: false,
    );
    await getIt<ProductRepository>().updateProduct(widget.storeId, updatedProduct, deletedImageIds: []);
  }

  void _updateStock() async {
    final originalQuantity = widget.product.stockQuantity;
    final parsedQuantity = int.tryParse(_stockController.text) ?? 0;
    final bool newControlStatus = parsedQuantity > 0;

    if (originalQuantity != parsedQuantity || widget.product.controlStock != newControlStatus) {
      try {
        final updatedProduct = widget.product.copyWith(
          stockQuantity: parsedQuantity,
          controlStock: newControlStatus,
        );
        await getIt<ProductRepository>().updateProduct(widget.storeId, updatedProduct, deletedImageIds: []);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar o estoque: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
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
                const SizedBox(width: 16),
                ..._buildDesktopActions(textColor, isCustomizable, isAvailableInThisCategory),
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
        children: [
          Column(
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
          const SizedBox(width: 8),
          Column(
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

  List<Widget> _buildDesktopActions(Color textColor, bool isCustomizable, bool isAvailableInThisCategory) {
    if (isCustomizable) {
      return [
        _buildPriceDisplay(),
        const SizedBox(width: 12),
        _buildSharedActionButtons(textColor, isCustomizable, isAvailableInThisCategory),
      ];
    } else {
      return [
        _buildStockField(isAvailableInThisCategory),
        const SizedBox(width: 12),
        _buildPriceField(isAvailableInThisCategory),
        const SizedBox(width: 12),
        _buildSharedActionButtons(textColor, isCustomizable, isAvailableInThisCategory),
      ];
    }
  }

  Widget _buildStockField(bool isAvailableInThisCategory) {
    return Tooltip(
      message: 'Estoque',
      child: SizedBox(
        width: 80,
        child: TextField(
          controller: _stockController,
          focusNode: _stockFocusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabled: isAvailableInThisCategory,
            fillColor: isAvailableInThisCategory ? null : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceField(bool isAvailableInThisCategory) {
    return Tooltip(
      message: 'Preço',
      child: SizedBox(
        width: 120,
        child: TextField(
          controller: _priceController,
          focusNode: _priceFocusNode,
          textAlign: TextAlign.center,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CentavosInputFormatter(moeda: true),
          ],
          decoration: InputDecoration(
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabled: isAvailableInThisCategory,
            fillColor: isAvailableInThisCategory ? null : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildSharedActionButtons(Color textColor, bool isCustomizable, bool isAvailableInThisCategory) {
    return Row(
      children: [
        IconButton(
          icon: Icon(
              isAvailableInThisCategory ? Icons.pause_circle_outline : Icons.play_circle_outline,
              color: isAvailableInThisCategory ? Colors.green : Colors.orange
          ),
          tooltip: isAvailableInThisCategory ? 'Pausar item' : 'Ativar item',
          onPressed: (){
            context.read<ProductsCubit>().toggleAvailabilityInCategory(
              storeId: widget.storeId,
              product: widget.product,
              parentCategory: widget.parentCategory,
            );
          }
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: textColor),
          onSelected: (value) {
            if (value == 'edit') {



              _openEditPanel();




            } else if (value == 'delete') {
              _removeProductFromCategory();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem<String>(value: 'edit', child: Text('Editar item')),
            const PopupMenuItem<String>(value: 'delete', child: Text('Remover item')),
          ],
        ),
      ],
    );
  }

// Em product_list_item_desktop.dart


  void _openEditPanel() {


    final isCustomizable = widget.parentCategory.type == CategoryType.CUSTOMIZABLE;

    // Decide qual painel abrir
    final Widget panelToOpen = isCustomizable
        ? FlavorEditPanel(
      storeId: widget.storeId,
      product: widget.product,
      parentCategory: widget.parentCategory,
      onSaveSuccess: () {


      },
      onCancel: () => Navigator.of(context).pop(),
    )
        : ProductEditPanel(
      storeId: widget.storeId,
      product: widget.product,
      onSaveSuccess: () {
      // Fecha o painel

      },
      onCancel: () => Navigator.of(context).pop(),
    );

    // Usa o seu helper para abrir o painel lateral escolhido
    showResponsiveSidePanel(context, panelToOpen);
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

  Widget _buildPriceDisplay() {
    final hasPrices = widget.product.prices.isNotEmpty;
    final startingPrice = hasPrices
        ? widget.product.prices.map((p) => p.price).reduce((a, b) => a < b ? a : b)
        : 0;

    return hasPrices
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('À partir de', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(width: 8),
        Text(
          UtilBrasilFields.obterReal(startingPrice / 100),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    )
        : InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Item sem preço'),
            content: const Text('Este sabor ainda não tem preços definidos para os tamanhos. Edite o item para configurá-los.'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              TextButton(
                child: const Text('Ir para Edição'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.push('/stores/${widget.storeId}/products/${widget.product.id}/edit-flavor', extra: widget.product);
                },
              ),
            ],
          ),
        );
      },
      child: const Chip(label: Text('⚠️ Sem Preço'), backgroundColor: Colors.orangeAccent),
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
}