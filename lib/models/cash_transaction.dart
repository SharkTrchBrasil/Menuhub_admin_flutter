// lib/models/cashier_transaction.dart
import 'package:flutter/foundation.dart'; // Import for debugPrint

class CashierTransaction {
  final int id;

  final double amount;
  final String type; // Corrigido para tipos do backend (sale, refund, inflow, outflow, withdraw, sangria)
  final String? description;
  final int? paymentMethod; // Adicionado
 final int? orderId; // Adicionado
  final DateTime createdAt;
  final DateTime updatedAt; // Adicionado (do TimestampMixin)

  CashierTransaction({
    required this.id,

    required this.amount,
    required this.type,
    this.description,
     this.paymentMethod,
 this.orderId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CashierTransaction.fromJson(Map<String, dynamic> json) {
    debugPrint('CashierTransaction fromJson: $json');
    return CashierTransaction(
      id: json['id'] as int, // Adicione o 'as int' para segurança de tipo

      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String, // Adicione 'as String'
      description: json['description'] as String?, // Já estava correto
      paymentMethod: json['payment_method_id'] as int?, // <--- MUDE AQUI: use 'as String?'
      orderId: json['order_id'] as int?, // Já estava correto
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // O método toJson() não é usado na sua CashPage para este modelo,
  // mas seria necessário para criar transações no backend.
  Map<String, dynamic> toJson() => {
    'id': id,

    'amount': amount,
    'type': type,
    'description': description,
    'payment_method': paymentMethod,
    'order_id': orderId,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}