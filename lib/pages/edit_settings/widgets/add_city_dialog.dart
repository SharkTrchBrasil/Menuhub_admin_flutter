import 'package:brasil_fields/brasil_fields.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/store_city.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';

import 'package:totem_pro_admin/widgets/app_text_field.dart';


import '../../../core/app_edit_controller.dart';
import '../../../repositories/store_repository.dart';
import '../../../widgets/app_page_status_builder.dart';
import '../../../widgets/base_dialog.dart';

class AddCityDialog extends StatefulWidget {
  const AddCityDialog({
    super.key,
    required this.storeId,
    this.id,
    this.onSaved,
  });

  final int storeId;
  final int? id;
  final void Function(StoreCity)? onSaved;

  @override
  State<AddCityDialog> createState() => _AddCityDialogState();
}

class _AddCityDialogState extends State<AddCityDialog> {
  final formKey = GlobalKey<FormState>();
  final repository = getIt<StoreRepository>();

  late final AppEditController<void, StoreCity> controller = AppEditController(
    id: widget.id,
    fetch: (id) => repository.getCity(widget.storeId, id),
    save: (category) => repository.saveCity(widget.storeId, category),
    empty: () => StoreCity(name: ''),
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return AppPageStatusBuilder<StoreCity>(
          status: controller.status,
          successBuilder: (category) {
            return BaseDialog(
              content: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    // height: 200,
                    width:
                        MediaQuery.of(context).size.width < 600
                            ? MediaQuery.of(context).size.width
                            : 300,
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 25),



                              AppTextField(
                                initialValue: category.name,
                                title: 'Nome',
                                hint: 'Minha cidade',
                                validator: (title) {
                                  if (title == null || title.isEmpty) {
                                    return 'Campo obrigatório';
                                  } else if (title.length < 3) {
                                    return 'Título muito curto';
                                  }
                                  return null;
                                },
                                onChanged: (name) {
                                  controller.onChanged(
                                    category.copyWith(name: name),
                                  );
                                },
                              ),
                              const SizedBox(height: 25),

                              AppTextField(
                                initialValue:
                                     UtilBrasilFields.obterReal(
                                          category.deliveryFee / 100,
                                        ),

                                title: 'Valor da taxa',
                                hint: 'Ex: R\$ 5,00',
                                formatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  CentavosInputFormatter(moeda: true),
                                ],
                                onChanged: (value) {
                                  final money =
                                      UtilBrasilFields.converterMoedaParaDouble(
                                        value ?? '',
                                      );

                                  controller.onChanged(
                                    category.copyWith(
                                      deliveryFee: (money * 100).floor(),
                                    ),
                                  );
                                },
                                validator: (value) {
                                  if (value == null || value.length < 7) {
                                    return 'Campo obrigatório';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 25),
                              Row(
                                children: [
                                  Switch(
                                    value: category.isActive,
                                    onChanged: (name) {
                                      controller.onChanged(
                                        category.copyWith(isActive: name),
                                      );
                                    },
                                  ),
                                  
                                  SizedBox(width: 20,),
                                  Text('Cidade disponivel?')
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: widget.id == null ? 'Criar cidade' : 'Editar cidade',
              onSave: () async {
                if (formKey.currentState!.validate()) {
                  final result = await controller.saveData();
                  if (result.isRight && context.mounted) {
                    widget.onSaved?.call(result.right);
                    Navigator.of(context).pop(); // fecha o dialog
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
}
