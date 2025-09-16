

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProductImage extends StatelessWidget {
  // ✅ MUDANÇA: Agora recebe a URL diretamente
  final String? imageUrl;
  final double width;
  final double height;
  final double iconSize;

  const ProductImage({
    super.key,
    required this.imageUrl, // Recebe a URL em vez do objeto product
    this.width = 56.0,   // Ajustei para um tamanho de lista padrão
    this.height = 56.0,
    this.iconSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    // A lógica agora usa a `imageUrl` recebida diretamente
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.grey.shade100, // Um fundo sutil para o placeholder
        borderRadius: BorderRadius.circular(8),
      ),
      child: (imageUrl != null)
          ? CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.0)),
        ),
        errorWidget: (context, url, error) => _buildDefaultImage(),
      )
          : _buildDefaultImage(),
    );
  }

  Widget _buildDefaultImage() {
    return Center(
      child: SvgPicture.asset(
        'assets/icons/food1.svg',
        width: iconSize,
        height: iconSize,
        colorFilter: ColorFilter.mode(Colors.grey.shade400, BlendMode.srcIn),
      ),
    );
  }
}