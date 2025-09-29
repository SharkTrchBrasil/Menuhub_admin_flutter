
import 'package:flutter/material.dart';

import 'package:totem_pro_admin/core/responsive_builder.dart';

import 'package:totem_pro_admin/pages/products/widgets/product_card_desktop.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_card_mobile.dart';

import '../../../models/products/product.dart';

class ProductCardItem extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback onTap;
  final int storeId;
  final VoidCallback onStatusToggle;

  const ProductCardItem({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.storeId,
    required this.onStatusToggle,
  });

  @override
  Widget build(BuildContext context) {
    // O Card e o InkWell agora envolvem o ResponsiveBuilder
    return InkWell(
      onTap: onTap,
      child: ResponsiveBuilder(
        mobileBuilder: (context, constraints) =>
            ProductCardMobile(
              storeId: storeId,
              product: product,
              isSelected: isSelected,
              onTap: onTap,
              onStatusChanged: onStatusToggle,
            ),
        desktopBuilder: (context, constraints) =>
            ProductCardDesktop(
              storeId: storeId,
              product: product,
              isSelected: isSelected,
              onTap: onTap,
              onStatusToggle: onStatusToggle,

            ),
      ),
    );
  }
}

