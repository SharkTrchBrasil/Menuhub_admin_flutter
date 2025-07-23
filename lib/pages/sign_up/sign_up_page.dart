import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../core/di.dart';
import '../../repositories/auth_repository.dart';
import '../../services/auth_service.dart';
import '../../services/cubits/auth_cubit.dart';
import '../../services/cubits/auth_state.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toasts.dart';

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
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {

          if (state is AuthSignUpError) {
            // Chama o método para exibir o erro com base na mensagem do AuthError
            _handleSignUpError(state.error);
          }





        },
        child: Stack(
          children: [
            if (!isMobile) _buildBackground(),
            Center(
              child: Container(
                margin: const EdgeInsets.all(30),
                constraints: const BoxConstraints(maxWidth: 1000),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,

                  border: Border.all(color: Color(0xFFE67E22), width: 1),
                ),
                child:
                    isMobile
                        ? _buildFormSection()
                        : Row(
                          children: [
                            Expanded(child: _buildVisualSection()),
                            Expanded(child: _buildFormSection()),
                          ],
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF39C12),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.bolt,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'PDVix',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Criar nova conta',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (!isMobile)
                const Text(
                  'Preencha os dados abaixo para começar',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),

              const SizedBox(height: 50),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      title: 'Seu nome',
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

              const SizedBox(height: 24),

              AppTextField(
                title: 'Seu melhor email',
                hint: 'enter_your_email'.tr(),
                validator: (s) {
                  if (s == null || !EmailValidator.validate(s)) {
                    return 'invalid_email'.tr();
                  }
                  return null;
                },
                onChanged: (s) => email = s ?? '',
              ),

              const SizedBox(height: 24),

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

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFFF39C12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final loading = showLoading();

                      await context.read<AuthCubit>().signUp(
                        name: name,
                        email: email,
                        password: password,
                      );

                      loading();
                    }
                  },

                  label: const Text(
                    'Criar conta',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isMobile)
                    Flexible(
                      child: const Text(
                        'Já tem uma conta? ',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  InkWell(
                    onTap: () {
                      context.go(
                        '/sign-in${widget.redirectTo != null ? '?redirectTo=${widget.redirectTo!}' : ''}',
                      );
                    },
                    child: const Text(
                      'Faça login aqui',
                      style: TextStyle(
                        color: Color(0xFFF39C12),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisualSection() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          bottomLeft: Radius.circular(22),
        ),

        gradient: const LinearGradient(
          colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white24,
            child: FaIcon(
              FontAwesomeIcons.store,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Cadastro de Lojista',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Cadastre seu restaurante e aumente suas vendas',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildFeature('Plataforma completa de gestão'),
          _buildFeature('Comissões competitivas'),
          _buildFeature('Marketing digital incluído'),
          _buildFeature('Relatórios detalhados'),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  bool isChecked = false;

  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####', // Máscara para números internacionais
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        // gradient: LinearGradient(
        //   colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
      ),
    );
  }

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

