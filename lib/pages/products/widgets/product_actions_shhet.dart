// Garanta que todos estes imports estejam no topo do seu arquivo
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/enums/category_type.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';

import '../cubit/products_cubit.dart';

class ProductActionsSheet extends StatefulWidget {
  final int storeId;
  final Product product;
  final Category parentCategory;
  final int displayPrice;

  const ProductActionsSheet({
    required this.storeId,
    required this.product,
    required this.parentCategory,
    required this.displayPrice,
  });

  @override
  State<ProductActionsSheet> createState() => ProductActionsSheetState();
}

class ProductActionsSheetState extends State<ProductActionsSheet> {
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final FocusNode _priceFocusNode;
  late final FocusNode _stockFocusNode;

  // ✅ 1. VARIÁVEL DE ESTADO LOCAL PARA O CONTROLE DE ESTOQUE
  late bool _isStockControlled;

  @override
  void initState() {
    super.initState();
    // Usa 'widget.displayPrice' para o preço, pois é o preço contextual da categoria
    _priceController = TextEditingController(
      text: UtilBrasilFields.obterReal(widget.displayPrice / 100.0),
    );
    _stockController = TextEditingController(
      text: widget.product.stockQuantity.toString(),
    );
    _priceFocusNode = FocusNode()..addListener(_onPriceFocusChange);
    _stockFocusNode = FocusNode()..addListener(_onStockFocusChange);
    // Inicia o estado local com o valor do produto
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

  // --- MÉTODOS DE AÇÃO (AGORA VIVEM AQUI) ---

  void _onPriceFocusChange() {
    if (!_priceFocusNode.hasFocus) _updatePrice();
  }

  void _onStockFocusChange() {
    if (!_stockFocusNode.hasFocus) _updateStock();
  }

  // ✅ MÉTODO DE ATUALIZAR PREÇO (CHAMA O CUBIT)
  void _updatePrice() {
    final parsedPrice =
        (UtilBrasilFields.converterMoedaParaDouble(_priceController.text) * 100)
            .toInt();
    if (widget.displayPrice != parsedPrice) {
      context.read<ProductsCubit>().updateProductPriceInCategory(
        storeId: widget.storeId,
        productId: widget.product.id!,
        categoryId: widget.parentCategory.id!,
        newPrice: parsedPrice,
      );
    }
  }

  // ✅ MÉTODO DE ATUALIZAR ESTOQUE (CHAMA O CUBIT)
  void _updateStock() {
    final parsedQuantity = int.tryParse(_stockController.text) ?? 0;
    // A UI local é atualizada separadamente para uma resposta mais rápida
    final newControlStatus = parsedQuantity > 0;
    if (_isStockControlled != newControlStatus) {
      setState(() {
        _isStockControlled = newControlStatus;
      });
    }

    context.read<ProductsCubit>().updateStock(
      storeId: widget.storeId,
      product: widget.product,
      newQuantity: parsedQuantity,
    );
  }

  // ✅ 3. MÉTODO DE "ATIVAR" AGORA APENAS ATUALIZA A UI LOCAL
  void _activateStockControl() {
    setState(() {
      _isStockControlled = true;
    });
    // Pede foco para o campo de texto para o usuário começar a digitar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stockFocusNode.requestFocus();
    });
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
            /* Mantém a versão antiga se não encontrar */
          }
        }

        final link = widget.product.categoryLinks.firstWhere(
          (l) => l.categoryId == widget.parentCategory.id,
        );

        final isAvailableInThisCategory = link.isAvailable;

        final isCustomizable =
            widget.parentCategory.type == CategoryType.CUSTOMIZABLE;

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
                              keyboardType:
                                  const TextInputType.numberWithOptions(
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
                        child:
                            _isStockControlled
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
                  color:
                      isAvailableInThisCategory ? Colors.orange : Colors.green,
                ),
                title: Text(
                  isAvailableInThisCategory
                      ? 'Pausar nesta categoria'
                      : 'Ativar nesta categoria',
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<ProductsCubit>().toggleAvailabilityInCategory(
                    storeId: widget.storeId,
                    product: widget.product,
                    parentCategory: widget.parentCategory,
                  );
                },
              ),

              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Editar item'),
                onTap: () {
                  Navigator.of(context).pop(); // Fecha o menu de opções

                  final storeIdStr = widget.storeId.toString();
                  final productIdStr = currentProduct.id.toString();

                  if (isCustomizable) {
                    // ✅ Navega para a rota de edição de sabor usando o NOME e PARÂMETROS
                    context.goNamed(
                      'flavor-edit',
                      pathParameters: {
                        'storeId': storeIdStr,
                        'productId': productIdStr,
                      },
                      extra:
                          currentProduct, // O 'extra' ainda é útil aqui para a carga inicial!
                    );
                  } else {
                    // ✅ Navega para a rota de edição de produto usando o NOME e PARÂMETROS
                    context.goNamed(
                      'product-edit',
                      pathParameters: {
                        'storeId': storeIdStr,
                        'productId': productIdStr,
                      },
                      extra: currentProduct, // O 'extra' ainda é útil aqui!
                    );
                  }
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Remover da categoria'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<ProductsCubit>().removeProductFromCategory(
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
                // Zera o campo localmente
                _stockController.text = '0';
                // Chama a função de update, que agora sabe que 0 significa desativar
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
