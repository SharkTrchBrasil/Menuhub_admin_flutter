import 'package:brasil_fields/brasil_fields.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_actions_shhet.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';



import '../../../core/di.dart';

import '../../../core/enums/category_type.dart';
import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';
import '../../../repositories/product_repository.dart';
import '../../../services/dialog_service.dart';

// ✅ 1. CONVERTIDO PARA STATEFULWIDGET
class ProductListItem extends StatefulWidget {
  final int storeId;
  final Product product;
  final Category parentCategory;
  final int displayPrice;

  const ProductListItem({
    super.key,
    required this.storeId,
    required this.product,
    required this.parentCategory,
    required this.displayPrice,

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

    // ✅ 3. USA O NOVO PARÂMETRO PARA DEFINIR O VALOR INICIAL
    _priceController = TextEditingController(
      text: UtilBrasilFields.obterReal(widget.displayPrice / 100),
    );


    _stockController = TextEditingController(
      text: widget.product.stockQuantity.toString() ?? '0',
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





  @override
  void didUpdateWidget(covariant ProductListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ CORREÇÃO: Comparar o displayPrice que vem do pai
    if (widget.product != oldWidget.product || widget.displayPrice != oldWidget.displayPrice) {
      final newPriceFormatted = UtilBrasilFields.obterReal(widget.displayPrice / 100);
      if (_priceController.text != newPriceFormatted) {
        _priceController.text = newPriceFormatted;
      }
      final newStock = widget.product.stockQuantity.toString();
      if (_stockController.text != newStock) {
        _stockController.text = newStock;
      }
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

    // Chama o método específico do repositório para o VÍNCULO
    await getIt<ProductRepository>().toggleLinkAvailability(
      storeId: widget.storeId,
      productId: widget.product.id!,
      categoryId: widget.parentCategory.id!,
      isAvailable: !currentLinkAvailability, // Envia o novo status (invertido)
    );
    // O socket vai cuidar de atualizar a UI.
  }

  Future<void> _updatePrice() async {
    final originalPrice = widget.displayPrice;
    final parsedPrice = (UtilBrasilFields.converterMoedaParaDouble(_priceController.text) * 100).toInt();

    // Só chama a API se o valor realmente mudou
    if (originalPrice != parsedPrice) {
      try {
        // ✅ USA O MÉTODO OTIMIZADO DO REPOSITÓRIO
        await getIt<ProductRepository>().updateProductCategoryPrice(
          storeId: widget.storeId,
          productId: widget.product.id!,
          // Usa o ID da categoria pai para garantir que estamos atualizando o preço certo
          categoryId: widget.parentCategory.id!,
          newPrice: parsedPrice,
        );
        // Não precisamos de SnackBar de sucesso, o socket atualizará a UI
      } catch (e) {
        // Em caso de erro, reverte a mudança no campo de texto
        if (mounted) {
          setState(() {
            _priceController.text = UtilBrasilFields.obterReal(originalPrice / 100);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar o preço: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }


  Future<void> _deactivateAndClearStock() async {
    // Se já está em 0 e desativado, não faz nada
    if (widget.product.stockQuantity == 0 && !widget.product.controlStock) return;

    // Cria uma cópia do produto com os dois campos atualizados
    final updatedProduct = widget.product.copyWith(
      stockQuantity: 0,
      controlStock: false,
    );
    // Chama o método de update geral para salvar as duas alterações de uma vez
    await getIt<ProductRepository>().updateProduct(widget.storeId, updatedProduct);
  }


  void _updateStock() async {
    final originalQuantity = widget.product.stockQuantity;
    final parsedQuantity = int.tryParse(_stockController.text) ?? 0;

    // A nova regra de negócio: o controle de estoque só está ativo se a quantidade > 0
    final bool newControlStatus = parsedQuantity > 0;

    // Só chama a API se algo realmente mudou
    if (originalQuantity != parsedQuantity || widget.product.controlStock != newControlStatus) {
      try {
        final updatedProduct = widget.product.copyWith(
          stockQuantity: parsedQuantity,
          controlStock: newControlStatus, // Atualiza o status de controle junto
        );
        await getIt<ProductRepository>().updateProduct(widget.storeId, updatedProduct);
      }  catch (e) {
        if (mounted) {
          // setState(() {
          //   _stockController.text = originalValue.toString();
          // });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao atualizar o estoque: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }


  Future<void> _removeProductFromCategory() async {
    try {
      // Chama o novo método do repositório que criamos no backend
      await getIt<ProductRepository>().removeProductFromCategory(
        storeId: widget.storeId,
        productId: widget.product.id!,
        categoryId: widget.parentCategory.id!,
      );
      // O evento de socket cuidará de atualizar a UI
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
    final hasComplements = widget.product.variantLinks!.isNotEmpty;
    final link = widget.product.categoryLinks.firstWhere((l) => l.categoryId == widget.parentCategory.id);

    final isAvailableInThisCategory = link.isAvailable;


    final bool isCustomizable = widget.parentCategory.type == CategoryType.CUSTOMIZABLE; // ✅ Correto (com 'c' minúsculo)


    final Color textColor = isAvailableInThisCategory ? Colors.black : Colors.grey.shade500;

    return Container(
      decoration: BoxDecoration(
        color: isAvailableInThisCategory ? const Color(0xFFFFFFFF)  : const Color(0xFFF5F5F5) ,
        borderRadius: BorderRadius.circular(8),
        //   border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [




          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              children: [



                SizedBox(width: 10,),


                  _buildDefaultImage(isAvailableInThisCategory), // Senão, usa a lógica de imagem padrão

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                      const SizedBox(height: 4),

                        Text(widget.product.description ?? '', style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                const SizedBox(width: 16),


                if (ResponsiveBuilder.isDesktop(context))
                  ..._buildDesktopActions(textColor, isCustomizable, isAvailableInThisCategory)
                else
                  ..._buildMobileActions(isCustomizable, isAvailableInThisCategory),



              ],
            ),
          ),


          // Alerta de item sem preço (se aplicável)
          if (widget.displayPrice == 0)
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

          // LISTA DE COMPLEMENTOS (expansível)
          if (_isExpanded) _buildComplementsList(),
        ],
      ),
    );
  }



  List<Widget> _buildDesktopActions(Color textColor, bool isCustomizable, bool isAvailableInThisCategory) {
    if (isCustomizable) {
      // --- LAYOUT PARA SABORES (CUSTOMIZÁVEL) ---
      return [
        _buildPriceDisplay(),
        const SizedBox(width: 12),
        _buildSharedActionButtons(textColor,isCustomizable, isAvailableInThisCategory ),
      ];
    } else {
      // --- LAYOUT PARA PRODUTOS SIMPLES ---
      return [
        _buildStockField(isAvailableInThisCategory),
        const SizedBox(width: 12),
        _buildPriceField(isAvailableInThisCategory),
        const SizedBox(width: 12),
        _buildSharedActionButtons(textColor, isCustomizable, isAvailableInThisCategory),
      ];
    }
  }

  // Métodos para construir os campos de texto (refatorados)
  Widget _buildStockField(bool isAvailableInThisCategory) {




    return      Tooltip(
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
          border:  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          // ✅ Aplicar estilo desativado ao campo de estoque
          enabled: isAvailableInThisCategory,
          fillColor: isAvailableInThisCategory ? null : Colors.white70,
        ),
      ),
    ),
  );
  }
  Widget _buildPriceField(bool isAvailableInThisCategory) {

    return  Tooltip(
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
          border:  OutlineInputBorder(borderRadius: BorderRadius.circular(6)),

          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          // ✅ Aplicar estilo desativado ao campo de preço
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



        // Botão de Pausar/Ativar
        IconButton(
          icon: Icon(
              isAvailableInThisCategory ? Icons.pause_circle_outline : Icons.play_circle_outline,
              color: isAvailableInThisCategory ? Colors.green : Colors.orange
          ),
          tooltip: isAvailableInThisCategory ? 'Pausar item' : 'Ativar item',
          onPressed: _toggleAvailabilityInCategory,
        ),

        // Menu de Opções
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: textColor),
          onSelected: (value) {
            if (value == 'edit') {
              // ✅ LÓGICA DE NAVEGAÇÃO DINÂMICA
              if (isCustomizable) {
                // Navega para a tela de edição de SABORES
                context.push('/stores/${widget.storeId}/products/${widget.product.id}/edit-flavor', extra: widget.product);
              } else {
                // Navega para a tela de edição de ITENS SIMPLES
                context.push('/stores/${widget.storeId}/products/${widget.product.id}', extra: widget.product);
              }
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











  // Lógica de imagem padrão
  Widget _buildDefaultImage(bool isAvailable) {
    return       ClipRRect(
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
            height: 68,
            fit: BoxFit.cover,
            // O que mostrar enquanto a imagem carrega pela primeira vez
            placeholder: (context, url) => Container(
              color: Colors.grey.shade200,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2.0)),
            ),
            // O que mostrar se houver um erro ao carregar
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

// Em _ProductListItemState

  Widget _buildPriceDisplay() { // O parâmetro 'isCustomizable' não era necessário aqui

    // 1. Verifica se a lista de preços do produto (que vem da API) não está vazia.
    final hasPrices = widget.product.prices.isNotEmpty;

    // 2. Se houver preços, encontra o menor valor.
    //    O 'reduce' compara cada preço com o próximo e mantém sempre o menor.
    //    Esta é a forma correta de obter o preço "À partir de".
    final startingPrice = hasPrices
        ? widget.product.prices.map((p) => p.price).reduce((a, b) => a < b ? a : b)
        : 0;

    // 3. Se houver preços, mostra o valor formatado.
    return hasPrices
        ? Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('À partir de', style: TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          UtilBrasilFields.obterReal(startingPrice / 100),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    )
    // 4. Se NÃO houver preços, mostra o aviso "Sem Preço", que agora é clicável.
        : InkWell(
      onTap: () {
        // Reutiliza a mesma lógica do dialog que já tínhamos
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
                  // Navega para a tela de edição de sabores
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

  List<Widget> _buildMobileActions( bool isCustomizable, bool isAvailableInThisCategory) {
    return [
      IconButton(
        icon: Icon(isAvailableInThisCategory ? Icons.pause_circle_outline : Icons.play_circle_outline, color: isAvailableInThisCategory ? Colors.orange : Colors.green),
        tooltip: widget.product.available ? 'Pausar item' : 'Ativar item',
        onPressed: _toggleAvailabilityInCategory,
      ),
      IconButton(
        icon: const Icon(Icons.more_vert),
        tooltip: 'Mais ações',
        onPressed: () => _showMobileActionSheet(context,  isCustomizable),
      ),
    ];
  }


  // Widget para a lista de complementos
  Widget _buildComplementsList() {

    // ✅ LÓGICA SEGURA: Só constrói a lista se ela não for nula e não estiver vazia
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
          // Mapeia os links de variantes para exibir os nomes
          ...widget.product.variantLinks!.map((link) {
            return Text('- ${link.variant.name}');
          }).toList(),
        ],
      ),
    );
  }

  // Em _ProductListItemState

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
        // ✅ 1. O CONTEÚDO AGORA É UM WIDGET SEPARADO E INTELIGENTE
        return ProductActionsSheet(
         displayPrice: widget.displayPrice,
          storeId: widget.storeId,
          product: widget.product,
          parentCategory: widget.parentCategory,

        );
      },
    );
  }

// ... (seus outros métodos, como _buildStockDetails, _buildStockControlWidget, etc., podem ser movidos para o novo widget abaixo se forem exclusivos dele)
  //
  // void _showMobileActionSheet(BuildContext context,  bool isCustomizable) {
  //   showModalBottomSheet(
  //     isScrollControlled: true,
  //     context: context,
  //     backgroundColor: Colors.white,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadiusDirectional.only(
  //         topEnd: Radius.circular(25),
  //         topStart: Radius.circular(25),
  //       ),
  //     ),
  //
  //
  //     builder: (ctx) {
  //       // Usamos um StatefulBuilder para que o BottomSheet possa atualizar seu próprio estado (ex: ícone de pausar)
  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setModalState) {
  //
  //
  //           // ✅ 1. A LÓGICA DE ESTADO AGORA FICA AQUI DENTRO
  //           //    Isso garante que a UI reflita o estado mais recente do produto
  //           final link = widget.product.categoryLinks.firstWhere((l) => l.categoryId == widget.parentCategory.id);
  //           final isAvailableInThisCategory = link.isAvailable;
  //
  //
  //           return Container(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //
  //                 Padding(
  //                   padding: const EdgeInsets.only(top: 8.0, bottom: 16),
  //                   child: Row(
  //                     children: [
  //                       Expanded(
  //                         child: Align(
  //                           alignment: Alignment.center,
  //                           child: Text(
  //                             'Ações do produto',
  //                             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
  //                           ),
  //                         ),
  //                       ),
  //                       IconButton(
  //                         icon: Icon(Icons.close),
  //                         onPressed: () => Navigator.of(ctx).pop(),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //
  //                 if(!isCustomizable)
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
  //                   child: Row(
  //                     children: [
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           children: [
  //                             const Text(
  //                               'Preço',
  //                               style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
  //                             ),
  //                             const SizedBox(height: 4),
  //                             TextField(
  //                               controller: _priceController,
  //                               focusNode: _priceFocusNode,
  //                               decoration: const InputDecoration(
  //                                 isDense: true,
  //                                 border: OutlineInputBorder(),
  //                                 contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  //                               ),
  //                               keyboardType: const TextInputType.numberWithOptions(decimal: true),
  //                               inputFormatters: [
  //                                 FilteringTextInputFormatter.digitsOnly,
  //                                 CentavosInputFormatter(moeda: true),
  //                               ],
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                       const SizedBox(width: 16),
  //
  //
  //                       Expanded(
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.start,
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           children: [
  //
  //                             widget.product.controlStock ? _buildStockDetails(setModalState)
  //
  //                            : _buildStockControlWidget() ,
  //
  //
  //
  //
  //
  //                           ],
  //                         ),
  //                       ),
  //
  //
  //
  //
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),
  //                 if(!isCustomizable)
  //                 const Divider(height: 1),
  //                 const SizedBox(height: 16),
  //                 // Lista de Ações
  //                 ListTile(
  //                   leading: Icon(isAvailableInThisCategory ? Icons.pause : Icons.play_arrow, color: isAvailableInThisCategory ? Colors.red : Colors.green),
  //                   title: Text(isAvailableInThisCategory ? 'Pausar item' : 'Ativar item', style: TextStyle(fontWeight: FontWeight.w600)),
  //                   onTap: (){
  //                     Navigator.of(ctx).pop();
  //                     _toggleAvailabilityInCategory;
  //                   }
  //                 ),
  //                 ListTile(
  //                   leading: const Icon(Icons.edit),
  //                   title: const Text('Editar item', style: TextStyle(fontWeight: FontWeight.w600)),
  //                   onTap: () {
  //                     Navigator.of(ctx).pop();
  //
  //                     // ✅ LÓGICA DE NAVEGAÇÃO DINÂMICA
  //                     if (isCustomizable) {
  //                       // Navega para a tela de edição de SABORES
  //                       context.push('/stores/${widget.storeId}/products/${widget.product.id}/edit-flavor', extra: widget.product);
  //                     } else {
  //                       // Navega para a tela de edição de ITENS SIMPLES
  //                       context.push('/stores/${widget.storeId}/products/${widget.product.id}', extra: widget.product);
  //                     }
  //
  //
  //
  //                //     context.go('/stores/${widget.storeId}/products/${widget.product.id}', extra: widget.product);
  //
  //
  //                   },
  //                 ),
  //                 ListTile(
  //                   leading: const Icon(Icons.delete_outline, color: Colors.red),
  //                   title: const Text('Remover item', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600) ),
  //                   onTap: () {
  //                     Navigator.of(ctx).pop();
  //                   _removeProductFromCategory();
  //                   },
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }




}
















