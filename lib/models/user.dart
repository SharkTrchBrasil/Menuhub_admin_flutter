// lib/models/user.dart

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? cpf;
  final DateTime? birthDate;
  final String referralCode;
  final bool isEmailVerified;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.cpf,
    this.birthDate,
    required this.referralCode,
    required this.isEmailVerified,
  });

  // Construtor factory para criar um User a partir de um JSON vindo da API
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      cpf: json['cpf'],
      // tryParse é mais seguro, pois retorna null se o formato da data for inválido
      birthDate: json['birth_date'] != null ? DateTime.tryParse(json['birth_date']) : null,
      referralCode: json['referral_code'],
      isEmailVerified: json['is_email_verified'] ?? false,
    );
  }

  // Método para criar uma cópia do objeto com valores alterados
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? cpf,
    DateTime? birthDate,
    String? referralCode,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      cpf: cpf ?? this.cpf,
      birthDate: birthDate ?? this.birthDate,
      referralCode: referralCode ?? this.referralCode,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  // Propriedades usadas pelo Equatable para comparar dois objetos User
  @override
  List<Object?> get props => [
    id, name, email, phone, cpf, birthDate, referralCode, isEmailVerified
  ];
}