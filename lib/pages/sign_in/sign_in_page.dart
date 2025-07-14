import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:email_validator/email_validator.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../core/di.dart';
import '../../cubits/store_manager_cubit.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/store_repository.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_primary_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toasts.dart';
import '../splash/splash_page_cubit.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.redirectTo});
  final String? redirectTo;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'csatrabalho1@gmail.com');
  final _passwordController = TextEditingController(text: '12345678');

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      body: Stack(
        children: [
          if (!isMobile) _buildBackground(),
          Center(
            child: Container(
              margin: const EdgeInsets.all(30),
              constraints: const BoxConstraints(maxWidth: 1000),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFFE67E22),
                  width: 1,
                ),
              ),
              child: isMobile
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
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
    );
  }

  Widget _buildVisualSection() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
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
            child: const FaIcon(FontAwesomeIcons.store, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            'Área do Lojista',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Gerencie seu restaurante e aumente suas vendas',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          _buildFeature('Dashboard completo de vendas'),
          _buildFeature('Gestão de cardápio e preços'),
          _buildFeature('Relatórios detalhados'),
          _buildFeature('Suporte especializado'),
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
          )
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Form(
        key: _formKey,
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
                    child: const FaIcon(FontAwesomeIcons.bolt, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'PDVix',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Bem-vindo de volta!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Faça login para continuar',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 50),
              AppTextField(
                controller: _emailController,
                title: 'email'.tr(),
                hint: 'enter_your_email'.tr(),
                validator: (s) {
                  if (s == null || !EmailValidator.validate(s)) {
                    return 'invalid_email'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              AppTextField(
                controller: _passwordController,
                title: 'password'.tr(),
                hint: 'enter_your_password'.tr(),
                isHidden: true,
                validator: (s) {
                  if (s == null || s.isEmpty) {
                    return 'field_required'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go('/forgot-password'),
                  child: const Text('Esqueceu a senha?'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppPrimaryButton(
                  onPressed: _handleSignIn,
                  label: 'Entrar',

                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isMobile)
                    const Flexible(
                      child: Text(
                        'Não tem uma conta? ',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  InkWell(
                    onTap: () => context.go(
                      '/sign-up${widget.redirectTo != null ? '?redirectTo=${widget.redirectTo}' : ''}',
                    ),
                    child: const Text(
                      'Cadastre-se aqui',
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
  // Future<void> _handleSignIn() async {
  //   if (!_formKey.currentState!.validate()) return;
  //
  //   final loading = showLoading();
  //   final authService = getIt<AuthService>();
  //   final result = await authService.signIn(
  //     email: _emailController.text,
  //     password: _passwordController.text,
  //   );
  //   loading();
  //
  //   if (!mounted) return;
  //
  //   result.fold(
  //         (error) => _handleSignInError(error),
  //         (_) async {
  //       // 🔥 Agora chamando a inicialização do StoresManagerCubit
  //       final storesManager = getIt<StoresManagerCubit>();
  //       await storesManager.initialize();
  //
  //       if (!mounted) return;
  //
  //       final storesResult = await getIt<StoreRepository>().getStores();
  //       storesResult.fold(
  //             (_) => showError('Erro ao carregar lojas'),
  //             (stores) {
  //           if (stores.isNotEmpty) {
  //             context.go(widget.redirectTo ?? '/stores/${stores.first.store.id}/orders');
  //           } else {
  //             context.go('/stores/new');
  //           }
  //         },
  //       );
  //     },
  //   );
  // }


  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    final loading = showLoading();
    final authService = getIt<AuthService>();
    final result = await authService.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
    loading();

    if (!mounted) return;

    result.fold(
          (error) => _handleSignInError(error),
          (_) async {
        // Login bem-sucedido!

        // 1. **Primeiro, busque as lojas e popule o StoreRepository.**
        // A instância do StoreRepository é um singleton, então ela manterá os dados.
        final storeRepository = getIt<StoreRepository>();
        final storesResult = await storeRepository
            .getStores(); // Esta chamada deve popular o _stores interno do StoreRepository

        if (!mounted) return;

        storesResult.fold(
              (_) => showError('Erro ao carregar lojas'),
              (stores) async { // Agora 'stores' está populado.


                // 2. Inicialize o StoresManagerCubit APÓS carregar as lojas no StoreRepository
                final storesManagerCubit = getIt<StoresManagerCubit>();
            //    await storesManagerCubit.initialize();



            if (stores.isNotEmpty) {
              context.go(widget.redirectTo ??
                  '/stores/${stores.first.store.id}/orders');
            } else {
              context.go('/stores/new');
            }
          },
        );
      },
    );
  }

  void _handleSignInError(SignInError error) {
    switch (error) {
      case SignInError.invalidCredentials:
        showError('Credenciais inválidas');
        break;
      case SignInError.inactiveAccount:
        showError('Conta inativa. Entre em contato com o suporte.');
        break;
      case SignInError.emailNotVerified:
        showInfo('Verifique seu e-mail para ativar sua conta.');
        context.go('/verify-code', extra: {
          'email': _emailController.text,
          'password': _passwordController.text,
        });
        break;
      case SignInError.noStoresAvailable:
        context.go('/stores/new');
        break;
      case SignInError.networkError:
        showError('Sem conexão com a internet. Verifique sua conexão.');
        break;
      case SignInError.serverError:
        showError('Problema no servidor. Tente novamente mais tarde.');
        break;
      default:
        showError('Erro inesperado. Tente novamente.');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}