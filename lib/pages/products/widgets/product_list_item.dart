import 'package:brasil_fields/brasil_fields.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';



import '../../../core/di.dart';

import '../../../models/product.dart';
import '../../../repositories/product_repository.dart';
import '../../../services/dialog_service.dart';

// ✅ 1. CONVERTIDO PARA STATEFULWIDGET
class ProductListItem extends StatefulWidget {
  final int storeId;
  final Product product;

  const ProductListItem({
    super.key,
    required this.storeId,
    required this.product,
  });

  @override
  State<ProductListItem> createState() => _ProductListItemState();
}

class _ProductListItemState extends State<ProductListItem> {
  // Para gerenciar o estado expandido dos complementos
  bool _isExpanded = false;

  // Controladores para os campos de texto
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;

  // Gerencia o foco para salvar o preço/estoque ao sair do campo
  late final FocusNode _priceFocusNode;
  late final FocusNode _stockFocusNode;

  @override
  void initState() {
    super.initState();

    // Inicializa os controladores com os valores do produto
    _priceController = TextEditingController(
      text: UtilBrasilFields.obterReal((widget.product.basePrice ?? 0) / 100),
    );
    _stockController = TextEditingController(
      text: widget.product.stockQuantity?.toString() ?? '0',
    );

    // Inicializa os FocusNodes e adiciona listeners para salvar ao perder o foco
    _priceFocusNode = FocusNode();
    _stockFocusNode = FocusNode();

    _priceFocusNode.addListener(_onPriceFocusChange);
    _stockFocusNode.addListener(_onStockFocusChange);
  }

  @override
  void dispose() {
    // Limpeza para evitar vazamentos de memória
    _priceController.dispose();
    _stockController.dispose();
    _priceFocusNode.removeListener(_onPriceFocusChange);
    _priceFocusNode.dispose();
    _stockFocusNode.removeListener(_onStockFocusChange);
    _stockFocusNode.dispose();
    super.dispose();
  }

  /// Garante que se o produto for atualizado externamente (via socket),
  /// os campos de texto locais também sejam atualizados.
  @override
  void didUpdateWidget(covariant ProductListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product != oldWidget.product) {
      // Atualiza o controlador de preço se o valor mudou
      final newPriceFormatted = UtilBrasilFields.obterReal((widget.product.basePrice ?? 0) / 100);
      if (_priceController.text != newPriceFormatted) {
        _priceController.text = newPriceFormatted;
      }
      // Atualiza o controlador de estoque se o valor mudou
      final newStock = widget.product.stockQuantity?.toString() ?? '0';
      if (_stockController.text != newStock) {
        _stockController.text = newStock;
      }
    }
  }

  // Função chamada quando o foco do campo de preço muda
  void _onPriceFocusChange() {
    // Se o campo perdeu o foco, tentamos salvar
    if (!_priceFocusNode.hasFocus) {
      _updateProductField(
        newValue: _priceController.text,
        isPrice: true,
      );
    }
  }

  // Função chamada quando o foco do campo de estoque muda
  void _onStockFocusChange() {
    if (!_stockFocusNode.hasFocus) {
      _updateProductField(
        newValue: _stockController.text,
        isPrice: false,
      );
    }
  }

  /// Lógica centralizada para atualizar um campo do produto
  Future<void> _updateProductField({required String newValue, required bool isPrice}) async {
    int? originalValue;
    int? parsedValue;
    Product updatedProduct;

    if (isPrice) {
      originalValue = widget.product.basePrice;
      parsedValue = (UtilBrasilFields.converterMoedaParaDouble(newValue) * 100).toInt();
      updatedProduct = widget.product.copyWith(basePrice: parsedValue);
    } else {
      originalValue = widget.product.stockQuantity;
      parsedValue = int.tryParse(newValue) ?? 0;
      updatedProduct = widget.product.copyWith(stockQuantity: parsedValue);
    }

    // Só salva se o valor realmente mudou
    if (originalValue != parsedValue) {
      try {
        await getIt<ProductRepository>().saveProduct(widget.storeId, updatedProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.product.name}: ${isPrice ? "Preço" : "Estoque"} atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Em caso de erro, reverte a mudança no campo de texto
        setState(() {
          if (isPrice) {
            _priceController.text = UtilBrasilFields.obterReal((originalValue ?? 0) / 100);
          } else {
            _stockController.text = originalValue?.toString() ?? '0';
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasComplements = widget.product.variantLinks!.isNotEmpty;
    // ✅ 4. ESTILO VISUAL PARA ITENS PAUSADOS
    final bool isAvailable = widget.product.available;
    final Color textColor = isAvailable ? Colors.black : Colors.grey.shade500;

    return Column(
      children: [
        // LINHA PRINCIPAL DO PRODUTO
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0, vertical: 14.0),
          child: Row(
            children: [
              // Imagem do produto com filtro cinza se pausado
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    isAvailable ? Colors.transparent : Colors.grey,
                    BlendMode.saturation,
                  ),
                  child: widget.product.image?.url != null
                ? CachedNetworkImage(
                imageUrl: widget.product.image!.url!,
                  width: 60,
                  height: 48,
                  fit: BoxFit.cover,
                  // O que mostrar enquanto a imagem carrega pela primeira vez
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
                  ),
                  // O que mostrar se houver um erro ao carregar
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
          : Container(width: 60, height: 48, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),



                ),
              ),
              const SizedBox(width: 12),
              // Nome e descrição do produto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 4),
                    if (widget.product.description.isNotEmpty)
                      Text(widget.product.description, style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // // ✅ 2. NOVO LAYOUT DE AÇÕES
              // // Botão de Complementos (condicional)
              // if (hasComplements) ...[
              //   OutlinedButton.icon(
              //     icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              //     label:  ResponsiveBuilder.isMobile(context) ? Text('') : Text('Complementos'),
              //     onPressed: () => setState(() => _isExpanded = !_isExpanded),
              //   ),
              //   const SizedBox(width: 16),
              // ],

              if (ResponsiveBuilder.isDesktop(context)) ..._buildDesktopActions(textColor) else ..._buildMobileActions(),


            ],
          ),
        ),

        // LISTA DE COMPLEMENTOS (expansível)
        if (_isExpanded) _buildComplementsList(),
      ],
    );
  }

  // Métodos de construção de layout para manter o código limpo
  List<Widget> _buildDesktopActions(Color textColor) {

    final bool isAvailable = widget.product.available;

    return [

      Tooltip(
        message: 'Estoque',
        child: SizedBox(
          width: 80,
          child: TextField(
            controller: _stockController,
            focusNode: _stockFocusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Tooltip(
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
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ),

      const SizedBox(width: 12),

      // Botão de Pausar/Ativar
      IconButton(
        icon: Icon(isAvailable ? Icons.pause_circle_outline : Icons.play_circle_outline, color: isAvailable ? Colors.orange : Colors.green),
        tooltip: isAvailable ? 'Pausar item' : 'Ativar item',
        onPressed: () async {
          final updatedProduct = widget.product.copyWith(available: !isAvailable);
          // Aqui não precisamos recarregar a lista, o estado do cubit fará isso
          await getIt<ProductRepository>().saveProduct(widget.storeId, updatedProduct);
        },
      ),

      // Menu de Opções
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, ),
        onSelected: (value) {
          if (value == 'edit') {
            context.go('/stores/${widget.storeId}/products/${widget.product.id}', extra: widget.product);
          } else if (value == 'delete') {
            _deleteProduct(context, widget.storeId, widget.product);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem<String>(value: 'edit', child: Text('Editar item')),
          const PopupMenuItem<String>(value: 'delete', child: Text('Remover item')),
        ],
      ),

    ];
  }

  List<Widget> _buildMobileActions() {
    return [
      IconButton(
        icon: Icon(widget.product.available ? Icons.pause_circle_outline : Icons.play_circle_outline, color: widget.product.available ? Colors.orange : Colors.green),
        tooltip: widget.product.available ? 'Pausar item' : 'Ativar item',
        onPressed: () async {
          final updatedProduct = widget.product.copyWith(available: !widget.product.available);
          await getIt<ProductRepository>().saveProduct(widget.storeId, updatedProduct);
        },
      ),
      IconButton(
        icon: const Icon(Icons.more_vert),
        tooltip: 'Mais ações',
        onPressed: () => _showMobileActionSheet(context),
      ),
    ];
  }


  // Widget para a lista de complementos
  Widget _buildComplementsList() {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Grupos de Complementos Vinculados:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // Mapeia os links de variantes para exibir os nomes
          ...widget.product.variantLinks!.map((link) {
            return Text('- ${link.variant.name}');
          }).toList(),
        ],
      ),
    );
  }


  // ✅ NOVO MÉTODO PARA MOSTRAR O BOTTOMSHEET NO MOBILE
  void _showMobileActionSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.only(
          topEnd: Radius.circular(25),
          topStart: Radius.circular(25),
        ),
      ),


      builder: (ctx) {
        // Usamos um StatefulBuilder para que o BottomSheet possa atualizar seu próprio estado (ex: ícone de pausar)
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final isAvailable = widget.product.available;
            return Container(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Ações do produto',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),

                  // Campos de Preço e Estoque
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Preço',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _priceController,
                                focusNode: _priceFocusNode,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Estoque',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              TextField(
                                controller: _stockController,
                                focusNode: _stockFocusNode,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  // Lista de Ações
                  ListTile(
                    leading: Icon(isAvailable ? Icons.pause : Icons.play_arrow, color: isAvailable ? Colors.red : Colors.green),
                    title: Text(isAvailable ? 'Pausar item' : 'Ativar item', style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () async {
                      Navigator.of(ctx).pop(); // Fecha o bottom sheet
                      final updatedProduct = widget.product.copyWith(available: !isAvailable);
                      await getIt<ProductRepository>().saveProduct(widget.storeId, updatedProduct);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Editar item', style: TextStyle(fontWeight: FontWeight.w600)),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.go('/stores/${widget.storeId}/products/${widget.product.id}', extra: widget.product);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline, color: Colors.red),
                    title: const Text('Remover item', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600) ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      _deleteProduct(context, widget.storeId, widget.product);
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



















// Função de exclusão (movida para fora para manter o código limpo)
Future<void> _deleteProduct(BuildContext context, int storeId, Product product) async {
  final confirmed = await DialogService.showConfirmationDialog(
    context,
    title: 'Confirmar Exclusão',
    content: 'Tem certeza que deseja excluir o produto "${product.name}"?',
  );
  if (confirmed == true && context.mounted) {
    try {
      await getIt<ProductRepository>().deleteProduct(storeId, product.id!);
      // Não precisa mais do reload, o socket vai notificar o cubit
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao excluir: $e')));
      }
    }
  }
}