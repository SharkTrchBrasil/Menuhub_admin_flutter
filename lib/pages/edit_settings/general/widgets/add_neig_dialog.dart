import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:totem_pro_admin/core/di.dart';

import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';

import '../../../../core/app_edit_controller.dart';
import '../../../../models/store_neig.dart';
import '../../../../widgets/app_page_status_builder.dart';
import '../../../../widgets/base_dialog.dart';


class AddNeighborhoodDialog extends StatefulWidget {
  const AddNeighborhoodDialog({
    super.key,
    required this.cityId,
    this.id,
    this.onSaved,
  });

  final int cityId;
  final int? id;
  final void Function(StoreNeighborhood)? onSaved;

  @override
  State<AddNeighborhoodDialog> createState() => _AddNeighborhoodDialogState();
}

class _AddNeighborhoodDialogState extends State<AddNeighborhoodDialog> {
  final formKey = GlobalKey<FormState>();
  final repository = getIt<StoreRepository>();

  late final AppEditController<void, StoreNeighborhood> controller =
  AppEditController(
    id: widget.id,
    fetch: (id) => repository.getNeighborhood(widget.cityId, id),
    save: (neighborhood) =>
        repository.saveNeighborhood(widget.cityId, neighborhood),
    empty: () => StoreNeighborhood(
      name: '',
      cityId: widget.cityId,
      deliveryFee: 0,
      isActive: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return AppPageStatusBuilder<StoreNeighborhood>(
          status: controller.status,
          successBuilder: (neighborhood) {
            return BaseDialog(
              title: widget.id == null ? 'Criar bairro' : 'Editar bairro',
              saveText: 'Salvar',
              onSave: () async {
                if (formKey.currentState!.validate()) {
                  final result = await controller.saveData();
                  if (result.isRight && context.mounted) {
                    widget.onSaved?.call(result.right);
                    Navigator.of(context).pop(); // fecha o dialog
                  }
                }
              },
              content: Container(
                padding: const EdgeInsets.all(24),
                width: MediaQuery.of(context).size.width < 600
                    ? MediaQuery.of(context).size.width
                    : 300,
                child: Wrap(
                  spacing: 24,
                  runSpacing: 24,
                children: [

                  Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          initialValue: neighborhood.name,
                          title: 'Nome do bairro',
                          hint: 'Ex: Centro',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Campo obrigatório';
                            } else if (value.length < 3) {
                              return 'Nome muito curto';
                            }
                            return null;
                          },
                          onChanged: (name) {
                            controller.onChanged(
                              neighborhood.copyWith(name: name),
                            );
                          },
                        ),
                        const SizedBox(height: 25),
                        AppTextField(
                          initialValue: UtilBrasilFields.obterReal(
                              neighborhood.deliveryFee / 100),
                          title: 'Taxa de entrega',
                          hint: 'Ex: R\$ 5,00',
                          formatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CentavosInputFormatter(moeda: true),
                          ],
                          onChanged: (value) {
                            final money = UtilBrasilFields
                                .converterMoedaParaDouble(value ?? '');
                            controller.onChanged(
                              neighborhood.copyWith(
                                deliveryFee: (money * 100).floor(),
                              ),
                            );
                          },
                          validator: (value) {
                            if (value == null || value.length < 4) {
                              return 'Campo obrigatório';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),
                        Row(
                          children: [
                            Switch(
                              value: neighborhood.isActive,
                              onChanged: (value) {
                                controller.onChanged(
                                  neighborhood.copyWith(isActive: value),
                                );
                              },
                            ),
                            const SizedBox(width: 20),
                            const Text('Bairro disponível?'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                ),
              ),
            );
          },
        );
      },
    );
  }
}
