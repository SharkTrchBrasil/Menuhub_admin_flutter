

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/models/store_payable.dart';
import 'package:totem_pro_admin/models/variant.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/pages/coupons/widgets/edit_coupon_page_dialog.dart';
import 'package:totem_pro_admin/pages/edit_payment_methods/edit_payment_methods.dart';
import 'package:totem_pro_admin/pages/edit_variant/edit_variant_page.dart';
import '../models/category.dart';
import '../pages/catalog_page/widgets/edit_basic_info_dialog.dart';
import '../pages/catalog_page/widgets/edit_url_link_dialog.dart';
import '../pages/categories/widgets/category_form_dialog.dart';
import '../pages/edit_product/widgets/edit_product_dialog.dart';
import '../pages/edit_variant/widgets/edit_variant_dialog.dart';
import '../pages/edit_variant_option/widget/edit_variant_option_dialog.dart';
import '../pages/payables/widgets/edit_payable_dialog.dart';
import '../pages/payment_methods/widgets/edit_payment_methods_dialog.dart';

class DialogService {
  static Future<void> showCategoryDialog(
      BuildContext context,
      int storeId, {
        int? categoryId,
        void Function(dynamic category)? onSaved,
      }) {
    return showDialog(
      context: context,
      builder: (_) => EditCategoryForm(
        storeId: storeId,
        id: categoryId,
        onSaved: onSaved,
      ),
    );
  }

  static Future<void> showProductDialog(
      BuildContext context,

      int storeId, {
        Category? category,
        int? productId,
        void Function(dynamic product)? onSaved,
      }) {
    return showDialog(
      context: context,
      builder: (_) => EditProductDialog(
        storeId: storeId,
        id: productId,
        onSaved: onSaved, category: category,
      ),
    );
  }

  static Future<void> showCouponsDialog(
      BuildContext context,
      int storeId, {
        int? couponsId,
        void Function(dynamic coupon)? onSaved,
      }) {
    return showDialog(
      context: context,
      builder: (_) => EditCouponPageDialog(
        storeId: storeId,
        id: couponsId,
        onSaved: onSaved,
      ),
    );
  }

  static Future<void> showUrlLinkDialog(
      BuildContext context,
      Store store, {
        void Function(Store updatedStore)? onSaved,
      }) {
    return showDialog(
      context: context,
      builder: (_) => EditUrlLinkDialog(
        store: store,
       // onSaved: onSaved,
      ),
    );
  }



  static Future<void> showPaymentDialog(
      BuildContext context,
      int storeId,

 { int? paymentId, void Function(StorePaymentMethod updatedStore)? onSaved,}) {
    return showDialog(
      context: context,
      builder: (_) => EditPaymentMethodsDialog(
         storeId: storeId,
         id: paymentId,
         onSaved: onSaved,
      ),
    );
  }


  static Future<void> showPayableDialog(
      BuildContext context,
      int storeId,

      { int? paymentId, void Function(StorePayable updatedStore)? onSaved,}) {
    return showDialog(
      context: context,
      builder: (_) => EditPayableDialog(
        storeId: storeId,
        id: paymentId,
        onSaved: onSaved,
      ),
    );
  }

  static Future<void> showVariantsDialog(
      BuildContext context,
      int storeId,

      { int? variantId, void Function(Variant updatedStore)? onSaved,}) {
    return showDialog(
      context: context,
      builder: (_) => EditVariantDialog(
        storeId: storeId,
        id: variantId,
        onSaved: onSaved,
      ),
    );
  }

  static Future<void> showVariantsOptionsDialog(
      BuildContext context,
      int storeId,
      int variantId, {
        int? id,
        void Function()? onSaved, // aqui trocou o tipo
      }) {
    return showDialog(
      context: context,
      builder: (_) => EditVariantOptionDialog(
        storeId: storeId,
        id: id,
        variantId: variantId,
        onSaved: onSaved,
      ),
    );
  }




// Adicione mais diálogos aqui conforme necessário
}
