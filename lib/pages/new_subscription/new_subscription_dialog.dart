import 'package:brasil_fields/brasil_fields.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';

// ✅ Imports dos modelos corretos
import 'package:totem_pro_admin/models/address.dart';
import 'package:totem_pro_admin/models/billing_customer.dart';
import 'package:totem_pro_admin/models/credit_card.dart';
import 'package:totem_pro_admin/models/create_subscription_payload.dart';
import 'package:totem_pro_admin/models/plans.dart';
import 'package:totem_pro_admin/models/tokenized_card.dart';

import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

import '../../models/page_status.dart';

class NewSubscriptionDialog extends StatefulWidget {
  const NewSubscriptionDialog({
    super.key,
    required this.plan,
    required this.storeId,
  });

  final int storeId;
  final Plans plan;

  @override
  State<NewSubscriptionDialog> createState() => _NewSubscriptionDialogState();
}

class _NewSubscriptionDialogState extends State<NewSubscriptionDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Variáveis para guardar os dados do formulário
  Address _address =  Address(street: '', number: '', neighborhood: '', city: '', state: '', zipcode: '');
  BillingCustomer _billingCustomer =  BillingCustomer();
  CreditCard _creditCard = CreditCard();

  PageStatus _zipCodeStatus = PageStatusIdle();
  final StoreRepository _storeRepository = getIt<StoreRepository>();

  Future<void> _searchZipCode(String zipcode) async {
    setState(() => _zipCodeStatus = PageStatusLoading());
    final result = await _storeRepository.getZipcodeAddress(zipcode);

    // ✅ Envolve a atualização em setState para reconstruir o formulário com os novos dados
    setState(() {
      result.fold(
            (failure) => _zipCodeStatus = PageStatusError(failure.message),
            (address) {
          _address = address; // Atualiza a variável de estado principal
          _zipCodeStatus = PageStatusSuccess(address);
        },
      );
    });
  }

  Future<void> _submitSubscription() async {
    // Valida o formulário apenas se for um plano pago
    if (widget.plan.price > 0 && !formKey.currentState!.validate()) {
      showError('Algum campo necessita de atenção');
      return;
    }

    final VoidCallback hideLoading = showLoading();

    try {
      // Lógica para plano pago
      if (widget.plan.price > 0) {
        final tokenizeResult = await _storeRepository.generateCardToken(_creditCard);

        await tokenizeResult.fold(
              (failure) async {
            showError(failure.message);
          },
              (tokenizedCard) async {
            final payload = CreateSubscriptionPayload(
              planId: widget.plan.id,
              customer: _billingCustomer,
              card: tokenizedCard,
              address: _address, // ✅ Usa a variável de estado _address
            );
            await _createSubscription(payload);
          },
        );
      } else {
        // Lógica para plano gratuito
        final payload = CreateSubscriptionPayload(planId: widget.plan.id);
        await _createSubscription(payload);
      }
    } finally {
      hideLoading(); // Garante que o loading seja fechado mesmo se ocorrer um erro
    }
  }

  Future<void> _createSubscription(CreateSubscriptionPayload payload) async {
    final result = await _storeRepository.createSubscription(widget.storeId, payload);

    result.fold(
          (failure) {
        showError(failure.message);
      },
          (success) {
        showSuccess('Assinatura realizada com sucesso');
        if (context.mounted) context.pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isPaidPlan = widget.plan.price > 0;

    return Center(
      child: SingleChildScrollView(
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- CABEÇALHO ---
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          isPaidPlan
                              ? '${widget.plan.planName}: ${widget.plan.price.toPrice()}/${widget.plan.interval == 1 ? 'mês' : '${widget.plan.interval} meses'}'
                              : '${widget.plan.planName}: Grátis',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('ATENÇÃO: Seu plano atual será cancelado e substituído por este.'),
                  const SizedBox(height: 24),

                  // --- FORMULÁRIO (APENAS PARA PLANOS PAGOS) ---
                  if (isPaidPlan) ...[
                    // --- ENDEREÇO DE COBRANÇA ---
                    const Text('Endereço de cobrança', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                          _searchZipCode(c);
                        } else {
                          setState(() {
                            _zipCodeStatus = PageStatusIdle();
                          });
                        }
                      },
                    ),





                    const SizedBox(height: 16),

                    if (_zipCodeStatus is PageStatusSuccess<Address>)
                      Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AppTextField(
                                  initialValue: _address.state, // ✅ Usa a variável de estado _address
                                  title: 'Estado',
                                  hint: 'Ex: SP',
                                  enabled: false,
                                  onChanged: (c) {},
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AppTextField(
                                  initialValue: _address.city, // ✅ Usa a variável de estado _address
                                  title: 'Cidade',
                                  hint: 'Ex: São Paulo',
                                  enabled: false,
                                  onChanged: (c) {},
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            initialValue: _address.street, // ✅ Usa a variável de estado _address
                            title: 'Endereço',
                            hint: 'Ex: Rua ABC',
                            validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
                            // ✅ Atualiza a variável de estado _address
                            onChanged: (c) => _address = _address.copyWith(street: c),
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            initialValue: _address.neighborhood, // ✅ Usa a variável de estado _address
                            title: 'Bairro',
                            hint: 'Ex: Brooklin',
                            validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
                            // ✅ Atualiza a variável de estado _address
                            onChanged: (c) => _address = _address.copyWith(neighborhood: c),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AppTextField(
                                  title: 'Número',
                                  hint: 'Ex: 123',
                                  validator: (v) => (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
                                  // ✅ Atualiza a variável de estado _address
                                  onChanged: (c) => _address = _address.copyWith(number: c),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: AppTextField(
                                  title: 'Complemento',
                                  hint: 'Ex: Apto 101',
                                  // ✅ Atualiza a variável de estado _address
                                  onChanged: (c) => _address = _address.copyWith(complement: c),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else if (_zipCodeStatus is PageStatusLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_zipCodeStatus is PageStatusError)
                        Center(child: Text((_zipCodeStatus as PageStatusError).message, style: const TextStyle(color: Colors.red))),

                    const SizedBox(height: 24),
                    // --- DADOS DO PROPRIETÁRIO ---
                    const Text('Dados do proprietário do cartão', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    AppTextField(
                      title: 'Nome completo',
                      hint: '',
                      validator: (v) => (v == null || v.split(' ').length < 2) ? 'Informe o nome completo' : null,
                      onChanged: (c) => _billingCustomer = _billingCustomer.copyWith(name: c),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      title: 'CPF',
                      hint: 'Ex: 123.456.789-09',
                      formatters: [FilteringTextInputFormatter.digitsOnly, CpfInputFormatter()],
                      validator: (v) => (v == null || v.length < 14) ? 'CPF inválido' : null,
                      onChanged: (c) => _billingCustomer = _billingCustomer.copyWith(cpf: c),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      title: 'E-mail',
                      hint: 'Ex: email@email.com',
                      validator: (v) => (v == null || !EmailValidator.validate(v)) ? 'E-mail inválido' : null,
                      onChanged: (c) => _billingCustomer = _billingCustomer.copyWith(email: c),
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
                        _billingCustomer = _billingCustomer.copyWith(
                            birthday: DateFormat('dd/MM/yyyy').tryParse(c!));
                      },
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      initialValue: _billingCustomer.phone,
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
                        _billingCustomer = _billingCustomer.copyWith(phone: c);
                      },
                    ),
                    const SizedBox(height: 24),
                    // --- DADOS DO CARTÃO ---
                    const Text('Dados do cartão de crédito', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    AppTextField(
                      title: 'Número do cartão',
                      hint: 'Ex: 1234 5678 9012 3456',
                      validator: (v) => (v == null || v.length < 19) ? 'Número inválido' : null,
                      formatters: [FilteringTextInputFormatter.digitsOnly, CartaoBancarioInputFormatter()],
                      onChanged: (c) => _creditCard = _creditCard.copyWith(number: c),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            hint: 'MM/YY',
                            title: 'Vencimento',
                            formatters: [FilteringTextInputFormatter.digitsOnly, ValidadeCartaoInputFormatter()],
                            validator: (v) => (v == null || v.length < 5) ? 'Data inválida' : null,
                            onChanged: (c) {
                              if (c != null && c.length == 5) {
                                _creditCard = _creditCard.copyWith(expirationDate: DateFormat('MM/yy').tryParse(c));
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: AppTextField(
                            title: 'CVV',
                            hint: 'Ex: 123',
                            validator: (v) => (v == null || v.length < 3) ? 'CVV inválido' : null,
                            formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
                            onChanged: (c) => _creditCard = _creditCard.copyWith(cvv: c),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),
                  // ✅ BOTÃO ÚNICO E FUNCIONAL
                  AppPrimaryButton(
                    label: isPaidPlan ? 'Assinar' : 'Voltar ao plano gratuito',
                    onPressed: _submitSubscription,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
