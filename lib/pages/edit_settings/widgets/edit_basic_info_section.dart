

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/app_edit_controller.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';



class EditBasicInfoSection extends StatefulWidget {
  const EditBasicInfoSection({super.key, required this.storeId});

  final int storeId;

  @override
  State<EditBasicInfoSection> createState() => _EditBasicInfoSectionState();
}

class _EditBasicInfoSectionState extends State<EditBasicInfoSection> {
  final StoreRepository storeRepository = getIt();

  final formKey = GlobalKey<FormState>();

  late final AppEditController<void, Store> controller = AppEditController<void, Store>(
    id: widget.storeId,
    fetch: (id) => storeRepository.getStore(id),
    save: (store) => storeRepository.updateStore(widget.storeId,store),
    empty: () => Store(),
  );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informações básicas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) {
              return AppPageStatusBuilder<Store>(
                status: controller.status,
                successBuilder: (store) {


                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 350,
                                child: AppTextField(
                                  initialValue: store.name,
                                  title: 'Nome da loja',
                                  hint: 'Informe o nome da loja',
                                  onChanged: (v) {
                                    controller.onChanged(store.copyWith(name: v));
                                  },
                                  validator: (v) {
                                    if(v == null || v.isEmpty) {
                                      return 'Campo obrigatório';
                                    } else if(v.length < 3) {
                                      return 'Mínimo de 3 caracteres';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              AppPrimaryButton(
                                label: 'Salvar',
                                onPressed: () async {
                                  if(formKey.currentState!.validate()) {
                                    await controller.saveData();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );


                },
              );
            },
          ),

        ],
      ),
    );
  }
}
