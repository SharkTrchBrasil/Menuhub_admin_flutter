import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/models/plans/plans.dart';
import 'package:totem_pro_admin/models/subscription/create_subscription_payload.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/core/utils/card_utils.dart';

class NewSubscriptionDialog extends StatefulWidget {
  final int storeId;
  final Plans plan;

  const NewSubscriptionDialog({
    super.key,
    required this.storeId,
    required this.plan,
  });

  @override
  State<NewSubscriptionDialog> createState() => _NewSubscriptionDialogState();
}

class _NewSubscriptionDialogState extends State<NewSubscriptionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _repository = GetIt.I<StoreRepository>();

  // Controllers
  final _cardNumberController = TextEditingController();
  final _holderNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isLoading = false;
  CardBrand _detectedBrand = CardBrand.unknown;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _holderNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _onCardNumberChanged(String value) {
    final brand = CardUtils.detectBrand(value);
    if (brand != _detectedBrand) {
      setState(() => _detectedBrand = brand);
    }
  }

  /// ✅ VERSÃO FINAL CORRIGIDA
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // ═══════════════════════════════════════════════════════════
      // 1️⃣ TOKENIZA O CARTÃO VIA PAGAR.ME
      // ═══════════════════════════════════════════════════════════

      final expiry = _expiryController.text.split('/');

      final tokenResult = await _repository.generatePagarmeCardToken(
        cardNumber: _cardNumberController.text,
        holderName: _holderNameController.text,
        expirationMonth: expiry[0].trim(),
        expirationYear: '20${expiry[1].trim()}',
        // 25 → 2025
        cvv: _cvvController.text,
      );

      if (tokenResult.isLeft) {
        final failure = tokenResult.left;
        if (mounted) {
          _showError(failure.message);
        }
        return;
      }

      // ✅ CORREÇÃO: tokenResult.right é PagarmeTokenResult, não String
      final tokenData = tokenResult.right;

      debugPrint('✅ Token recebido: ${tokenData.token.substring(0, 20)}...');
      debugPrint('   Máscara: ${tokenData.cardMask}');
      debugPrint('   Bandeira: ${tokenData.brand}');

      // ═══════════════════════════════════════════════════════════
      // 2️⃣ CRIA PAYLOAD E ENVIA PARA O BACKEND
      // ═══════════════════════════════════════════════════════════

      // ✅ CORREÇÃO: Usa factory method
      final payload = CreateSubscriptionPayload.fromTokenResult(tokenData);

      debugPrint('📤 Enviando payload para backend...');
      debugPrint('   Payload: ${payload.toJson()}');

      final result = await _repository.createSubscription(
        widget.storeId,
        payload,
      );

      // ═══════════════════════════════════════════════════════════
      // 3️⃣ PROCESSA RESULTADO
      // ═══════════════════════════════════════════════════════════

      if (mounted) {
        if (result.isRight) {
          debugPrint('✅ Assinatura criada com sucesso!');
          _showSuccess();
        } else {
          debugPrint('❌ Erro ao criar assinatura: ${result.left.message}');
          _showError(result.left.message);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erro inesperado: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        _showError('Erro inesperado: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Assinatura ativada com sucesso!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
    Navigator.of(context).pop(true);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
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
                      'Adicionar Cartão',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ═══════════════════════════════════════════════════════════
              // NÚMERO DO CARTÃO
              // ═══════════════════════════════════════════════════════════
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Número do Cartão',
                  hintText: '0000 0000 0000 0000',
                  prefixIcon: Icon(
                    _detectedBrand != CardBrand.unknown
                        ? Icons.credit_card
                        : Icons.credit_card_outlined,
                    color: const Color(0xFF3C76E8),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  CardNumberInputFormatter(),
                ],
                onChanged: _onCardNumberChanged,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Digite o número do cartão';
                  }
                  final clean = value.replaceAll(' ', '');
                  if (clean.length < 13) {
                    return 'Número do cartão inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ═══════════════════════════════════════════════════════════
              // NOME DO TITULAR
              // ═══════════════════════════════════════════════════════════
              TextFormField(
                controller: _holderNameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Titular',
                  hintText: 'Como está no cartão',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Digite o nome do titular';
                  }
                  if (value.trim().length < 3) {
                    return 'Nome muito curto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ═══════════════════════════════════════════════════════════
              // VALIDADE E CVV
              // ═══════════════════════════════════════════════════════════
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'Validade',
                        hintText: 'MM/AA',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        ExpiryDateInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite a validade';
                        }
                        if (!value.contains('/') || value.length != 5) {
                          return 'Formato: MM/AA';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '123',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Digite o CVV';
                        }
                        if (value.length < 3) {
                          return 'CVV inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ═══════════════════════════════════════════════════════════
              // BOTÃO CONFIRMAR
              // ═══════════════════════════════════════════════════════════
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3C76E8),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Confirmar e Ativar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                ),
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
                    'Pagamento 100% seguro via Pagar.me',
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

// ═══════════════════════════════════════════════════════════
// FORMATADORES CUSTOMIZADOS
// ═══════════════════════════════════════════════════════════

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');

    if (text.length >= 2) {
      return TextEditingValue(
        text: '${text.substring(0, 2)}/${text.substring(2)}',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }

    return newValue;
  }
}
