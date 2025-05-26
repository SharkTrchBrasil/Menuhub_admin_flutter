import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/app_edit_controller.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/pages/base/BasePage.dart';
import 'package:totem_pro_admin/repositories/product_repository.dart';
import 'package:totem_pro_admin/widgets/app_page_header.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_secondary_button.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';

import '../../widgets/app_switch_form_field.dart';
import '../../widgets/fixed_header.dart';

// ... imports existentes ...

class EditVariantOptionPage extends StatefulWidget {
  const EditVariantOptionPage({
    super.key,
    required this.storeId,
    required this.variantId,
    this.id,
  });

  final int storeId;
  final int variantId;
  final int? id;

  @override
  State<EditVariantOptionPage> createState() => _EditVariantOptionPageState();
}

class _EditVariantOptionPageState extends State<EditVariantOptionPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ProductRepository repository = getIt();

  late final AppEditController<void, VariantOption> controller = AppEditController(
    id: widget.id,
    fetch: (id) => repository.getVariantOption(widget.storeId, widget.variantId, id),
    save: (option) => repository.saveVariantOption(widget.storeId, widget.variantId, option),
    empty: () => VariantOption(),
  );

  // Removida a função save() original que fazia context.go
  // A lógica de salvamento será no onPressed do botão e fará Navigator.pop

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return AppPageStatusBuilder<VariantOption>(
          status: controller.status,
          successBuilder: (option) {
            return Dialog( // Use Dialog para encapsular o conteúdo da página
              child: ConstrainedBox( // Opcional: Para controlar o tamanho do dialog
                constraints: BoxConstraints(maxWidth: 900, maxHeight: MediaQuery.of(context).size.height * 0.8),
                child: Form(
                  key: formKey,
                  child: BasePage( // BasePage ainda pode ser útil para MobileAppBar e desktop/mobile builders
                    mobileAppBar: AppBarCustom(
                      title: widget.id == null ? 'Nova Opção' : 'Editar Opção',
                    ),
                    // Adapte os builders para o layout do dialog
                    mobileBuilder: (BuildContext context) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: _buildOptionForm(option), // Crie um método auxiliar para o formulário
                      );
                    },
                    desktopBuilder: (BuildContext context) {
                      return Column(
                        children: [
                          FixedHeader(
                            title: widget.id == null ? 'Nova Opção' : 'Editar Opção',
                            actions: [
                              AppPrimaryButton(
                                label: 'Salvar',
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    final result = await controller.saveData();
                                    if (result.isRight && mounted) {
                                      Navigator.of(context).pop(true); // Indica sucesso e fecha o dialog
                                    }
                                  }
                                },
                              ),
                            ],

                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: _buildOptionForm(option),
                            ),
                          ),
                        ],
                      );
                    },
                    mobileBottomNavigationBar: AppPrimaryButton(
                      label: 'Salvar',
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          final result = await controller.saveData();
                          if (result.isRight && mounted) {
                            Navigator.of(context).pop(true); // Indica sucesso e fecha o dialog
                          }
                        }
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Método auxiliar para construir o formulário da opção
  Widget _buildOptionForm(VariantOption option) {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        SizedBox(
          width: 200,
          child: AppTextField(
            initialValue: option.name,
            title: 'Título da opção',
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
              controller.onChanged(
                option.copyWith(name: name),
              );
            },
          ),
        ),
        SizedBox(
          width: 400,
          child: AppTextField(
            initialValue: option.description,
            title: 'Descrição da opção',
            hint: 'Ex: Muito bom',
            validator: (title) {
              if (title == null || title.isEmpty) {
                return 'Campo obrigatório';
              } else if (title.length < 10) {
                return 'Descrição muito curta';
              }
              return null;
            },
            onChanged: (desc) {
              controller.onChanged(
                option.copyWith(description: desc),
              );
            },
          ),
        ),
        SizedBox(
          width: 200,
          child: AppTextField(
            initialValue:
            option.price != null
                ? UtilBrasilFields.obterReal(
              option.price! / 100,
            )
                : '',
            title: 'Preço',
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
                option.copyWith(
                  price: (money * 100).floor(),
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
        ),
        // Adicione um AppSwitchFormField para o status 'available' aqui
        SizedBox(
          width: 200, // ou um tamanho adequado
          child: AppSwitchFormField(
            title: 'Disponível',
            initialValue: option.available,
            onChanged: (value) {
              controller.onChanged(
                option.copyWith(available: value),
              );
            },
            // Você pode adicionar um validator aqui se necessário
            validator: (value) => null,
          ),
        ),
      ],
    );
  }
}