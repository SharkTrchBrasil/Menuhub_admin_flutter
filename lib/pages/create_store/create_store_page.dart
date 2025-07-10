import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

import '../../cubits/store_manager_cubit.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_text_field.dart';

class CreateStorePage extends StatefulWidget {
  const CreateStorePage({super.key});

  @override
  State<CreateStorePage> createState() => _CreateStorePageState();
}

class _CreateStorePageState extends State<CreateStorePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final StoreRepository storeRepository = getIt();

  String name = '';
  String phone = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                autovalidateMode: AutovalidateMode.onUnfocus,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppLogo(size: 50),
                    const SizedBox(height: 32),
                    Text(
                      'Vamos criar juntos a sua loja!',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      title: 'Nome da Loja',
                      hint: 'Digite o nome da sua loja',
                      validator: (s) {
                        if (s == null || s.isEmpty) {
                          return 'Campo obrigatório';
                        } else if(s.length < 5) {
                          return 'Nome muito curto';
                        }
                        return null;
                      },
                      onChanged: (s) => name = s ?? '',
                    ),

                    AppTextField(
                      title: 'Whatsapp',
                      hint: 'enter_your_phone'.tr(),
                      validator: (s) {
                        if (s == null || s.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }

                        try {
                          // Tenta parsear o número de telefone
                          final phone = PhoneNumber.parse(s, destinationCountry: IsoCode.BR);

                          // Valida se é um número de celular
                          final isValidMobile = phone.isValid(type: PhoneNumberType.mobile);

                          if (!isValidMobile) {
                            return 'Número de celular inválido';
                          }

                          return null; // ✅ Válido
                        } catch (e) {
                          return 'Número inválido';
                        }
                      },
                      onChanged: (s) {
                        final raw = phoneMask.getUnmaskedText(); // Ex: 33991210220
                        phone = '$raw'; // Resultado final: +5533991210220
                      },
                      formatters: [phoneMask], // Aplica a máscara
                    ),
                    const SizedBox(height: 48),
                    AppPrimaryButton(
                      label: 'Criar loja',
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final l = showLoading();
                            final result = await storeRepository.createStore(name, phone);
                            l();

                            if (result.isLeft) {
                              showError('Não foi possível criar a loja. Por favor, tente novamente.');
                            } else {
                              showSuccess('Loja criada com sucesso!');

                              final store = result.right;

                              // ✅ Adiciona a loja ao StoresManagerCubit e conecta o socket
                              final storesManagerCubit = context.read<StoresManagerCubit>();
                              storesManagerCubit.addStore(store); // <-- você vai precisar criar este método

                              if (context.mounted) {
                                context.go('/stores/${store.store.id}/orders');
                              }
                            }
                          }
                        }

                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!context.isSmallScreen)
            Expanded(flex: 3, child: Container(color: Colors.blue)),
        ],
      ),
    );
  }

  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####', // Máscara para números internacionais
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
}
