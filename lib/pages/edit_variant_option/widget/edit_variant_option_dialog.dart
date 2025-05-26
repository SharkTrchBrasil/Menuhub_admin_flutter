import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/app_edit_controller.dart';
import 'package:totem_pro_admin/core/di.dart';

import 'package:totem_pro_admin/models/variant_option.dart';

import 'package:totem_pro_admin/repositories/product_repository.dart';

import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';

import 'package:totem_pro_admin/widgets/app_text_field.dart';

import '../../../widgets/app_counter_form_field.dart';
import '../../../widgets/app_switch_form_field.dart';
import '../../../widgets/base_dialog.dart';

class EditVariantOptionDialog extends StatefulWidget {
  const EditVariantOptionDialog({
    super.key,
    required this.storeId,
    required this.variantId,
    this.id,
    this.onSaved,
  });

  final int storeId;
  final int variantId;
  final void Function()? onSaved;

  final int? id;

  @override
  State<EditVariantOptionDialog> createState() =>
      _EditVariantOptionDialogState();
}

class _EditVariantOptionDialogState extends State<EditVariantOptionDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ProductRepository repository = getIt();

  late final AppEditController<void, VariantOption> controller =
      AppEditController(
        id: widget.id,
        fetch:
            (id) => repository.getVariantOption(
              widget.storeId,
              widget.variantId,
              id,
            ),
        save:
            (option) => repository.saveVariantOption(
              widget.storeId,
              widget.variantId,
              option,
            ),
        empty: () => VariantOption(),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return AppPageStatusBuilder<VariantOption>(
          status: controller.status,
          successBuilder: (option) {
            return BaseDialog(
              content: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                ),
                child: Form(key: formKey, child: _buildOptionForm(option)),
              ),
              title: '',
              onSave: () async {
                if (formKey.currentState!.validate()) {
                  final result = await controller.saveData();
                  if (result.isRight && context.mounted) {
                    widget.onSaved?.call();
                    context.pop();
                  }
                }
              },
              saveText: 'Salvar',
            );
          },
        );
      },
    );
  }

  Widget _buildOptionForm(VariantOption option) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AppTextField(
                initialValue: option.name,
                title: 'Nome',
                hint: 'Ex: Morango',
                validator: (title) {
                  if (title == null || title.isEmpty) {
                    return 'Campo obrigatório';
                  } else if (title.length < 3) {
                    return 'Título muito curto';
                  }
                  return null;
                },
                onChanged: (name) {
                  controller.onChanged(option.copyWith(name: name));
                },
              ),
            ),
            SizedBox(width: 25),

            Expanded(
              child: AppCounterFormField(
                initialValue: option.maxQuantity,
                minValue: 1,
                maxValue: 100,
                title: 'Escolha máxima',
                validator: (quantity) => null,
                onChanged: (quantity) {
                  controller.onChanged(option.copyWith(maxQuantity: quantity));
                },
              ),
            ),
          ],
        ),

        AppTextField(
          initialValue: option.description,
          title: 'Descrição',
          hint: 'Ex: Muito bom',
          onChanged: (desc) {
            controller.onChanged(option.copyWith(description: desc));
          },
        ),

        AppSwitchFormField(
          initialValue: option.isFree,
          title: 'Este adicional é gratuito?',
          onChanged: (value) {
            final isFree = value == true;

            controller.onChanged(
              option.copyWith(
                isFree: isFree,

                price: isFree ? 0 : (option.price ?? 0),
                discountPrice: isFree ? 0 : (option.discountPrice ?? 0),
              ),
            );
          },
        ),

        if (!option.isFree)
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  initialValue:
                      option.price != null
                          ? UtilBrasilFields.obterReal(option.price / 100)
                          : '',
                  title: 'Preço',
                  hint: 'Ex: R\$ 5,00',
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CentavosInputFormatter(moeda: true),
                  ],
                  onChanged: (value) {
                    final money = UtilBrasilFields.converterMoedaParaDouble(
                      value ?? '',
                    );
                    controller.onChanged(
                      option.copyWith(price: (money * 100).floor()),
                    );
                  },
                  validator: (value) {
                    final money = UtilBrasilFields.converterMoedaParaDouble(
                      value ?? '',
                    );

                    if (value == null || value.isEmpty) {
                      return 'Campo obrigatório';
                    }

                    if (money < 0) {
                      return 'Valor inválido';
                    }

                    return null;
                  },
                ),
              ),
              SizedBox(width: 25),
              Expanded(
                child: AppTextField(
                  initialValue:
                      option.discountPrice != null
                          ? UtilBrasilFields.obterReal(
                            option.discountPrice! / 100,
                          )
                          : '',
                  title: 'Preço com desconto (opcional)',
                  hint: 'Ex: R\$ 5,00',
                  formatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CentavosInputFormatter(moeda: true),
                  ],
                  onChanged: (value) {
                    final money = UtilBrasilFields.converterMoedaParaDouble(
                      value ?? '',
                    );
                    controller.onChanged(
                      option.copyWith(discountPrice: (money * 100).floor()),
                    );
                  },
                ),
              ),
            ],
          ),

        AppSwitchFormField(
          initialValue: option.available,
          title: 'Opção disponível?',
          onChanged: (value) {
            controller.onChanged(option.copyWith(available: value));
          },
        ),
      ],
    );
  }
}
