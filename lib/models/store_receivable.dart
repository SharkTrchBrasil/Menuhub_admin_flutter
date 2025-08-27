import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/store_customer.dart';
import 'receivable_category.dart';





class StoreReceivable extends Equatable {
  final int id;
  final String title;
  final String? description;
  final int amount; // Valor em centavos
  final DateTime dueDate;
  final DateTime? receivedDate;
  final String status;
  final ReceivableCategory? category;
  final StoreCustomer? customer;

  const StoreReceivable({
    required this.id,
    required this.title,
    this.description,
    required this.amount,
    required this.dueDate,
    this.receivedDate,
    required this.status,
    this.category,
    this.customer,
  });

  factory StoreReceivable.fromJson(Map<String, dynamic> json) {
    return StoreReceivable(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      amount: json['amount'] as int,
      // Converte a string de data (ex: "2025-08-22") para um objeto DateTime
      dueDate: DateTime.parse(json['due_date']),
      // Faz o mesmo para a data de recebimento, que pode ser nula
      receivedDate: json['received_date'] != null
          ? DateTime.parse(json['received_date'])
          : null,
      status: json['status'] as String,
      // Converte os objetos aninhados (se existirem)
      category: json['category'] != null
          ? ReceivableCategory.fromJson(json['category'])
          : null,
      customer: json['customer'] != null
          ? StoreCustomer.fromJson(json['customer'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    amount,
    dueDate,
    receivedDate,
    status,
    category,
    customer,
  ];
}