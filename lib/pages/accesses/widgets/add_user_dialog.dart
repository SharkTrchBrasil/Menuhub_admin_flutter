import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_drop_down_form_field.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_secondary_button.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

import '../../../repositories/store_repository.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key, required this.storeId});

  final int storeId;

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String email = '';
  StoreAccessRole? role;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Container(
        width: 350,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Adicionar Usuário',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Informe o e-mail do usuário para conceder acesso a esta loja.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                title: 'E-mail',
                hint: 'Digite o e-mail do usuário',
                onChanged: (v) {
                  email = v ?? '';
                },
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Campo obrigatório';
                  } else if(!EmailValidator.validate(v)) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AppDropDownFormField(
                  title: 'Função',
                  onChanged: (v) {
                    role = v;
                  },
                  items: StoreAccessRole.values
                      .where((v) => v.selectable)
                      .map(
                        (r) => DropdownMenuItem(
                      value: r,
                      child: Text(r.title),
                    ),
                  )
                      .toList(),
                  validator: (v) {
                    if (v == null) {
                      return 'Campo obrigatório';
                    }
                    return null;
                  }
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppSecondaryButton(
                    label: 'Cancelar',
                    onPressed: context.pop,
                  ),
                  const SizedBox(width: 16),
                  AppPrimaryButton(
                    label: 'Salvar',
                    onPressed: () async {
                      if(formKey.currentState!.validate()) {
                        final l = showLoading();
                        final result = await getIt<StoreRepository>()
                            .createStoreAccess(widget.storeId, email, role!);

                        l();
                        if (result.isRight) {
                          showSuccess('Usuário vinculado com sucesso!');
                          if (context.mounted) context.pop(true);
                        } else {
                          showError('Falha ao adicionar usuário!');
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
