
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_card_desktop.dart';
import 'package:totem_pro_admin/pages/products/widgets/product_card_mobile.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/services/dialog_service.dart';

// ✅ TORNADO STATELESSWIDGET: Mais simples e performático
class ProductCardItem extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback onTap;
  final int storeId;

  const ProductCardItem({
    super.key,
    required this.product,
    required this.isSelected,
    required this.onTap,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    // O Card e o InkWell agora envolvem o ResponsiveBuilder
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: ResponsiveBuilder(
          mobileBuilder: (context, constraints) =>
              ProductCardMobile(
                storeId: storeId,
                product: product,
                isSelected: isSelected,
                onTap: onTap,
              ),
          desktopBuilder: (context, constraints) =>
              ProductCardDesktop(
                storeId: storeId,
                product: product,
                isSelected: isSelected,
                onTap: onTap,
              ),
        ),
      ),
    );
  }
}

