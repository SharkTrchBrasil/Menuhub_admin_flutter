// lib/widgets/credit_card_form.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:totem_pro_admin/core/utils/card_utils.dart';

class CreditCardForm extends StatefulWidget {
  final TextEditingController cardNumberController;
  final TextEditingController holderNameController;
  final TextEditingController expiryController;
  final TextEditingController cvvController;

  const CreditCardForm({
    super.key,
    required this.cardNumberController,
    required this.holderNameController,
    required this.expiryController,
    required this.cvvController,
  });

  @override
  State<CreditCardForm> createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  CardBrand _detectedBrand = CardBrand.unknown;

  void _onCardNumberChanged(String value) {
    final brand = CardUtils.detectBrand(value);
    if (brand != _detectedBrand) {
      setState(() => _detectedBrand = brand);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ═══════════════════════════════════════════════════════════
        // NÚMERO DO CARTÃO
        // ═══════════════════════════════════════════════════════════
        TextFormField(
          controller: widget.cardNumberController,
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
          controller: widget.holderNameController,
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
                controller: widget.expiryController,
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
                controller: widget.cvvController,
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
      ],
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