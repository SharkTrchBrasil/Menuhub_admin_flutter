// lib/pages/subscriptions/update_card_dialog.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/models/subscription/create_subscription_payload.dart';

import 'credit_card_form.dart';


class UpdateCardDialog extends StatefulWidget {
  final int storeId;

  const UpdateCardDialog({super.key, required this.storeId});

  @override
  State<UpdateCardDialog> createState() => _UpdateCardDialogState();
}

class _UpdateCardDialogState extends State<UpdateCardDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _holderNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _updateCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = GetIt.I<StoreRepository>();

      // ═══════════════════════════════════════════════════════════
      // 1. TOKENIZAR CARTÃO
      // ═══════════════════════════════════════════════════════════
      final expiry = _expiryController.text.split('/');

      final tokenResult = await repository.generatePagarmeCardToken(
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        holderName: _holderNameController.text,
        expirationMonth: expiry[0].trim(),
        expirationYear: '20${expiry[1].trim()}', // 25 → 2025
        cvv: _cvvController.text,
      );

      await tokenResult.fold(
            (error) async {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
            (tokenData) async {
          // ═══════════════════════════════════════════════════════════
          // 2. CRIAR PAYLOAD
          // ═══════════════════════════════════════════════════════════
          final payload = CreateSubscriptionPayload.fromTokenResult(tokenData);

          debugPrint('📤 Atualizando cartão...');
          debugPrint('   Token: ${tokenData.token.substring(0, 20)}...');
          debugPrint('   Máscara: ${tokenData.cardMask}');

          // ═══════════════════════════════════════════════════════════
          // 3. ENVIAR PARA BACKEND
          // ═══════════════════════════════════════════════════════════
          final updateResult = await repository.updateSubscriptionCard(
            widget.storeId,
            payload,
          );

          updateResult.fold(
                (error) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
                (_) {
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Cartão atualizado com sucesso!'),
                    backgroundColor: Colors.green,
                  ),
                );


              }
            },
          );
        },
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erro ao atualizar cartão: $e');
      debugPrint('Stack trace: $stackTrace');

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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ═══════════════════════════════════════════════════════════
              // HEADER
              // ═══════════════════════════════════════════════════════════
              Row(
                children: [
                  const Icon(Icons.credit_card, color: Color(0xFF3C76E8)),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Atualizar Cartão de Crédito',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ═══════════════════════════════════════════════════════════
              // FORMULÁRIO DE CARTÃO (REUTILIZÁVEL)
              // ═══════════════════════════════════════════════════════════
              CreditCardForm(
                cardNumberController: _cardNumberController,
                holderNameController: _holderNameController,
                expiryController: _expiryController,
                cvvController: _cvvController,
              ),
              const SizedBox(height: 24),

              // ═══════════════════════════════════════════════════════════
              // BOTÕES DE AÇÃO
              // ═══════════════════════════════════════════════════════════
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateCard,
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
                          : const Text(
                        'Atualizar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ═══════════════════════════════════════════════════════════
              // SEGURANÇA
              // ═══════════════════════════════════════════════════════════
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Transação segura via Pagar.me',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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