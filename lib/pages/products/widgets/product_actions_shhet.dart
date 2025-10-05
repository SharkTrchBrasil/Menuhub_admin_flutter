import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:totem_pro_admin/core/enums/category_type.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_panel.dart';



import '../../../core/helpers/sidepanel.dart';
import '../../../models/products/product.dart';
import '../../product_flavors/flavor_edit_panel.dart';
import '../cubit/products_cubit.dart';

class ProductActionsSheet extends StatefulWidget {
  final int storeId;
  final Product product;
  final Category parentCategory;
  final String displayPrice; // ✅ Já é String
  final ProductsCubit productsCubit;

  const ProductActionsSheet({
    super.key,
    required this.storeId,
    required this.product,
    required this.parentCategory,
    required this.displayPrice,
    required this.productsCubit,
  });

  @override
  State<ProductActionsSheet> createState() => ProductActionsSheetState();
}

class ProductActionsSheetState extends State<ProductActionsSheet> {
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final FocusNode _priceFocusNode;
  late final FocusNode _stockFocusNode;
  late bool _isStockControlled;

  @override
  void initState() {
    super.initState();


    _priceController = TextEditingController(text: widget.displayPrice);

    _stockController = TextEditingController(
      text: widget.product.stockQuantity?.toString() ?? '0',
    );

    _priceFocusNode = FocusNode()..addListener(_onPriceFocusChange);
    _stockFocusNode = FocusNode()..addListener(_onStockFocusChange);
    _isStockControlled = widget.product.controlStock;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _stockController.dispose();
    _priceFocusNode.dispose();
    _stockFocusNode.dispose();
    super.dispose();
  }

  void _onPriceFocusChange() {
    if (!_priceFocusNode.hasFocus) _updatePrice();
  }

  void _onStockFocusChange() {
    if (!_stockFocusNode.hasFocus) _updateStock();
  }


  void _updatePrice() {
    final originalPriceText = widget.displayPrice;
    final newPriceText = _priceController.text;

    // Só atualiza se o texto mudou
    if (originalPriceText != newPriceText) {
      try {
        final priceInCents = (UtilBrasilFields.converterMoedaParaDouble(newPriceText) * 100).toInt();

        widget.productsCubit.updateProductPriceInCategory(
          storeId: widget.storeId,
          productId: widget.product.id!,
          categoryId: widget.parentCategory.id!,
          newPrice: priceInCents,
        );
      } catch (e) {
        // Reverte em caso de erro
        _priceController.text = originalPriceText;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar preço: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _updateStock() {
    final parsedQuantity = int.tryParse(_stockController.text) ?? 0;
    final newControlStatus = parsedQuantity > 0;

    if (_isStockControlled != newControlStatus) {
      setState(() {
        _isStockControlled = newControlStatus;
      });
    }

    widget.productsCubit.updateStock(
      storeId: widget.storeId,
      product: widget.product,
      newQuantity: parsedQuantity,
    );
  }

  void _activateStockControl() {
    setState(() {
      _isStockControlled = true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stockFocusNode.requestFocus();
    });
  }


  void _openEditPanel() {
    // Fecha o BottomSheet que está aberto
    Navigator.of(context).pop();

    final isCustomizable = widget.parentCategory.type == CategoryType.CUSTOMIZABLE;

    // Decide qual painel abrir
    final Widget panelToOpen = isCustomizable
        ? FlavorEditPanel(
      storeId: widget.storeId,
      product: widget.product,
      parentCategory: widget.parentCategory,
      onSaveSuccess: () {
        Navigator.of(context).pop(); // Fecha o painel

      },
      onCancel: () => Navigator.of(context).pop(),
    )
        : ProductEditPanel(
      storeId: widget.storeId,
      product: widget.product,
      onSaveSuccess: () {
        Navigator.of(context).pop(); // Fecha o painel

      },
      onCancel: () => Navigator.of(context).pop(),
    );

    // Usa o seu helper para abrir o painel lateral escolhido
    showResponsiveSidePanel(context, panelToOpen);
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        Product currentProduct = widget.product;
        if (state is StoresManagerLoaded) {
          try {
            currentProduct = state.activeStore!.relations.products.firstWhere(
                  (p) => p.id == widget.product.id,
            );
          } catch (e) {
            // Mantém a versão antiga se não encontrar
          }
        }

        final link = widget.product.categoryLinks.firstWhere(
              (l) => l.categoryId == widget.parentCategory.id,
        );

        final isAvailableInThisCategory = link.isAvailable;
        final isCustomizable = widget.parentCategory.type == CategoryType.CUSTOMIZABLE;

        return Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Ações do produto',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Campos de Preço e Estoque
              if (!isCustomizable)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Preço',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            TextField(
                              controller: _priceController,
                              focusNode: _priceFocusNode,
                              decoration: const InputDecoration(
                                isDense: true,
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                CentavosInputFormatter(moeda: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _isStockControlled
                            ? _buildStockDetails()
                            : _buildStockControlWidget(),
                      ),
                    ],
                  ),
                ),
              const Divider(height: 1),

              // Lista de Ações
              ListTile(
                leading: Icon(
                  isAvailableInThisCategory ? Icons.pause : Icons.play_arrow,
                  color: isAvailableInThisCategory ? Colors.orange : Colors.green,
                ),
                title: Text(
                  isAvailableInThisCategory
                      ? 'Pausar nesta categoria'
                      : 'Ativar nesta categoria',
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.productsCubit.toggleAvailabilityInCategory(
                    storeId: widget.storeId,
                    product: widget.product,
                    parentCategory: widget.parentCategory,
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar item'),

                onTap: _openEditPanel,
              ),

              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remover da categoria'),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.productsCubit.removeProductFromCategory(
                    storeId: widget.storeId,
                    productId: widget.product.id!,
                    categoryId: widget.parentCategory.id!,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStockControlWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estoque', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          icon: const Icon(Icons.inventory_2_outlined, size: 16),
          label: const Text('Ativar Controle'),
          onPressed: _activateStockControl,
        ),
      ],
    );
  }

  Widget _buildStockDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estoque', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        TextField(
          controller: _stockController,
          focusNode: _stockFocusNode,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, size: 20),
              tooltip: 'Zerar e desativar estoque',
              onPressed: () {
                _stockController.text = '0';
                _updateStock();
              },
            ),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }
}