class PaymentMethodSummary {
  final String methodName;
  final double totalAmount; // Valor em Reais (API já converte de centavos)

  PaymentMethodSummary({required this.methodName, required this.totalAmount});

  factory PaymentMethodSummary.fromJson(Map<String, dynamic> json) {
    return PaymentMethodSummary(
      methodName: json['method_name'],
      totalAmount: (json['total_amount'] as num).toDouble(),
    );
  }
}