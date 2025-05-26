import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:totem_pro_admin/ConstData/typography.dart';

import '../../core/di.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/store_repository.dart';
import '../../widgets/app_toasts.dart';
import '../base/BasePage.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;

  final String password;

  const VerifyCodePage({required this.email, super.key, required this.password,});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {


  TextEditingController textEditingController = TextEditingController();


  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }





  @override
  Widget build(BuildContext context) {
    return BasePage(
      mobileBuilder: (BuildContext context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'Verificação de email',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                          child: RichText(
                            text: TextSpan(
                              text: "Digite o código recebido no seu email ",
                              children: [
                                TextSpan(
                                  text: "${widget.email}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const Spacer(),
                        // empurra o restante pro centro
                        Form(
                          key: formKey,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8.0,
                              horizontal: 30,
                            ),
                            child: PinCodeTextField(
                              appContext: context,
                              pastedTextStyle: TextStyle(
                             //   color: notifire.getBgPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                              length: 6,
                              obscureText: false,
                              obscuringCharacter: '*',
                              blinkWhenObscuring: true,
                              animationType: AnimationType.fade,
                              validator: (v) {
                                if (v!.length < 6) {
                                  return "Digite os 6 números";
                                } else {
                                  return null;
                                }
                              },
                              pinTheme: PinTheme(
                                inactiveColor: Colors.black,
                                inactiveFillColor: Colors.white,
                                inactiveBorderWidth: 1,
                                activeColor: Colors.green,
                                selectedColor: Colors.redAccent,
                                selectedFillColor: Colors.white,
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(5),
                                fieldHeight: 50,
                                fieldWidth: 40,
                                activeFillColor: Colors.white,
                              ),
                              cursorColor: Colors.black,
                              animationDuration: const Duration(milliseconds: 300),
                              enableActiveFill: true,
                              errorAnimationController: errorController,
                              controller: textEditingController,
                              keyboardType: TextInputType.number,
                              boxShadows: const [
                                BoxShadow(
                                  offset: Offset(0, 1),
                                  color: Colors.black12,
                                  blurRadius: 10,
                                )
                              ],
                              onCompleted: (v) {
                                debugPrint("Completed");
                              },
                              onChanged: (value) {
                                debugPrint(value);
                                setState(() {
                                  currentText = value;
                                });
                              },
                              beforeTextPaste: (text) {
                                debugPrint("Allowing to paste $text");
                                return true;
                              },
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Text(
                            hasError ? "*Please fill up all the cells properly" : "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                            //  backgroundColor: notifire.getBgPrimaryColor,
                              fixedSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                final authRepository = getIt<AuthRepository>();
                                final l = showLoading();
                                final code = textEditingController.text;

                                final result = await authRepository.verifyCode(
                                  email: widget.email,
                                  code: code,
                                );
                                l();
                                if (!context.mounted) return;

                                result.fold(
                                      (error) {
                                    switch (error) {
                                      case CodeError.invalidCode:
                                        showError('Código inválido.');
                                        break;
                                      case CodeError.alreadyVerified:
                                        showInfo('Este e-mail já foi verificado.');
                                        break;
                                      case CodeError.userNotFound:
                                        showError('Usuário não encontrado.');
                                        break;
                                      case CodeError.unknown:
                                        showError('Erro desconhecido. Tente novamente.');
                                        break;
                                    }
                                  },
                                      (_) async {
                                    showSuccess('Código verificado com sucesso!');

                                    final loginResult = await authRepository.signIn(
                                      email: widget.email,
                                      password: widget.password,
                                    );

                                    if (!context.mounted) return;

                                    if (loginResult.isRight) {
                                      final getStoresResult = await getIt<StoreRepository>().getStores();
                                      if (!context.mounted) return;

                                      if (getStoresResult.isLeft || getStoresResult.right.isEmpty) {
                                        context.go('/stores/new');
                                      } else {
                                        context.go('/stores');
                                      }
                                    } else {
                                      showError('Erro ao fazer login após verificar código.');
                                    }
                                  },
                                );
                              }
                            },
                            child: const Center(
                              child: Text(
                                "VERIFICAR",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Não recebeu o código ?",
                              style: TextStyle(color: Colors.black54, fontSize: 15),
                            ),
                            TextButton(
                              onPressed: () async {
                                final authRepository = getIt<AuthRepository>();
                                final closeLoading = showLoading(); // mostra carregando
                                final result = await authRepository.sendCode(email: widget.email);
                                closeLoading(); // fecha carregando

                                if (!context.mounted) return;

                                result.fold(
                                      (error) {
                                    String message;

                                    switch (error) {
                                      case ResendError.userNotFound:
                                        message = 'Usuário não encontrado.';
                                        break;
                                      case ResendError.resendError:
                                        message = 'Email já foi verificado.';
                                        break;
                                      case ResendError.unknown:
                                      message = 'Erro desconhecido. Tente novamente.';
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                                  },
                                      (_) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Código reenviado com sucesso!')),
                                    );
                                  },
                                );
                              },
                              child: const Text(
                                "Reenviar",
                                style: TextStyle(
                                  color: Color(0xFF91D3B3),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          ],
                        ),
                        Spacer()
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },




      desktopBuilder: (BuildContext context) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Center( // Centraliza o conteúdo na tela desktop
                      child: SizedBox(
                        width: 400, // Defina a largura desejada para o conteúdo no desktop
                        child: Column(
                          children: [
                            const SizedBox(height: 32),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Verificação de email',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                              child: RichText(
                                text: TextSpan(
                                  text: "Digite o código recebido no seu email ",
                                  children: [
                                    TextSpan(
                                      text: "${widget.email}",
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const Spacer(),
                            // empurra o restante pro centro
                            Form(
                              key: formKey,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 30,
                                ),
                                child: PinCodeTextField(
                                  appContext: context,
                                  pastedTextStyle: TextStyle(
                                  //  color: notifire.getBgPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  length: 6,
                                  obscureText: false,
                                  obscuringCharacter: '*',
                                  blinkWhenObscuring: true,
                                  animationType: AnimationType.fade,
                                  validator: (v) {
                                    if (v!.length < 6) {
                                      return "Digite os 6 números";
                                    } else {
                                      return null;
                                    }
                                  },
                                  pinTheme: PinTheme(
                                    inactiveColor: Colors.black,
                                    inactiveFillColor: Colors.white,
                                    inactiveBorderWidth: 1,
                                    activeColor: Colors.green,
                                    selectedColor: Colors.redAccent,
                                    selectedFillColor: Colors.white,
                                    shape: PinCodeFieldShape.box,
                                    borderRadius: BorderRadius.circular(5),
                                    fieldHeight: 50,
                                    fieldWidth: 40,
                                    activeFillColor: Colors.white,
                                  ),
                                  cursorColor: Colors.black,
                                  animationDuration: const Duration(milliseconds: 300),
                                  enableActiveFill: true,
                                  errorAnimationController: errorController,
                                  controller: textEditingController,
                                  keyboardType: TextInputType.number,
                                  boxShadows: const [
                                    BoxShadow(
                                      offset: Offset(0, 1),
                                      color: Colors.black12,
                                      blurRadius: 10,
                                    )
                                  ],
                                  onCompleted: (v) {
                                    debugPrint("Completed");
                                  },
                                  onChanged: (value) {
                                    debugPrint(value);
                                    setState(() {
                                      currentText = value;
                                    });
                                  },
                                  beforeTextPaste: (text) {
                                    debugPrint("Allowing to paste $text");
                                    return true;
                                  },
                                ),
                              ),
                            ),
                            const Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 30.0),
                              child: Text(
                                hasError ? "*Please fill up all the cells properly" : "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                               //   backgroundColor: notifire.getBgPrimaryColor,
                                  fixedSize: const Size.fromHeight(52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    final authRepository = getIt<AuthRepository>();
                                    final l = showLoading();
                                    final code = textEditingController.text;

                                    final result = await authRepository.verifyCode(
                                      email: widget.email,
                                      code: code,
                                    );
                                    l();
                                    if (!context.mounted) return;

                                    result.fold(
                                          (error) {
                                        switch (error) {
                                          case CodeError.invalidCode:
                                            showError('Código inválido.');
                                            break;
                                          case CodeError.alreadyVerified:
                                            showInfo('Este e-mail já foi verificado.');
                                            break;
                                          case CodeError.userNotFound:
                                            showError('Usuário não encontrado.');
                                            break;
                                          case CodeError.unknown:
                                            showError('Erro desconhecido. Tente novamente.');
                                            break;
                                        }
                                      },
                                          (_) async {
                                        showSuccess('Código verificado com sucesso!');

                                        final loginResult = await authRepository.signIn(
                                          email: widget.email,
                                          password: widget.password,
                                        );

                                        if (!context.mounted) return;

                                        if (loginResult.isRight) {
                                          final getStoresResult = await getIt<StoreRepository>().getStores();
                                          if (!context.mounted) return;

                                          if (getStoresResult.isLeft || getStoresResult.right.isEmpty) {
                                            context.go('/stores/new');
                                          } else {
                                            context.go('/stores');
                                          }
                                        } else {
                                          showError('Erro ao fazer login após verificar código.');
                                        }
                                      },
                                    );
                                  }
                                },
                                child: const Center(
                                  child: Text(
                                    "VERIFICAR",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Não recebeu o código ?",
                                  style: TextStyle(color: Colors.black54, fontSize: 15),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    final authRepository = getIt<AuthRepository>();
                                    final closeLoading = showLoading(); // mostra carregando
                                    final result = await authRepository.sendCode(email: widget.email);
                                    closeLoading(); // fecha carregando

                                    if (!context.mounted) return;

                                    result.fold(
                                          (error) {
                                        String message;

                                        switch (error) {
                                          case ResendError.userNotFound:
                                            message = 'Usuário não encontrado.';
                                            break;
                                          case ResendError.resendError:
                                            message = 'Email já foi verificado.';
                                            break;
                                          case ResendError.unknown:
                                            message = 'Erro desconhecido. Tente novamente.';
                                        }

                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
                                      },
                                          (_) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Código reenviado com sucesso!')),
                                        );
                                      },
                                    );
                                  },
                                  child: const Text(
                                    "Reenviar",
                                    style: TextStyle(
                                      color: Color(0xFF91D3B3),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const Spacer()
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },



    );



  }
}






//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Verificar Código')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _codeController,
//                 decoration: InputDecoration(labelText: 'Código de Verificação'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Por favor, insira o código.';
//                   }
//                   return null;
//                 },
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     final authRepository = getIt<AuthRepository>();
//                     final l = showLoading();
//                     final code = _codeController.text;
//
//                     // Verifica o código antes de tentar login
//                     final result = await authRepository.verifyCode(email: widget.email, code: code);
//                     l();
//                     if (!context.mounted) return;
//
//                     result.fold(
//                           (error) {
//                         switch (error) {
//                           case CodeError.invalidCode:
//                             showError('Código inválido.'.tr());
//                             break;
//                           case CodeError.alreadyVerified:
//                             showInfo('Este e-mail já foi verificado.'.tr());
//                             break;
//                           case CodeError.userNotFound:
//                             showError('Usuário não encontrado.'.tr());
//                             break;
//                           case CodeError.unknown:
//                             showError('Erro desconhecido. Tente novamente.'.tr());
//                             break;
//                         }
//                       },
//                           (_) async {
//                         showSuccess('Código verificado com sucesso!');
//
//                         // Faz login automaticamente
//                         final loginResult = await authRepository.signIn(
//                           email: widget.email,
//                           password: widget.password,
//                         );
//
//                         if (!context.mounted) return;
//
//                         if (loginResult.isRight) {
//                           final getStoresResult = await getIt<StoreRepository>().getStores();
//
//                           if (!context.mounted) return;
//
//                           if (getStoresResult.isLeft || getStoresResult.right.isEmpty) {
//                             context.go('/stores/new');
//                           } else {
//                             context.go('/stores');
//                           }
//                         } else {
//                           showError('Erro ao fazer login após verificar código.'.tr());
//                         }
//                       },
//                     );
//                   }
//
//                 },
//                 child: Text('Verificar Código'),
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
