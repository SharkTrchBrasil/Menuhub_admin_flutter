// Garanta que você tenha esses pacotes no seu pubspec.yaml:
// cached_network_image: ^3.3.1
// flutter_svg: ^2.0.10+1

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem_pro_admin/models/product.dart';

// ✅ RENOMEADO: Removemos o '_' para indicar que é um widget reutilizável
class ProductImage extends StatelessWidget {
  final Product product;
  final double width;
  final double height;
  final double iconSize;

  const ProductImage({
    super.key,
    required this.product,
    this.width = 80.0,
    this.height = 80.0,
    this.iconSize = 60.0,
  });

  @override
  Widget build(BuildContext context) {

    final imageUrl = product.image?.url;

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias, // Garante que a imagem respeite as bordas
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
     //   color: Colors.grey[100], // Fundo para o placeholder
      ),
      // ✅ 2. LÓGICA CONDICIONAL LIMPA
      child: (imageUrl != null && imageUrl.isNotEmpty)
      // Se tiver uma URL válida, usa o CachedNetworkImage
          ? CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        // ✅ 3. FEEDBACK VISUAL: Mostra um loading enquanto a imagem baixa
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2.0),
        ),
        // Mostra a imagem padrão em caso de erro de rede
        errorWidget: (context, url, error) => _buildDefaultImage(),
      )
      // Se não tiver URL, mostra a imagem padrão
          : _buildDefaultImage(),
    );
  }

  Widget _buildDefaultImage() {
    return Center(
      child: SvgPicture.asset(
        'assets/icons/food1.svg', // Adapte para o caminho do seu SVG
        width: iconSize,
        height: iconSize,

      ),
    );
  }
}