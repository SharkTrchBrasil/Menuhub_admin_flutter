import 'package:brasil_fields/brasil_fields.dart';
import 'package:intl/intl.dart';

class BillingCustomer {

  BillingCustomer({
    this.name = '',
    this.cpf = '',
    this.email = '',
    this.birthday,
    this.phone = ''
  });

  final String name;
  final String cpf;
  final String email;
  final DateTime? birthday;
  final String phone;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cpf': UtilBrasilFields.removeCaracteres(cpf),
      'email': email,
      'birth': DateFormat('yyyy-MM-dd').format(birthday!),
      'phone_number': UtilBrasilFields.removeCaracteres(phone),
    };
  }

  BillingCustomer copyWith({
    String? name,
    String? cpf,
    String? email,
    DateTime? birthday,
    String? phone,
  }) {
    return BillingCustomer(
      name: name ?? this.name,
      cpf: cpf ?? this.cpf,
      email: email ?? this.email,
      birthday: birthday ?? this.birthday,
      phone: phone ?? this.phone,
    );
  }
}