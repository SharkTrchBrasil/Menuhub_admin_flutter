// ignore_for_file: deprecated_member_use, depend_on_referenced_packages

import 'package:brasil_fields/brasil_fields.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';
import 'package:totem_pro_admin/models/payment_method.dart';

import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/pages/base/BasePage.dart';
import 'package:totem_pro_admin/repositories/payment_method_repository.dart';

import '../../../UI TEMP/controller/invoicecreatcontroller.dart';

import '../../../core/app_edit_controller.dart';
import '../../../core/di.dart';
import '../../../models/category.dart';

import '../../../repositories/category_repository.dart';
import '../../../repositories/product_repository.dart';

import '../../../services/dialog_service.dart';
import '../../../widgets/app_image_form_field.dart';
import '../../../widgets/app_page_header.dart';
import '../../../widgets/app_page_status_builder.dart';
import '../../../widgets/app_selection_form_field.dart';
import '../../../widgets/app_table.dart';
import '../../../widgets/app_text_field.dart';
import '../../../widgets/app_text_field_2.dart';
import '../../../widgets/base_dialog.dart';
import '../../../widgets/drawercode.dart';

class EditPaymentMethodsDialog extends StatefulWidget {
  const EditPaymentMethodsDialog({
    super.key,
    required this.storeId,
    this.id,
    this.onSaved,
  });

  final int storeId;

  final int? id;
  final void Function(StorePaymentMethod)? onSaved;

  @override
  State<EditPaymentMethodsDialog> createState() =>
      _EditPaymentMethodsDialogState();
}

class _EditPaymentMethodsDialogState extends State<EditPaymentMethodsDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final StorePaymentMethodRepository repository = getIt();

  late final AppEditController<void, StorePaymentMethod> controller =
      AppEditController(
        id: widget.id,
        fetch: (id) => repository.getPaymentMethod(widget.storeId, id),
        save:
            (product) => repository.savePaymentMethod(widget.storeId, product),
        empty: () => StorePaymentMethod(paymentType: '', customName: ''),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return AppPageStatusBuilder<StorePaymentMethod>(
          status: controller.status,
          successBuilder: (product) {
            return Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,

              child: BaseDialog(
                content: SizedBox(
                  width:
                      MediaQuery.of(context).size.width < 600
                          ? MediaQuery.of(context).size.width
                          : MediaQuery.of(context).size.width * 0.25,
                  height: 400,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: BasePage(
                      mobileBuilder: (BuildContext context) {
                        return SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Wrap(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 20),
                                          contentApp(product)
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),


                            ],
                          ),
                        );
                      },
                      desktopBuilder: (BuildContext context) {
                        return Column(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [

                                      contentApp(product)

                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                title: '',
                onSave: () async {
                  if (formKey.currentState!.validate()) {
                    final result = await controller.saveData();

                    if (result.isRight && context.mounted) {
                      widget.onSaved?.call(result.right);
                      context.pop(); // fecha o dialog
                    }
                  }
                },
                saveText: 'Salvar',
              ),
            );
          },
        );
      },
    );
  }

  Widget contentApp (StorePaymentMethod product){

    return Column(
      children: [
        // titulo


        Row(
          children: [

            Flexible(
              flex: 3,
              child: AppTextField(
                initialValue: product.customName,
                title: 'Nome',
                hint: 'Dinheiro',
                validator: (title) {
                  if (title == null ||
                      title.isEmpty) {
                    return 'Campo obrigatório';
                  } else if (title.length < 3) {
                    return 'Título muito curto';
                  }
                  return null;
                },
                onChanged: (name) {
                  controller.onChanged(
                    product.copyWith(
                      customName: name,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 20),

            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: DropdownButton<String>(
                  value: product.paymentType.isNotEmpty ? product.paymentType : null,

                  isDense: true, // deixa mais compacto
                  items: const [
                    DropdownMenuItem(
                      value: 'Card',
                      child: Row(
                        children: [Icon(Icons.credit_card), SizedBox(width: 8), Text('Cartão')],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Pix',
                      child: Row(
                        children: [Icon(Icons.qr_code), SizedBox(width: 8), Text('Pix')],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Other',
                      child: Row(
                        children: [Icon(Icons.currency_bitcoin), SizedBox(width: 8), Text('Outro')],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.onChanged(
                        product.copyWith(
                          paymentType: value,
                          customIcon: _getDefaultAssetName(value),
                        ),
                      );
                    }
                  },


                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        if (product.paymentType.toLowerCase() == 'pix')
          AppTextField(
            initialValue: product.pixKey,
            title: 'Chave Pix',
            hint: 'Email, celular, CNPJ, CPF',
            validator: (value) {
              if (value == null || value.isEmpty) return 'Campo obrigatório';
              return null;
            },
            onChanged: (value) {
              controller.onChanged(product.copyWith(pixKey: value));
            },
          ),






        const SizedBox(height: 20),

        if (product.paymentType.toLowerCase() == 'card')
          AppTextField2(
            initialValue: product.taxRate.toString(),
            title: 'Taxa',
            hint: 'Ex: 3,99%',
            suffixText: '%',
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            formatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+[,\.]?\d{0,2}')),
            ],
            onChanged: (value) {
              final parsedValue = double.tryParse(value!.replaceAll(',', '.')) ?? 0.0;
              controller.onChanged(product.copyWith(taxRate: parsedValue));
            },
          ),





        Row(
          children: [
            Flexible(
              child: Text(
                'Delivery',
                style: TextStyle(
                  //     color:
                  //      notifire
                  //        .textcolore,
                ),
                overflow:
                TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 5),
            Switch(
              value: product.activeOnDelivery,

              onChanged: (bool value) {
                controller.onChanged(
                  product.copyWith(
                    activeOnDelivery: value,
                  ),
                );
              },
            ),
          ],
        ),

        Row(
          children: [
            Flexible(
              child: Text(
                'Retirada',
                style: TextStyle(
                  //     color:
                  //      notifire
                  //        .textcolore,
                ),
                overflow:
                TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 5),
            Switch(
              value: product.activeOnPickup,

              onChanged: (bool value) {
                controller.onChanged(
                  product.copyWith(
                    activeOnPickup: value,
                  ),
                );
              },
            ),
          ],
        ),

        Row(
          children: [
            Flexible(
              child: Text(
                'No local (Tipo balcão)',
                style: TextStyle(
                  //     color:
                  //      notifire
                  //        .textcolore,
                ),
                overflow:
                TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 5),
            Switch(
              value: product.activeOnCounter,

              onChanged: (bool value) {
                controller.onChanged(
                  product.copyWith(
                    activeOnCounter: value,
                  ),
                );
              },
            ),
          ],
        ),


        const SizedBox(height: 40),
        Row(
          children: [
            Flexible(child: Text('Forma de pagamento ativo')),
            Switch(
              value: product.isActive,
              onChanged: (value) {
                controller.onChanged(product.copyWith(isActive: value));
              },
            ),
          ],
        ),

      ],
    );
  }
  String _getDefaultAssetName(String type) {
    switch (type.toLowerCase()) {
      case 'card':
        return 'card.svg';
      case 'pix':
        return 'pix.svg';
      case 'other':
        return 'other.svg';
      default:
        return 'money.svg';
    }
  }

  IconData _getPaymentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return Icons.attach_money;
      case 'card':
        return Icons.credit_card;
      case 'pix':
        return Icons.qr_code;
      case 'other':
        return Icons.payment;
      default:
        return Icons.money;
    }
  }

}
