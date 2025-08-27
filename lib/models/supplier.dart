// lib/models/supplier.dart

import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final int id;
  final String name;
  final String? tradeName; // Nome Fantasia
  final String? document; // CPF ou CNPJ
  final String? email;
  final String? phone;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? bankInfo;
  final String? notes;

  const Supplier({
    required this.id,
    required this.name,
    this.tradeName,
    this.document,
    this.email,
    this.phone,
    this.address,
    this.bankInfo,
    this.notes,
  });

  /// Construtor de fábrica para criar uma instância de Supplier a partir de um JSON.
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] as int,
      name: json['name'] as String,
      tradeName: json['trade_name'] as String?,
      document: json['document'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      // Garante que os mapas sejam criados corretamente se não forem nulos
      address: json['address'] != null
          ? Map<String, dynamic>.from(json['address'])
          : null,
      bankInfo: json['bank_info'] != null
          ? Map<String, dynamic>.from(json['bank_info'])
          : null,
      notes: json['notes'] as String?,
    );
  }

  // Equatable ajuda a comparar objetos Supplier. Muito útil em BLoC/Cubit.
  @override
  List<Object?> get props => [
    id,
    name,
    tradeName,
    document,
    email,
    phone,
    address,
    bankInfo,
    notes,
  ];
}