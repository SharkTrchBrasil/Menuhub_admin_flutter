class CreditCard {

  CreditCard({
    this.number = '',
    this.cvv = '',
    this.expirationDate,
    this.brand = '',
  });

  final String number;
  final String cvv;
  final DateTime? expirationDate;
  final String? brand;

  CreditCard copyWith({
    String? number,
    String? cvv,
    DateTime? expirationDate,
    String? brand,
  }) {
    return CreditCard(
      number: number ?? this.number,
      cvv: cvv ?? this.cvv,
      expirationDate: expirationDate ?? this.expirationDate,
      brand: brand ?? this.brand,
    );
  }
}