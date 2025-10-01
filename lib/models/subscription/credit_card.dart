import '../../core/utils/card_utils.dart';

class CreditCard {

  CreditCard({
    this.number = '',
    this.cvv = '',
    this.expirationDate,
    this.brand = CardBrand.unknown
  });

  final String number;
  final String cvv;
  final DateTime? expirationDate;
  final CardBrand brand;

  CreditCard copyWith({
    String? number,
    String? cvv,
    DateTime? expirationDate,
    CardBrand? brand,
  }) {
    return CreditCard(
      number: number ?? this.number,
      cvv: cvv ?? this.cvv,
      expirationDate: expirationDate ?? this.expirationDate,
      brand: brand ?? this.brand,
    );
  }
}