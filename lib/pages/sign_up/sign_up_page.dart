import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../../core/di.dart';
import '../../core/enums/auth_erros.dart';
import '../../cubits/auth_state.dart';
import '../../repositories/auth_repository.dart';
import '../../services/auth_service.dart';
import '../../cubits/auth_cubit.dart';

import '../../widgets/app_text_field.dart';
import '../../widgets/app_toasts.dart';
import '../../widgets/ds_primary_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.redirectTo});

  final String? redirectTo;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String password = '';
  String phone = '';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ Importante para o teclado empurrar o conteúdo

      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSignUpError) {
              _handleSignUpError(state.error);
            }
          },
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final isDesktop = constraints.maxWidth > 800;
              final form = _buildFormSection();

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 720, // tanto desktop quanto mobile
                    ),
                    child: form,
                  ),
                ),
              );

            },
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Flexible(

              child: DsButton(

                style: DsButtonStyle.secondary,
                onPressed: () {
                  context.go('/sign-in${widget.redirectTo != null ? '?redirectTo=${widget.redirectTo!}' : ''}');
                },
                label: ' Voltar',
              ),
            ),
            SizedBox(width: 16,),
            Flexible(
              child: DsButton(


                onPressed: () async {
                  if (formKey.currentState!.validate()) {


                    await context.read<AuthCubit>().signUp(
                      name: name,
                      phone: phone,
                      email: email,
                      password: password,
                    );


                  }
                },

                label:
                  'Continuar',


              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildFormSection() {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Container(
    //  margin: EdgeInsets.all(58),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[100]!), // ✅ Borda cinza
        borderRadius: BorderRadius.circular(16), // ✅ Radius de 8
      ),


      child: Padding(
       padding:  EdgeInsets.all(isMobile ? 8 : 22.0),
        child: Center(
          child: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              child: Padding(
                padding:  EdgeInsets.all(isMobile ? 8 : 18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Estamos felizes em ter você por aqui!',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 30,
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Precisamos de algumas informações para começar o cadastro do seu restaurante.',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.black87,

                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            title: 'Nome completo*',
                            hint: 'enter_your_full_name'.tr(),
                            validator: (s) {
                              if (s == null || s.isEmpty) {
                                return 'name_required'.tr();
                              } else if (s.trim().split(' ').length < 2) {
                                return 'enter_valid_full_name'.tr();
                              }
                              return null;
                            },
                            onChanged: (s) => name = s ?? '',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    AppTextField(
                      title: 'Celular*',
                      hint: 'enter_your_phone'.tr(),
                      validator: (s) {
                        if (s == null || s.trim().isEmpty) {
                          return 'Campo obrigatório';
                        }

                        try {
                          // Tenta parsear o número de telefone
                          final phone = PhoneNumber.parse(
                            s,
                            destinationCountry: IsoCode.BR,
                          );

                          // Valida se é um número de celular
                          final isValidMobile = phone.isValid(
                            type: PhoneNumberType.mobile,
                          );

                          if (!isValidMobile) {
                            return 'Número de celular inválido';
                          }

                          return null; // ✅ Válido
                        } catch (e) {
                          return 'Número inválido';
                        }
                      },
                      onChanged: (s) {
                        if (s != null && s.trim().isNotEmpty) {
                          try {
                            final parsedPhone = PhoneNumber.parse(
                              s,
                              destinationCountry: IsoCode.BR,
                            );

                            if (parsedPhone.isValid(
                              type: PhoneNumberType.mobile,
                            )) {
                              phone =
                                  parsedPhone
                                      .international; // ✅ "+55 31 99999-8888"
                            } else {
                              phone =
                                  phoneMask.getUnmaskedText(); // fallback bruto
                            }
                          } catch (e) {
                            phone = phoneMask.getUnmaskedText(); // fallback bruto
                          }
                        }
                      },

                      formatters: [phoneMask], // Aplica a máscara
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      title: 'Email',
                      hint: 'enter_your_email'.tr(),
                      validator: (s) {
                        if (s == null || !EmailValidator.validate(s)) {
                          return 'invalid_email'.tr();
                        }
                        return null;
                      },
                      onChanged: (s) => email = s ?? '',
                    ),

                    const SizedBox(height: 20),

                    AppTextField(
                      title: 'password'.tr(),
                      hint: 'enter_your_password'.tr(),
                      isHidden: true,
                      validator: (s) {
                        if (s == null || s.isEmpty) {
                          return 'field_required'.tr();
                        } else if (s.length < 8) {
                          return 'password_too_short'.tr();
                        }
                        return null;
                      },
                      onChanged: (s) => password = s ?? '',
                    ),


                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool isChecked = false;

  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####', // Máscara para números internacionais
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );



  void _handleSignUpError(SignUpError error) {
    switch (error) {
      case SignUpError.userAlreadyExists:
        showError('Este e-mail já está cadastrado.');
        break;
      case SignUpError.invalidData:
        showError('Dados inválidos. Verifique os campos preenchidos.');
        break;
      case SignUpError.weakPassword:
        showError('A senha escolhida é muito fraca. Tente uma mais segura.');
        break;
      case SignUpError.networkError:
        showError('Sem conexão com a internet. Verifique sua conexão.');
        break;
      case SignUpError.emailNotSent:
        showError('Falha ao enviar o e-mail de verificação. Tente novamente.');
        break;
      case SignUpError.unknown:
      default:
        showError('Erro inesperado ao criar a conta. Tente novamente.');
    }
  }
}






