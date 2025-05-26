
import 'package:flutter/material.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:totem_pro_admin/models/user.dart';

import 'package:totem_pro_admin/repositories/user_repository.dart';


import '../../../ConstData/typography.dart';

import '../../../core/app_user_controller.dart';
import '../../../core/di.dart';
import '../../../widgets/app_page_status_builder.dart';

import '../../../widgets/app_text_field.dart';

class EditUserInfo extends StatefulWidget {
  const EditUserInfo({super.key, required this.storeId});

  final int storeId;

  @override
  State<EditUserInfo> createState() => _EditUserInfoState();
}

class _EditUserInfoState extends State<EditUserInfo> {
  User? currentUser;
  final UserRepository userRepository = getIt();

  // Ajuste no seu controlador para usuário
  late final AppUserController<void, User> userController =
      AppUserController<void, User>(
        fetch: () => userRepository.getUserInfo(),
        // Método que busca o usuário logado
        save:
            (user) => userRepository.updateUser(
              user,
            ), // Método que atualiza o usuário
      );
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: AnimatedBuilder(
        animation: userController,
        builder: (_, __) {
          return AppPageStatusBuilder<User>(
            status: userController.status,
            tryAgain: userController.initialize, // Recarregar os dados
            successBuilder: (user) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      width: 600,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                      //  border: Border.all(color: notifire.getGry700_300Color),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Meus dados",
                              style: Typographyy.heading4.copyWith(
                               // color: notifire.getTextColor,
                              ),
                            ),

                            AppTextField(
                              initialValue: user.name,
                              title: 'Nome completo',
                              hint: 'Cristiano silva',
                              onChanged: (v) {
                                userController.onChanged(user.copyWith(name: v));
                              },
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Campo obrigatório';
                                } else if (v.length < 3) {
                                  return 'Mínimo de 3 caracteres';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 25),
                            AppTextField(
                                readOnly: true,
                              initialValue: user.email,
                              title: 'Email',
                              hint: 'sualoja@example.com',
                              onChanged: (v) {
                            //    userController.onChanged(user.copyWith(email: v));
                              },
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Campo obrigatório';
                                } else if (v.length < 3) {
                                  return 'Mínimo de 3 caracteres';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 25),
                            AppTextField(
                              title: 'Contato',
                              hint: '0123456789',
                              validator: (s) {
                                if (s == null || s.trim().isEmpty)
                                  return 'Campo obrigatório';
                                try {
                                  final phone = PhoneNumber.parse(
                                    s,
                                    destinationCountry: IsoCode.BR,
                                  );
                                  if (!phone.isValid(
                                    type: PhoneNumberType.mobile,
                                  )) {
                                    return 'Número de celular inválido';
                                  }
                                  return null;
                                } catch (e) {
                                  return 'Número inválido';
                                }
                              },
                              onChanged: (s) {
                              //  userController.onChanged(user.copyWith(phone: s));
                              },
                              formatters: [phoneMask],
                            ),

                            const SizedBox(height: 25),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                   //   backgroundColor: notifire.getBgPrimaryColor,
                                      elevation: 0,
                                      fixedSize: const Size.fromHeight(42),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () async {
                                      if (formKey.currentState!.validate()) {
                                        await userController.saveData();
                                      }
                                    },

                                    child: Text(
                                      "Atualizar dados",
                                      style: Typographyy.bodyMediumMedium
                                          .copyWith(color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####', // Máscara para números internacionais
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );




}
