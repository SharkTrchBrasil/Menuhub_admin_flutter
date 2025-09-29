import 'package:dio/dio.dart';

class StorePayable {
  final int? id;
  final String title;
  final String? description;
  final String? barcode;
  final int amount; // em centavos
  final String dueDate; // formato ISO (yyyy-MM-dd)
  final String? paymentDate;
  final String status; // 'open', 'paid', 'cancelled'


  StorePayable( {
    this.id,
    required this.title,
    this.description,
    this.barcode,
    required this.amount,
    required this.dueDate,
    this.paymentDate,
    required this.status,

  });

  StorePayable copyWith({
    int? id,
    String? title,
    String? description,
    String? barcode,
    int? amount,
    String? dueDate,
    String? paymentDate,
    String? status,

  }) {
    return StorePayable(
      id: id ?? this.id,
      title: title ?? this.title,

      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,

    );
  }

  factory StorePayable.fromJson(Map<String, dynamic> json) {
    return StorePayable(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      barcode: json['barcode'],
      amount: json['amount'],
      dueDate: json['due_date'],
      paymentDate: json['payment_date'],
      status: json['status'],
        );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
       'title': title,
      'description': description,
      'barcode': barcode,
      'amount': amount,
      'due_date': dueDate,
      'payment_date': paymentDate,
      'status': status,

    };
  }


}
