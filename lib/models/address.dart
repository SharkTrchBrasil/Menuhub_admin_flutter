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

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      zipcode: json['zipcode'],
      city: json['city'],
      state: json['state'],
      neighborhood: json['neighborhood'],
      street: json['street'],
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

  Map<String, dynamic> toJson() {
    return {
      'zipcode': UtilBrasilFields.removeCaracteres(zipcode),
      'city': city,
      'state': state,
      'neighborhood': neighborhood,
      'street': street,
      'number': number,
      'complement': complement,
    };
  }
}
