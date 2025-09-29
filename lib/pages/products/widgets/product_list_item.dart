import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';

import '../../../models/category.dart';

import '../../../models/products/product.dart';
import 'product_list_item_desktop.dart';
import 'product_list_item_mobile.dart';

class ProductListItem extends StatelessWidget {
  final int storeId;
  final Product product;
  final Category parentCategory;
  final String displayPriceText;

  const ProductListItem({
    super.key,
    required this.storeId,
    required this.product,
    required this.parentCategory,
    required this.displayPriceText,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        mobileBuilder: (BuildContext context, BoxConstraints constraints) {


          return ProductListItemMobile(
            storeId: storeId,
            product: product,
            parentCategory: parentCategory,
            displayPriceText: displayPriceText,
          );
        },

    desktopBuilder: (BuildContext context, BoxConstraints constraints) { return ProductListItemDesktop(
      storeId: storeId,
      product: product,
      parentCategory: parentCategory,
      displayPriceText: displayPriceText,
    ); },

    );

  }
}