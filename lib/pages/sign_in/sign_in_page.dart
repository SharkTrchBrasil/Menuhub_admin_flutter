import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';

import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';

import 'package:totem_pro_admin/widgets/app_primary_button.dart';

import 'package:totem_pro_admin/widgets/app_text_field.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

import '../../constdata/typography.dart';

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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: size.height,
            width: size.width,
            child: Stack(
              clipBehavior: Clip.none,
              children: [

                LayoutBuilder(
                  builder: (context, constraints) {
                    Widget loginWidget = LoginContainer(
                      formKey: _formKey,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      redirectTo: widget.redirectTo,
                    );

                    if (constraints.maxWidth < 600) {
                      return Column(
                        children: [
                          Expanded(
                            child: Center(child: loginWidget),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          const Spacer(),
                          Row(
                            children: [
                              const Spacer(),
                              Expanded(
                                flex: constraints.maxWidth < 1000 ? 3 : 1,
                                child: Center(child: loginWidget),
                              ),
                              const Spacer(),
                            ],
                          ),
                          const Spacer(),
                        ],
                      );
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LoginContainer extends StatelessWidget {
  const LoginContainer({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController, required this.redirectTo,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? redirectTo;

  @override
  Widget build(BuildContext context) {


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUnfocus,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Login',
                style: TextStyle(
                  fontSize: 25,
                 // color: notifire.textcolore,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              AppTextField(
                controller: emailController,
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
                controller: passwordController,
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
              InkWell(
                onTap: () {},
                child: Text(
                  'Esqueceu a senha?',
                 // style: TextStyle(color: notifire.textcolore),
                ),
              ),
              const SizedBox(height: 30),
              AppPrimaryButton(
                label: "sign_in".tr(),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final authRepository = getIt<AuthRepository>();
                    final loading = showLoading();

                    final result = await authRepository.signIn(
                      email: emailController.text,
                      password: passwordController.text,
                    );

                    loading();

                    if (!context.mounted) return;

                    if (result.isLeft) {
                      switch (result.left) {
                        case SignInError.invalidCredentials:
                          showError('Credenciais inválidas');
                          break;
                        case SignInError.unknown:
                          showError('Erro inesperado. Tente novamente.');
                          break;
                        case SignInError.inactiveAccount:
                          showError('Conta inativa.');
                          break;
                        case SignInError.emailNotVerified:
                          showInfo('Verifique seu e-mail.');
                          context.go('/verify-code', extra: {
                            'email': emailController.text,
                            'password': passwordController.text,
                          });
                          break;
                      }
                    } else {
                      final storesResult =
                      await getIt<StoreRepository>().getStores();

                      if (!context.mounted) return;

                      if (storesResult.isLeft) {
                        showError('Erro ao buscar suas lojas.');
                        return;
                      }

                      final stores = storesResult.right;
                      context.go(stores.isEmpty ? '/stores/new' : '/stores');
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey.withOpacity(0.4)),
                  ),


                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      context.go('/sign-up${redirectTo != null ? '?redirectTo=${redirectTo}' : ''}');
                    },
                    child: Text(
                      'Ainda não tenho conta',
                      // style: TextStyle(color: notifire.textcolore),
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
}

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final String icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(icon, height: 20, width: 20),
            const SizedBox(width: 10),
            Text(label, style: TextStyle()),
          ],
        ),
      ),
    );
  }
}
