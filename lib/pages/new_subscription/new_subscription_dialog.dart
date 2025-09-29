// lib/pages/new_subscription/new_subscription_dialog.dart

import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Importe o flutter_bloc
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';
import 'package:totem_pro_admin/cubits/auth_cubit.dart'; // ✅ Importe o AuthCubit
import 'package:totem_pro_admin/cubits/auth_state.dart'; // ✅ Importe o AuthState
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/address.dart';
import 'package:totem_pro_admin/models/billing_customer.dart';
import 'package:totem_pro_admin/models/plans/plans.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/models/subscription/create_subscription_payload.dart';
import 'package:totem_pro_admin/models/subscription/credit_card.dart';
import 'package:totem_pro_admin/models/user.dart'; // Importe o modelo User
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_text_field.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final StoreRepository _storeRepository = getIt<StoreRepository>();

  // O StoresManagerCubit continua sendo necessário para pegar a loja ativa
  final StoresManagerCubit _storesManagerCubit = getIt<StoresManagerCubit>();

  // Variáveis de estado
  Address? _address;
  BillingCustomer? _billingCustomer;
  CreditCard _creditCard = CreditCard();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // Acessa o estado dos dois cubits
    final storeState = _storesManagerCubit.state;

    // ✅ CORREÇÃO PRINCIPAL: Acessa o AuthCubit através do context
    final authState = context.read<AuthCubit>().state;
    User? currentUser;

    if (authState is AuthAuthenticated) {
      currentUser = authState.data.user;
    }

    if (storeState is StoresManagerLoaded && storeState.activeStore != null && currentUser != null) {
      final Store store = storeState.activeStore!;
      setState(() {
        _address = Address(
          street: store.address?.street ?? '',
          number: store.address?.number ?? '',
          complement: store.address?.complement ?? '',
          neighborhood: store.address?.neighborhood ?? '',
          city: store.address?.city ?? '',
          state: store.address?.state ?? '',
          zipcode: store.address?.zipCode ?? '',
        );

        _billingCustomer = BillingCustomer(
          name: currentUser!.name,
          cpf: currentUser.cpf!,
          email: currentUser.email,
          phone: store.core.phone ?? currentUser.phone ?? '',
          birthday:  currentUser.birthDate,
        );

        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = "Não foi possível carregar os dados da loja ou do usuário. Tente novamente.";
        _isLoading = false;
      });
    }
  }

  Future<void> _submitSubscription() async {
    if (!_formKey.currentState!.validate()) {
      showError('Por favor, verifique os dados do cartão.');
      return;
    }

    if (_address == null || _billingCustomer == null) {
      showError("Dados da loja não carregados. Não é possível continuar.");
      return;
    }

    final VoidCallback hideLoading = showLoading();

    try {
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
            address: _address,
          );
          await _createSubscriptionInBackend(payload);
        },
      );
    } finally {
      hideLoading();
    }
  }

  Future<void> _createSubscriptionInBackend(CreateSubscriptionPayload payload) async {
    final result = await _storeRepository.createSubscription(widget.storeId, payload);

    result.fold(
          (failure) {
        showError(failure.message);
      },
          (success) {
        showSuccess('Cobrança ativada com sucesso!');
        if (context.mounted) context.pop();

      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // O restante do build permanece o mesmo, pois a UI não muda
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
            : Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ativar cobrança: ${widget.plan.planName}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Para ativar seu plano, precisamos dos dados de um cartão de crédito. A cobrança será realizada mensalmente com base no faturamento da sua loja, conforme os termos do plano.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 24),
                const Text('Dados do cartão de crédito', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                AppTextField(
                  title: 'Número do cartão',
                  hint: '0000 0000 0000 0000',
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
                        hint: 'MM/AA',
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
                        hint: '123',
                        validator: (v) => (v == null || v.length < 3) ? 'CVV inválido' : null,
                        formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                        onChanged: (c) => _creditCard = _creditCard.copyWith(cvv: c),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  label: 'Ativar Plano e Salvar Cartão',
                  onPressed: _submitSubscription,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}