import 'package:bot_toast/bot_toast.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:go_router/go_router.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/widgets/app_logo.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_text_button.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

import '../../ConstData/typography.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.redirectTo});

  final String? redirectTo;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String name = 'Cristiano Silva';
  String email = 'csatrabalho1@gmail.com';
  String password = '12345678';
  String phone = '33991210220';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
       // color: notifire.getBgColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Scaffold(
              //  backgroundColor: notifire.getBgColor,

                body: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildSingupUi(
                                  width: constraints.maxWidth,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            } else if (constraints.maxWidth < 980) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildSingupUi(
                                width: constraints.maxWidth,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildui()),
                            Expanded(
                              child: _buildSingupUi(
                                width: constraints.maxWidth,
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
          },
        ),
      ),
    );
  }

  Widget _buildui() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
           //   color: notifire.getBgPrimaryColor,
              height: 935,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Speady, Easy and Fast",
                      style: Typographyy.heading2.copyWith(
                      //  color: containerColor,
                      ),
                    ),
                    Text(
                      'Overpay help you set saving goals, earn cash back offers, Go to disclaimer for more details and get paychecks up to two days early. Get a \$20 bonus when you receive qualifying direct deposits'
                          ,
                      style: Typographyy.bodyMediumMedium.copyWith(
                      //  color: containerColor.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Flexible(child: SizedBox(height: 140)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    "assets/images/finallogotext.svg",
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  SvgPicture.asset(
                    "assets/images/finallogo.svg",
                    height: 20,
                    width: 30,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              left: 0,
              bottom: 300,
              child: Container(
                margin: const EdgeInsets.all(12),
                child: Image.asset(
                  "assets/images/hero-1-img 2.png",
                  height: 500,
                  width: 500,
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: Container(
                margin: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  "assets/images/Group.svg",
                  height: 142,
                  width: 26,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                margin: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  "assets/images/Vector.svg",
                  height: 81,
                  width: 81,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool isChecked = false;

  Widget _buildSingupUi({required double width}) {
    return Container(
   //   color: notifire.getBgColor,
      height: width < 600 ? 820 : 945,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(
            overscroll: false,
            scrollbars: false,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        width < 600
                            ? 0
                            : width < 1200
                            ? 30
                            : 100,
                  ),
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUnfocus,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical:
                                width < 600
                                    ? 0
                                    : width < 1200
                                    ? 15
                                    : 24.0,
                          ),
                          child: const AppLogo(size: 50),
                        ),
                        SizedBox(height: width < 600 ? 40 : 48),
                        Text(
                          'sign_up_for_account'.tr(),
                          style: Typographyy.heading3.copyWith(
                          //  color: notifire.getTextColor,
                          ),
                        ),
                        SizedBox(height: width < 600 ? 10 : 16),
                        Text(
                          'sign_up_send_spend_and_save_smarter_pdvix'.tr(),
                          style: Typographyy.bodyLargeRegular.copyWith(
                           // color: notifire.getGry500_600Color,
                          ),
                        ),

                        const SizedBox(height: 24),

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

                        const SizedBox(height: 24),

                        RichText(
                          textAlign: TextAlign.start,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'by_creating_account_you_agree'.tr(),
                                style: Typographyy.bodyMediumMedium.copyWith(
                               //   color: notifire.getGry500_600Color,
                                ),
                              ),
                              TextSpan(
                                text: ' ${'privacy_policy'.tr()}, ',
                                style: Typographyy.bodyMediumSemiBold.copyWith(
                            //     color: notifire.getWhitAndBlack,
                                ),
                              ),
                              TextSpan(
                                text: '${'and'.tr()} ',
                                style: Typographyy.bodyMediumMedium.copyWith(
                                //  color: notifire.getGry500_600Color,
                                ),
                              ),
                              TextSpan(
                                text: 'electronic_communication_policy'.tr(),
                                style: Typographyy.bodyMediumSemiBold.copyWith(
                                //  color: notifire.getWhitAndBlack,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        AppPrimaryButton(
                          label: 'sign_up'.tr(),
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final AuthRepository authRepository = getIt();
                              final l = showLoading();



                              final result = await authRepository.signUp(
                                name: name,
                                email: email,
                                password: password,

                              );

                              l();


                              if (result.isLeft) {
                                switch (result.left) {
                                  case SignUpError.userAlreadyExists:
                                    showError('user_already_exists'.tr());
                                    break;
                                  case SignUpError.unknown:
                                    showError('failed_to_create_account'.tr());
                                    break;
                                }
                                return;
                              }





                              if (result.isRight) {
                                // Após cadastro, vai direto para a verificação
                                context.go('/verify-code', extra: {
                                  'email': email,
                                  'password': password, // armazene só na memória!
                                });
                              } else {
                                showError('Erro ao criar conta.');
                              }










                            }
                          },
                        ),

                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'already_have_account'.tr(),
                              style: Typographyy.bodyLargeMedium.copyWith(
                              //  color: notifire.getWhitAndBlack,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                context.go(
                                  '/sign-in${widget.redirectTo != null ? '?redirectTo=${widget.redirectTo!}' : ''}',
                                );
                              },
                              child: Text(
                                ' ${'sign_in'.tr()}',
                                style: Typographyy.bodyLargeExtraBold.copyWith(
                                 // color: notifire.getWhitAndBlack,
                                ),
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),
                ),
              //  SizedBox(height: width < 600 ? 0 : 80),
              ],
            ),
          ),
        ),
      ),
      // color: Colors.deepPurple,
    );
  }

  final phoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####', // Máscara para números internacionais
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
}





