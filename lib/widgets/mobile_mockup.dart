import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';

import '../core/enums/ui_display_mode.dart';

import '../models/products/product.dart';
import '../models/products/product_variant_link.dart';
import '../models/variant_option.dart';
//----------- WIDGETS DO MOCKUP -----------//

/// O Widget principal que desenha a moldura do celular
class ProductPhoneMockup extends StatelessWidget {
  final Product product;
  final double? width;  // ✅ Parâmetro opcional para largura
  final double? height; // ✅ Parâmetro opcional para altura
 final bool? showVariants;
  const ProductPhoneMockup({
    super.key,
    required this.product,
    this.width,
    this.height,
    this.showVariants
  });

  @override
  Widget build(BuildContext context) {

    // Define valores padrão se os parâmetros não forem fornecidos
    final double finalWidth = width ?? 240.0;
    final double finalHeight = height ?? 500.0;
    final bool showVar = showVariants ?? false;
    return Container(
      width: finalWidth,   // Usa a largura final
      height: finalHeight, // Usa a altura final
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.black, width: 2),
        color: Colors.black,

      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Scaffold(
          // Usamos um Scaffold para facilitar a estrutura
          backgroundColor: Colors.white,
          body: _ProductPageLayout(product: product,   mockupWidth: finalWidth,showVar: showVar,),
        ),
      ),
    );
  }
}

/// Widget que recria o layout da página do produto
class _ProductPageLayout extends StatelessWidget {
  final Product product;
  final double mockupWidth; // ✅ Recebe a largura do pai
final bool showVar;
  const _ProductPageLayout({
    required this.product,
    required this.mockupWidth,
    required this.showVar
  });


  @override
  Widget build(BuildContext context) {
    // ✅ Usa a largura recebida via construtor para os cálculos
    final double imageHeight = mockupWidth * 0.9;
    final double contentOverlapPosition = imageHeight - 30;
    // ✅ 1. LÓGICA DEFENSIVA: Verificamos se há uma imagem válida.
    final bool hasImage = product.images.isNotEmpty && product.images.first.url != null;
    final String? imageUrl = hasImage ? product.images.first.url : null;

    return Stack(
      children: [
        // SingleChildScrollView permite que o conteúdo role
        SingleChildScrollView(
          child: Stack(
            children: [
              // Imagem do produto no topo
              CachedNetworkImage(


                imageUrl: imageUrl ?? "https://img.freepik.com/vetores-premium/conjunto-de-desenhos-animados-de-fast-food-sem-costura_1639-39822.jpg",


                height: imageHeight,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              // Conteúdo que sobrepõe a imagem
              Padding(
                padding: EdgeInsets.only(top: contentOverlapPosition),
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  padding: const EdgeInsets.fromLTRB(0, 24, 0, 120),
                  child: _buildContentColumn(context, showVar),
                ),
              ),
            ],
          ),
        ),
        // Botão de fechar sobre a imagem

      ],
    );
  }

  Widget _buildContentColumn(BuildContext context, bool showVar) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nome do Produto
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            (product.name?.isNotEmpty == true)
                ? product.name!
                : 'Nome do produto',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
// Descrição do Produto
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            (product.description?.isNotEmpty == true)
                ? product.description!
                : 'Descrição do produto',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[700]),
          ),
        ),

        const SizedBox(height: 16),
        // Preço
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            product.price?.toPrice() ?? "0,00",

            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.deepOrange,
            ),
          ),
        ),
        const SizedBox(height: 24),
        if(showVar)
        ListView.separated(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (_, i) {
            // Pega o objeto de ligação (que contém as regras e o variant)
            final productLink = product.variantLinks![i];
            // Passa o link completo para o widget de mock
            return _MockVariantWidget(link: productLink);
          },
          separatorBuilder: (_, __) => const SizedBox(height: 20),
          // O tamanho da lista é o número de links de variantes
          itemCount: product.variantLinks?.length ?? 0,
        ),


      ],
    );
  }
}


/// Widget para simular uma seção de variante (agora recebe ProductVariantLink)
class _MockVariantWidget extends StatelessWidget {
  final ProductVariantLink link;
  const _MockVariantWidget({required this.link});

  String get details {
    final min = link.minSelectedOptions;
    final max = link.maxSelectedOptions;
    if (min == 0) return 'Escolha até $max opç${max > 1 ? 'ões' : 'ão'}';
    if (min == max) return 'Escolha $max opç${max > 1 ? 'ões' : 'ão'}';
    return 'Escolha de $min até $max opções';
  }

  // Helper para formatar preço de centavos para R$
  String _formatPrice(int? priceInCents) {
    if (priceInCents == null || priceInCents == 0) return '';
    final priceInReal = priceInCents / 100.0;
    return '+ R\$ ${priceInReal.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(child: Text(link.variant.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                const SizedBox(width: 8),
                if(link.isRequired)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: const Text('OBRIGATÓRIO', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: Text(details, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, indent: 16, endIndent: 16,),
          ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: link.variant.options.length,
            itemBuilder: (context, index) {
              final option = link.variant.options[index];
              final isSingleSelection = link.uiDisplayMode == UIDisplayMode.SINGLE;
              return _MockOptionWidget(
                name: option.resolvedName,
                price: _formatPrice(option.resolvedPrice),
                isRadio: isSingleSelection,
                isSelected: isSingleSelection && index == 0, // No modo rádio, seleciona o primeiro por padrão
              );
            },
          ),
        ],
      ),
    );
  }
}



/// Widget para simular uma opção (agora mais genérico)
class _MockOptionWidget extends StatelessWidget {
  final String name;
  final String price;
  final bool isRadio; // True para RadioButton, false para Checkbox
  final bool isSelected;

  const _MockOptionWidget({
    required this.name,
    required this.price,
    this.isRadio = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Icon(
            isRadio
                ? (isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked)
                : (isSelected ? Icons.check_box : Icons.check_box_outline_blank),
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 15))),
          Text(price, style: const TextStyle(fontSize: 15, color: Colors.black54)),
        ],
      ),
    );
  }
}


