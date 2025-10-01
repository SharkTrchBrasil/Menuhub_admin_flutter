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

// Em lib/models/billing_customer.dart

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      // ✅ CORREÇÃO AQUI: Só formata o CPF se ele não for nulo E não for vazio.
      'cpf': (cpf != null && cpf!.isNotEmpty)
          ? UtilBrasilFields.removeCaracteres(cpf!)
          : null,
      'email': email,
      // ✅ CORREÇÃO AQUI: Faz o mesmo para o telefone.
      'phone_number': (phone != null && phone!.isNotEmpty)
          ? UtilBrasilFields.removeCaracteres(phone!)
          : null,
      'birth': birthday != null ? DateFormat('yyyy-MM-dd').format(birthday!) : null,
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