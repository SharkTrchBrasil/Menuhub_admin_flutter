import 'package:brasil_fields/brasil_fields.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';

import 'package:totem_pro_admin/models/address.dart';
import 'package:totem_pro_admin/models/billing_customer.dart';
import 'package:totem_pro_admin/models/credit_card.dart';
import 'package:totem_pro_admin/models/new_subscription.dart';
import 'package:totem_pro_admin/models/page_status.dart';
import 'package:totem_pro_admin/models/subscription_plan.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

class NewSubscriptionDialog extends StatefulWidget {
  const NewSubscriptionDialog(
      {super.key, required this.plan, required this.storeId});

  final int storeId;
  final SubscriptionPlan plan;

  @override
  State<NewSubscriptionDialog> createState() => _NewSubscriptionDialogState();
}

class _NewSubscriptionDialogState extends State<NewSubscriptionDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  PageStatus zipCodeStatus = PageStatusIdle();
  BillingCustomer billingCustomer = BillingCustomer();
  CreditCard creditCard = CreditCard();

  final StoreRepository storeRepository = getIt();

  Future<void> searchZipCode(String zipcode) async {
    setState(() {
      zipCodeStatus = PageStatusLoading();
    });

    final result = await storeRepository.getZipcodeAddress(zipcode);

    setState(() {
      zipCodeStatus = result.fold(
            (l) => PageStatusError('CEP não encontrado'),
            (r) => PageStatusSuccess(r),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUnfocus,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.plan.isPaid
                              ? '${widget.plan.name}: ${widget.plan.price.toPrice()}/${widget.plan.interval == 1 ? 'mês' : '${widget.plan.interval} meses'}'
                              : '${widget.plan.name}: Grátis',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const CloseButton(),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'ATENÇÃO: Seu plano atual será cancelado',
                  ),
                  const SizedBox(height: 24),
                  if (widget.plan.isPaid) ...[
                    const Text(
                      'Endereço de cobrança',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      title: 'CEP',
                      hint: 'Ex: 12345-678',
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CepInputFormatter(),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Campo obrigatório';
                        } else if (v.length < 10) {
                          return 'CEP inválido';
                        }
                        return null;
                      },
                      onChanged: (c) {
                        if (c!.length == 10) {
                          searchZipCode(c);
                        } else {
                          setState(() {
                            zipCodeStatus = PageStatusIdle();
                          });
                        }
                      },
                    ),
                    AppPageStatusBuilder<Address>(
                      status: zipCodeStatus,
                      successBuilder: (address) {
                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    initialValue: address.state,
                                    title: 'Estado',
                                    hint: 'Ex: SP',
                                    enabled: false,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Campo obrigatório';
                                      }
                                      return null;
                                    },
                                    onChanged: (c) {},
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: AppTextField(
                                    initialValue: address.city,
                                    title: 'Cidade',
                                    hint: 'Ex: São Paulo',
                                    enabled: false,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Campo obrigatório';
                                      }
                                      return null;
                                    },
                                    onChanged: (c) {},
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              initialValue: address.street,
                              title: 'Endereço',
                              hint: 'Ex: Rua ABC',
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Campo obrigatório';
                                }
                                return null;
                              },
                              onChanged: (c) {
                                setState(() {
                                  zipCodeStatus = PageStatusSuccess(
                                    address.copyWith(street: c),
                                  );
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              initialValue: address.neighborhood,
                              title: 'Bairro',
                              hint: 'Ex: Brooklin',
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Campo obrigatório';
                                }
                                return null;
                              },
                              onChanged: (c) {
                                setState(() {
                                  zipCodeStatus = PageStatusSuccess(
                                    address.copyWith(neighborhood: c),
                                  );
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: AppTextField(
                                    title: 'Número',
                                    hint: 'Ex: 123',
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Campo obrigatório';
                                      }
                                      return null;
                                    },
                                    onChanged: (c) {
                                      setState(() {
                                        zipCodeStatus = PageStatusSuccess(
                                          address.copyWith(number: c),
                                        );
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: AppTextField(
                                    title: 'Complemento',
                                    hint: 'Ex: Apto 101',
                                    onChanged: (c) {
                                      setState(() {
                                        zipCodeStatus = PageStatusSuccess(
                                          address.copyWith(complement: c),
                                        );
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Dados do proprietário do cartão',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      initialValue: billingCustomer.name,
                      title: 'Nome completo',
                      hint: '',
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Campo obrigatório';
                        } else if (v.split(' ').length < 2) {
                          return 'Informe o nome completo';
                        }
                        return null;
                      },
                      onChanged: (c) {
                        billingCustomer = billingCustomer.copyWith(name: c);
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      initialValue: billingCustomer.cpf,
                      title: 'CPF',
                      hint: 'Ex: 123.456.789-09',
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CpfInputFormatter(),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Campo obrigatório';
                        } else if (v.length < 14) {
                          return 'CPF inválido';
                        }
                        return null;
                      },
                      onChanged: (c) {
                        billingCustomer = billingCustomer.copyWith(cpf: c);
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      initialValue: billingCustomer.email,
                      title: 'E-mail',
                      hint: 'Ex: email@email.com',
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Campo obrigatório';
                        } else if (!EmailValidator.validate(v)) {
                          return 'E-mail inválido';
                        }
                        return null;
                      },
                      onChanged: (c) {
                        billingCustomer = billingCustomer.copyWith(email: c);
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      title: 'Data de nascimento',
                      hint: 'Ex: 01/01/2000',
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        DataInputFormatter(),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Campo obrigatório';
                        }
                        final date = DateFormat('dd/MM/yyyy').tryParse(v);
                        if (date == null ||
                            date.isAfter(DateTime.now().subtract(Duration(days: 365 * 18))) ||
                            date.isBefore(DateTime(1900))) {
                          return 'Data inválida ou menor de 18 anos';
                        }
                        return null;
                      },
                      onChanged: (c) {
                        billingCustomer = billingCustomer.copyWith(
                            birthday: DateFormat('dd/MM/yyyy').tryParse(c!));
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      initialValue: billingCustomer.phone,
                      title: 'Celular',
                      hint: 'Ex: (11) 91234-5678',
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TelefoneInputFormatter(),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Campo obrigatório';
                        } else if (v.length < 15) {
                          return 'Celular inválido';
                        }
                        return null;
                      },
                      onChanged: (c) {
                        billingCustomer = billingCustomer.copyWith(phone: c);
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Dados do cartão de crédito',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      initialValue: creditCard.number,
                      title: 'Número do cartão',
                      hint: 'Ex: 1234 5678 9012 3456',
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Campo obrigatório';
                        } else if (v.length < 19) {
                          return 'Número inválido';
                        }
                        return null;
                      },
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CartaoBancarioInputFormatter(),
                      ],
                      onChanged: (c) {
                        creditCard = creditCard.copyWith(number: c);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            hint: 'MM/YY',
                            title: 'Vencimento',
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              ValidadeCartaoInputFormatter()
                            ],
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Campo obrigatório';
                              }
                              final date = DateFormat('MM/yy').tryParse(v);
                              if (date == null) {
                                return 'Data inválida';
                              }
                              return null;
                            },
                            onChanged: (c) {
                              creditCard = creditCard.copyWith(
                                  expirationDate:
                                  DateFormat('MM/yy').tryParse(c!));
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            initialValue: creditCard.cvv,
                            title: 'CVV',
                            hint: 'Ex: 123',
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Campo obrigatório';
                              } else if (v.length != 3) {
                                return 'CVV inválido';
                              }
                              return null;
                            },
                            formatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (c) {
                              creditCard = creditCard.copyWith(cvv: c);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AppPrimaryButton(
                      label: 'Assinar',
                      onPressed: () async {
                        if (formKey.currentState!.validate() &&
                            (zipCodeStatus is PageStatusSuccess || !widget.plan.isPaid)) {
                          final l = showLoading();

                          final tokenizeResult = await storeRepository.generateCardToken(creditCard);

                          if (tokenizeResult.isLeft) {
                            showError(
                                'Erro ao processar o cartão. Verifique os dados e tente novamente.');
                            l();
                            return;
                          }

                          final tokenizedCard = tokenizeResult.right;

                          final newSubscription = NewSubscription(
                            plan: widget.plan,
                            customer: billingCustomer,
                            card: tokenizedCard,
                            address: (zipCodeStatus as PageStatusSuccess<Address>)
                                .data,
                          );

                          final result = await storeRepository.createSubscription(
                              widget.storeId, newSubscription);

                          if (result.isLeft) {
                            showError(
                                'Erro ao processar a assinatura. Tente novamente mais tarde.');
                            l();
                            return;
                          }

                          showSuccess('Assinatura realizada com sucesso');
                          if (context.mounted) {
                            context.pop();
                          }
                          l();
                        } else {
                          showError('Algum campo necessita de atenção');
                        }
                      },
                    ),
                  ] else ... [
                    AppPrimaryButton(
                      label: 'Voltar ao plano gratuito',
                      onPressed: () async {
                        final l = showLoading();

                        final newSubscription = NewSubscription(
                          plan: widget.plan,
                        );

                        final result = await storeRepository.createSubscription(
                            widget.storeId, newSubscription);

                        if (result.isLeft) {
                          showError(
                              'Erro ao processar a assinatura. Tente novamente mais tarde.');
                          l();
                          return;
                        }

                        showSuccess('Assinatura realizada com sucesso');
                        if (context.mounted) {
                          context.pop();
                        }
                        l();
                      },
                    ),
                  ]

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
