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

import '../../../core/helpers/edit_product_sidepanel.dart';
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

                const SizedBox(width: 12),
                Expanded(
                  child: Column(

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // ← Centraliza verticalmente
              children: [
                Text(widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),

                // COM PLACEHOLDER
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    widget.product.description?.isNotEmpty == true
                        ? widget.product.description!
                        : 'Sem descrição',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.product.description?.isNotEmpty == true
                          ? textColor.withOpacity(0.7)
                          : textColor.withOpacity(0.4), // Cor mais clara para placeholder
                      fontSize: 12,
                      fontStyle: widget.product.description?.isNotEmpty == true
                          ? FontStyle.normal
                          : FontStyle.italic, // Itálico para placeholder
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // ← Centraliza verticalmente
              children: [
                Text(widget.product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w700, color: textColor)),

                // COM PLACEHOLDER
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    widget.product.description?.isNotEmpty == true
                        ? widget.product.description!
                        : 'Sem descrição',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.product.description?.isNotEmpty == true
                          ? textColor.withOpacity(0.7)
                          : textColor.withOpacity(0.4), // Cor mais clara para placeholder
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontStyle: widget.product.description?.isNotEmpty == true
                          ? FontStyle.normal
                          : FontStyle.italic, // Itálico para placeholder
                    ),
                  ),
                ),
              ],
            ),
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


  void _openEditPanel() {


    // Chama o helper global passando as informações necessárias
    showEditProductPanel(
      context: context,
      product: widget.product,
      storeId: widget.storeId,
      parentCategory: widget.parentCategory, // Passa a categoria pai do contexto atual
      onSaveSuccess: () {
        // Você pode adicionar qualquer lógica extra aqui após o salvamento.
        // Por exemplo, atualizar a UI ou mostrar uma mensagem.
        print('Produto salvo, painel fechado!');
      },
    );
  }




  Widget _buildPriceDisplay() {


    // Se o texto do preço estiver indisponível ou zerado, mostra o chip de alerta.
    if (widget.displayPriceText.contains('indisponível') || widget.displayPriceText.contains('0,00')) {
      return InkWell(
        onTap: () => _openEditPanel(), // Permite clicar para corrigir
        child: const Chip(label: Text('⚠️ Sem Preço'), backgroundColor: Colors.orangeAccent),
      );
    }

    return
        Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('À partir de', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(width: 8),
        Text(
          widget.displayPriceText,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
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