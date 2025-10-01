import 'package:brasil_fields/brasil_fields.dart';

class Address {
  final String zipcode;
  final String city;
  final String state;
  final String neighborhood;
  final String street;
  final String number;
  final String complement;

  Address({
    required this.zipcode,
    required this.city,
    required this.state,
    required this.neighborhood,
    required this.street,
    this.number = '',
    this.complement = '',
  });

  // ✅ CORREÇÃO APLICADA AQUI
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      // Usa as chaves corretas da API ViaCEP
      zipcode: json['cep'] ?? '',
      city: json['localidade'] ?? '',
      state: json['estado'] ?? '',
      neighborhood: json['bairro'] ?? '',
      street: json['logradouro'] ?? '',
      complement: json['complemento'] ?? '',
    );
  }

  Address copyWith({
    String? zipcode,
    String? city,
    String? state,
    String? neighborhood,
    String? street,
    String? number,
    String? complement,
  }) {
    return Address(
      zipcode: zipcode ?? this.zipcode,
      city: city ?? this.city,
      state: state ?? this.state,
      neighborhood: neighborhood ?? this.neighborhood,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
    );
  }

// Em lib/models/address.dart

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      // ✅ CORREÇÃO AQUI: Só formata o CEP se ele não for nulo E não for vazio.
      'zipcode': (zipcode != null && zipcode!.isNotEmpty)
          ? UtilBrasilFields.removeCaracteres(zipcode!)
          : null,
    };
  }
}
