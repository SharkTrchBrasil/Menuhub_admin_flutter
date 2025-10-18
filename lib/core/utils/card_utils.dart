import 'package:flutter/material.dart';

/// Enum para representar as bandeiras de cartão de forma segura
enum CardBrand {
  elo,
  mastercard,
  visa,
  amex,
  hipercard,
  diners,
  discover,
  jcb,
  unknown; // Bandeira desconhecida ou inválida

  /// Helper para obter o caminho do asset do logo
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
      case CardBrand.diners:
        return 'assets/images/card_flags/diners.png';
      case CardBrand.discover:
        return 'assets/images/card_flags/discover.png';
      case CardBrand.jcb:
        return 'assets/images/card_flags/jcb.png';
      default:
        return 'assets/images/card_flags/unknown.png';
    }
  }

  /// Nome amigável da bandeira
  String get displayName {
    switch (this) {
      case CardBrand.elo:
        return 'Elo';
      case CardBrand.mastercard:
        return 'Mastercard';
      case CardBrand.visa:
        return 'Visa';
      case CardBrand.amex:
        return 'American Express';
      case CardBrand.hipercard:
        return 'Hipercard';
      case CardBrand.diners:
        return 'Diners Club';
      case CardBrand.discover:
        return 'Discover';
      case CardBrand.jcb:
        return 'JCB';
      default:
        return 'Desconhecida';
    }
  }
}

class CardUtils {
  /// ✅ MÉTODO PRINCIPAL: Detecta a bandeira do cartão com base no número
  ///
  /// Compatível com todas as principais bandeiras do Brasil e internacionais
  static CardBrand detectBrand(String cardNumber) {
    // Remove tudo que não for dígito
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (cleanNumber.isEmpty) {
      return CardBrand.unknown;
    }

    // ✅ ELO (bandeira brasileira) - DEVE VIR PRIMEIRO!
    // Elo tem padrões que começam com 4, 5 e 6, então precisa ser testado antes de Visa/Mastercard
    if (RegExp(r'^(4011(78|79)|43(1274|8935)|45(1416|7393|763[12])|50(4175|6699|67[0-8][0-9]|9\d{3})|627780|636(297|368)|650\d{3}|651[6-9]\d{2}|655\d{3})').hasMatch(cleanNumber)) {
      return CardBrand.elo;
    }

    // ✅ VISA (começa com 4)
    if (RegExp(r'^4').hasMatch(cleanNumber)) {
      return CardBrand.visa;
    }

    // ✅ MASTERCARD (começa com 51-55 ou 2221-2720)
    if (RegExp(r'^(5[1-5]|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)').hasMatch(cleanNumber)) {
      return CardBrand.mastercard;
    }

    // ✅ AMEX (começa com 34 ou 37)
    if (RegExp(r'^3[47]').hasMatch(cleanNumber)) {
      return CardBrand.amex;
    }

    // ✅ HIPERCARD (606282, 384100, 384140, 384160)
    if (RegExp(r'^(606282|3841(00|40|60))').hasMatch(cleanNumber)) {
      return CardBrand.hipercard;
    }

    // ✅ DINERS CLUB (começa com 36, 38, 300-305)
    if (RegExp(r'^(36|38|30[0-5])').hasMatch(cleanNumber)) {
      return CardBrand.diners;
    }

    // ✅ DISCOVER (começa com 6011, 622126-622925, 644-649, 65)
    if (RegExp(r'^(6011|622(12[6-9]|1[3-9][0-9]|[2-8][0-9]{2}|9[01][0-9]|92[0-5])|64[4-9]|65)').hasMatch(cleanNumber)) {
      return CardBrand.discover;
    }

    // ✅ JCB (começa com 3528-3589)
    if (RegExp(r'^35(2[8-9]|[3-8][0-9])').hasMatch(cleanNumber)) {
      return CardBrand.jcb;
    }

    return CardBrand.unknown;
  }

  /// ✅ ALIAS PARA COMPATIBILIDADE (método antigo)
  static CardBrand detectCreditCardBrand(String cardNumber) {
    return detectBrand(cardNumber);
  }

  /// Valida se o número do cartão é válido usando algoritmo de Luhn
  static bool isValidCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (cleanNumber.isEmpty || cleanNumber.length < 13 || cleanNumber.length > 19) {
      return false;
    }

    int sum = 0;
    bool isSecond = false;

    for (int i = cleanNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanNumber[i]);

      if (isSecond) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      isSecond = !isSecond;
    }

    return (sum % 10 == 0);
  }

  /// Formata o número do cartão com espaços (4 em 4 dígitos)
  static String formatCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (int i = 0; i < cleanNumber.length; i++) {
      buffer.write(cleanNumber[i]);
      if ((i + 1) % 4 == 0 && i + 1 != cleanNumber.length) {
        buffer.write(' ');
      }
    }

    return buffer.toString();
  }

  /// Mascara o número do cartão (ex: **** **** **** 1234)
  static String maskCardNumber(String cardNumber) {
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (cleanNumber.length < 4) {
      return '****';
    }

    final lastFour = cleanNumber.substring(cleanNumber.length - 4);
    final maskedLength = cleanNumber.length - 4;
    final masked = '*' * maskedLength;

    // Formata com espaços
    final buffer = StringBuffer();
    final fullMasked = masked + lastFour;

    for (int i = 0; i < fullMasked.length; i++) {
      buffer.write(fullMasked[i]);
      if ((i + 1) % 4 == 0 && i + 1 != fullMasked.length) {
        buffer.write(' ');
      }
    }

    return buffer.toString();
  }

  /// Valida se o CVV é válido
  static bool isValidCVV(String cvv, CardBrand brand) {
    final cleanCVV = cvv.replaceAll(RegExp(r'\D'), '');

    // American Express usa CVV de 4 dígitos
    if (brand == CardBrand.amex) {
      return cleanCVV.length == 4;
    }

    // Outras bandeiras usam 3 dígitos
    return cleanCVV.length == 3;
  }

  /// Valida se a data de validade é válida
  static bool isValidExpiryDate(String expiryDate) {
    if (!expiryDate.contains('/')) {
      return false;
    }

    final parts = expiryDate.split('/');
    if (parts.length != 2) {
      return false;
    }

    final month = int.tryParse(parts[0].trim());
    final year = int.tryParse(parts[1].trim());

    if (month == null || year == null) {
      return false;
    }

    if (month < 1 || month > 12) {
      return false;
    }

    // Converte ano de 2 dígitos para 4 (ex: 25 → 2025)
    final fullYear = year < 100 ? 2000 + year : year;

    final now = DateTime.now();
    final expiryDateTime = DateTime(fullYear, month);

    // Cartão expira no último dia do mês
    final lastDayOfMonth = DateTime(fullYear, month + 1, 0);

    return lastDayOfMonth.isAfter(now);
  }

  /// Retorna o tamanho máximo do cartão para a bandeira
  static int getCardMaxLength(CardBrand brand) {
    switch (brand) {
      case CardBrand.amex:
        return 15;
      case CardBrand.diners:
        return 14;
      default:
        return 16;
    }
  }

  /// Retorna o ícone da bandeira
  static Widget getBrandIcon(CardBrand brand, {double size = 32}) {
    if (brand == CardBrand.unknown) {
      return Icon(
        Icons.credit_card,
        size: size,
        color: Colors.grey,
      );
    }

    return Image.asset(
      brand.assetPath,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.credit_card,
          size: size,
          color: Colors.grey,
        );
      },
    );
  }
}