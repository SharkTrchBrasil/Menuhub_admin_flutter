import 'package:flutter/material.dart';

// Enum para representar as bandeiras de forma segura
enum CardBrand {
  elo,
  mastercard,
  visa,
  amex,
  hipercard,
  unknown; // Bandeira desconhecida ou inválida

  // Helper para obter o caminho do asset do logo
  String get assetPath {
    switch (this) {
      case CardBrand.elo:
        return 'assets/images/card_flags/elo.png';
      case CardBrand.mastercard:
        return 'assets/images/card_flags/mastercard.png';
      case CardBrand.visa:
        return 'assets/images/card_flags/visa.png';
      case CardBrand.amex:
        return 'assets/images/card_flags/amex.png';
      case CardBrand.hipercard:
        return 'assets/images/card_flags/hipercard.png';
      default:
        return 'assets/images/card_flags/unknown.png';
    }
  }
}

class CardUtils {
  /// Detecta a bandeira do cartão com base no número.
  static CardBrand detectCreditCardBrand(String cardNumber) {
    // Remove tudo que não for dígito
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (cleanNumber.isEmpty) {
      return CardBrand.unknown;
    }

    // Padrões de RegExp para cada bandeira
    final brandPatterns = {
      CardBrand.elo: RegExp(r'^(4011(78|79)|431274|438935|451416|457393|457631|457632|504175|506699|5067|509|627780|636297|636368|650|6516|6550)'),
      CardBrand.mastercard: RegExp(r'^5[1-5]'),
      CardBrand.visa: RegExp(r'^4'),
      CardBrand.amex: RegExp(r'^3[47]'),
      CardBrand.hipercard: RegExp(r'^(606282|384100|384140|384160)'),
    };

    // Itera sobre os padrões e retorna a primeira correspondência
    for (var entry in brandPatterns.entries) {
      if (entry.value.hasMatch(cleanNumber)) {
        return entry.key;
      }
    }

    return CardBrand.unknown;
  }
}