// lib/pages/plans/reactivate_subscription_page.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/models/subscription/create_subscription_payload.dart';


import 'credit_card_form.dart';

class ReactivateSubscriptionPage extends StatefulWidget {
  final int storeId;

  const ReactivateSubscriptionPage({
    super.key,
    required this.storeId,
  });

  @override
  State<ReactivateSubscriptionPage> createState() =>
      _ReactivateSubscriptionPageState();
}

class _ReactivateSubscriptionPageState
    extends State<ReactivateSubscriptionPage> {
  final _repository = GetIt.I<StoreRepository>();
  final _storesManagerCubit = GetIt.I<StoresManagerCubit>();

  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isLoading = false;
  bool _requiresCard = false;
  int _daysRemaining = 0;
  DateTime? _accessUntil;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionStatus();
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _holderNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _checkSubscriptionStatus() {
    final state = _storesManagerCubit.state;
    if (state is StoresManagerLoaded) {
      final subscription = state.activeStore?.relations.subscription;

      if (subscription != null) {
        final now = DateTime.now();
        final endDate = subscription.currentPeriodEnd;

        // ✅ VERIFICA SE AINDA TEM DIAS PAGOS
        if (endDate != null && now.isBefore(endDate)) {
          setState(() {
            _requiresCard = false;
            _daysRemaining = endDate.difference(now).inDays;
            _accessUntil = endDate;
          });
        } else {
          // ✅ EXPIROU - PRECISA DE NOVO CARTÃO
          setState(() {
            _requiresCard = true;
          });
        }
      }
    }
  }

  Future<void> _reactivate() async {
    // Se não precisa de cartão, reativa direto
    if (!_requiresCard) {
      await _reactivateWithoutCard();
      return;
    }

    // Se precisa de cartão, valida formulário
    if (!_formKey.currentState!.validate()) return;

    await _reactivateWithCard();
  }

  Future<void> _reactivateWithoutCard() async {
    setState(() => _isLoading = true);

    try {
      final result = await _repository.reactivateSubscription(
        widget.storeId,
      );

      result.fold(
            (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
            (response) {
          if (mounted) {


            // ✅ NAVEGA PARA DASHBOARD
            context.go('/stores/${widget.storeId}/dashboard');

            // ✅ MOSTRA SUCESSO
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Assinatura reativada com sucesso!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Erro ao reativar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _reactivateWithCard() async {
    setState(() => _isLoading = true);

    try {
      // ✅ 1. TOKENIZAR CARTÃO
      final expiry = _expiryController.text.split('/');

      final tokenResult = await _repository.generatePagarmeCardToken(
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        holderName: _holderNameController.text,
        expirationMonth: expiry[0].trim(),
        expirationYear: '20${expiry[1].trim()}',
        cvv: _cvvController.text,
      );

      await tokenResult.fold(
            (failure) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
            (tokenData) async {
          // ✅ 2. CRIAR PAYLOAD
          final payload = CreateSubscriptionPayload.fromTokenResult(tokenData);

          // ✅ 3. REATIVAR COM CARTÃO
          final reactivateResult = await _repository.reactivateSubscription(
            widget.storeId,
            cardData: payload,
          );

          reactivateResult.fold(
                (failure) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(failure.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
                (response) {
              if (mounted) {
                // ✅ RECARREGA DADOS
                _storesManagerCubit.loadInitialData();

                // ✅ NAVEGA PARA DASHBOARD
                context.go('/stores/${widget.storeId}/dashboard');

                // ✅ MOSTRA SUCESSO
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Assinatura reativada e cobrança processada!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
          );
        },
      );
    } catch (e) {
      debugPrint('❌ Erro ao reativar com cartão: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ═══════════════════════════════════════════════════════════
            // HEADER
            // ═══════════════════════════════════════════════════════════
            _buildHeader(),
            const SizedBox(height: 32),

            // ═══════════════════════════════════════════════════════════
            // FORMULÁRIO DE CARTÃO (SE NECESSÁRIO)
            // ═══════════════════════════════════════════════════════════
            if (_requiresCard) ...[
              _buildCardRequiredSection(),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: CreditCardForm(
                  cardNumberController: _cardNumberController,
                  holderNameController: _holderNameController,
                  expiryController: _expiryController,
                  cvvController: _cvvController,
                ),
              ),
            ] else
              _buildNoCardRequiredSection(),

            const SizedBox(height: 32),

            // ═══════════════════════════════════════════════════════════
            // BOTÃO DE AÇÃO
            // ═══════════════════════════════════════════════════════════
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _reactivate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3C76E8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                )
                    : Text(
                  _requiresCard
                      ? 'Reativar e Pagar'
                      : 'Reativar Gratuitamente',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.replay_circle_filled,
            size: 64,
            color: Colors.green.shade600,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Reative sua Assinatura',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Continue aproveitando todos os recursos da plataforma',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNoCardRequiredSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700, size: 48),
          const SizedBox(height: 16),
          Text(
            'Você ainda tem $_daysRemaining dias pagos!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Seu acesso vai até ${_accessUntil!.day.toString().padLeft(2, '0')}/${_accessUntil!.month.toString().padLeft(2, '0')}/${_accessUntil!.year}',
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ao reativar agora:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Sem cobrança adicional'),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Chatbot volta a funcionar'),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Loja reabre para pedidos'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardRequiredSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Novo Cartão Necessário',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Sua assinatura expirou. Para reativar, você precisa cadastrar um novo cartão de crédito.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}