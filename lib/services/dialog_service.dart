

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/models/store_payable.dart';
import 'package:totem_pro_admin/models/variant.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/pages/coupons/widgets/edit_coupon_page_dialog.dart';

import '../models/category.dart';
import '../pages/banners/widgets/banner_form_dialog.dart';



import '../pages/edit_settings/general/widgets/add_city_dialog.dart';
import '../pages/edit_settings/general/widgets/add_neig_dialog.dart';
import '../pages/payables/widgets/edit_payable_dialog.dart';


class DialogService {







  static Future<void> showBannerDialog(
      BuildContext context,
      int storeId, {
        int? bannerId,
        void Function(dynamic banner)? onSaved,
      }) {
    return showDialog(
      context: context,
      builder: (_) => EditBannerForm(
        storeId: storeId,
        id: bannerId,
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



  static Future<void> showCityDialog(
      BuildContext context, {
        required int storeId,
        int? cityId,
        void Function(dynamic)? onSaved,
      }) {
    return showDialog(
      context: context,
      builder: (_) => AddCityDialog(
        storeId: storeId,
        id: cityId,
        onSaved: onSaved,
      ),
    );
  }

  static Future<void> showNeighborhoodDialog(
      BuildContext context, {
        required int cityId,
        int? neighborhoodId,
        void Function(dynamic)? onSaved,
      }) {
    return showDialog(
      context: context,
      builder: (_) => AddNeighborhoodDialog(
        cityId: cityId,
        id: neighborhoodId,
        onSaved: onSaved,
      ),
    );
  }


  /// Exibe um diálogo de confirmação genérico.
  /// Retorna `true` se o usuário confirmar (pressionar 'Sim'), `false` caso contrário.
  static Future<bool?> showConfirmationDialog(
      BuildContext context, {
        required String title,
        required String content,
        String confirmButtonText = 'Sim', // Texto padrão para o botão de confirmação
        String cancelButtonText = 'Cancelar', // Texto padrão para o botão de cancelamento
      }) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title.tr()), // Usa .tr() para internacionalização
          content: Text(content.tr()), // Usa .tr() para internacionalização
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Retorna false ao cancelar
              },
              child: Text(cancelButtonText.tr()),
            ),
            FilledButton( // Usar FilledButton para a ação primária (confirmação)
              onPressed: () {
                Navigator.of(context).pop(true); // Retorna true ao confirmar
              },
              child: Text(confirmButtonText.tr()),
            ),
          ],
        );
      },
    );
  }


// Adicione mais diálogos aqui conforme necessário
}
