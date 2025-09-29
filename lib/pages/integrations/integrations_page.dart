import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/app_edit_controller.dart';
import 'package:totem_pro_admin/core/di.dart';

import 'package:totem_pro_admin/pages/base/BasePage.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_file_form_field.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';

import '../../models/store/store_pix_config.dart';

class EditPaymentInfoSection extends StatefulWidget {
  const EditPaymentInfoSection({super.key, required this.storeId});

  final int storeId;

  @override
  State<EditPaymentInfoSection> createState() => _EditPaymentInfoSectionState();
}

class _EditPaymentInfoSectionState extends State<EditPaymentInfoSection> {
  final StoreRepository storeRepository = getIt();

  final formKey = GlobalKey<FormState>();

  late final AppEditController<void, StorePixConfig> controller =
      AppEditController<void, StorePixConfig>(
        id: widget.storeId,
        fetch: (id) => storeRepository.getStorePixConfig(id),
        save:
            (pixConfig) =>
                storeRepository.updateStorePixConfig(widget.storeId, pixConfig),
        empty: () => const StorePixConfig(),
      );

  @override
  Widget build(BuildContext context) {
    return

      Form(
      key: formKey,
      child: BasePage(
        mobileAppBar: AppBarCustom(title: 'Integrações'),

        mobileBuilder: (BuildContext context) {
          return AnimatedBuilder(
            animation: controller,
            builder: (_, __) {
              return AppPageStatusBuilder<StorePixConfig>(
                status: controller.status,
                successBuilder: (pixConfig) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(



                          children: [
                            AppTextField(
                              initialValue: pixConfig.pixKey,
                              title: 'Chave PIX',
                              enabled: !pixConfig.isActive,
                              hint: 'CPF, CNPJ, E-mail, Telefone ou Aleatória',
                              onChanged: (v) {
                                controller.onChanged(pixConfig.copyWith(pixKey: v));
                              },
                            ),
                            const SizedBox(height: 16),
                            if (pixConfig.isActive) ...[
                              const Text(
                                '✔️ Configuração ativa!',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              AppPrimaryButton(
                                label: 'Alterar configuração',
                                onPressed: () {
                                  controller.onChanged(pixConfig.copyWith());
                                },
                              ),
                            ] else ...[
                              AppTextField(
                                title: 'ID Banco Efí',
                                onChanged: (v) {
                                  controller.onChanged(
                                    pixConfig.copyWith(clientId: v),
                                  );
                                },
                                hint: 'Client ID',
                              ),
                              const SizedBox(height: 16),
                              AppTextField(
                                title: 'Chave Banco Efí',
                                hint: 'Client secret',
                                isHidden: true,
                                onChanged: (v) {
                                  controller.onChanged(
                                    pixConfig.copyWith(clientSecret: v),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              AppFileFormField(
                                title: 'Certificado Efí (.pem)',
                                onChanged: (v) {
                                  controller.onChanged(
                                    pixConfig.copyWith(certificate: v?.file),
                                  );
                                },
                              ),


                            ],

                            const SizedBox(height: 26),


                            if(!pixConfig.isActive) ... [
                              const SizedBox(height: 24),
                              AppPrimaryButton(
                                label: 'Salvar',
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    await controller.saveData();
                                  }
                                },
                              ),
                            ]



                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        desktopBuilder: (BuildContext context) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              FixedHeader(title: 'Integrações'),

              AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  return AppPageStatusBuilder<StorePixConfig>(
                    status: controller.status,
                    successBuilder: (pixConfig) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 600),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 400,
                                  child: AppTextField(
                                    initialValue: pixConfig.pixKey,
                                    title: 'Chave PIX',
                                    enabled: !pixConfig.isActive,
                                    hint:
                                        'CPF, CNPJ, E-mail, Telefone ou Aleatória',
                                    onChanged: (v) {
                                      controller.onChanged(
                                        pixConfig.copyWith(pixKey: v),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 16),
                                if (pixConfig.isActive) ...[
                                  const Text(
                                    '✔️ Configuração ativa!',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  AppPrimaryButton(
                                    label: 'Alterar configuração',
                                    onPressed: () {
                                      controller.onChanged(
                                        pixConfig.copyWith(),
                                      );
                                    },
                                  ),
                                ] else ...[
                                  SizedBox(
                                    width: 500,
                                    child: AppTextField(
                                      title: 'ID Banco Efí',
                                      onChanged: (v) {
                                        controller.onChanged(
                                          pixConfig.copyWith(clientId: v),
                                        );
                                      },
                                      hint: 'Client ID',
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: 500,
                                    child: AppTextField(
                                      title: 'Chave Banco Efí',
                                      hint: 'Client secret',
                                      isHidden: true,
                                      onChanged: (v) {
                                        controller.onChanged(
                                          pixConfig.copyWith(clientSecret: v),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: 400,
                                    child: AppFileFormField(
                                      title: 'Certificado Efí (.pem)',
                                      onChanged: (v) {
                                        controller.onChanged(
                                          pixConfig.copyWith(
                                            certificate: v?.file,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                                if (!pixConfig.isActive) ...[
                                  const SizedBox(height: 24),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,

                                    children: [
                                      AppPrimaryButton(
                                        label: 'Salvar',
                                        onPressed: () async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            await controller.saveData();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
