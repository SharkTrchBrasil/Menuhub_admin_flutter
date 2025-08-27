import 'package:flutter/material.dart';


class SliverFilterBarDelegateProduct extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  SliverFilterBarDelegateProduct({required this.child, this.height = 72.0});

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // ✅ CORREÇÃO: Removemos o Material/elevation.
    // Agora é um Container simples que apenas posiciona o child.
    return Container(
      height: height,
      // Cor de fundo da área do filtro
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SliverFilterBarDelegateProduct oldDelegate) =>
      height != oldDelegate.height || child != oldDelegate.child;
}