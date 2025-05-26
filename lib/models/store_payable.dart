import 'package:dio/dio.dart';

class StorePayable {
  final int? id;
  final String title;
  final String? description;
  final String? barcode;
  final int value; // em centavos
  final String dueDate; // formato ISO (yyyy-MM-dd)
  final String? paymentDate;
  final String status; // 'open', 'paid', 'cancelled'
  final bool? isFixed;

  StorePayable( {
    this.id,
    required this.title,
    this.description,
    this.barcode,
    required this.value,
    required this.dueDate,
    this.paymentDate,
    required this.status,
    this.isFixed,
  });

  StorePayable copyWith({
    int? id,
    String? title,
    String? description,
    String? barcode,
    int? value,
    String? dueDate,
    String? paymentDate,
    String? status,
    bool? isFixed,
  }) {
    return StorePayable(
      id: id ?? this.id,
      title: title ?? this.title,

      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      value: value ?? this.value,
      dueDate: dueDate ?? this.dueDate,
      paymentDate: paymentDate ?? this.paymentDate,
      status: status ?? this.status,
      isFixed: isFixed ?? this.isFixed,
    );
  }

  factory StorePayable.fromJson(Map<String, dynamic> json) {
    return StorePayable(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      barcode: json['barcode'],
      value: json['value'],
      dueDate: json['due_date'],
      paymentDate: json['payment_date'],
      status: json['status'],
      isFixed: json['is_fixed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
       'title': title,
      'description': description,
      'barcode': barcode,
      'value': value,
      'due_date': dueDate,
      'payment_date': paymentDate,
      'status': status,
      'is_fixed': isFixed,
    };
  }

  FormData toFormData() {
    return FormData.fromMap({
      if (id != null) 'id': id.toString(),
      'description': description,
      'title': title,
      if (barcode != null) 'barcode': barcode,
      'value': value.toString(),
      'due_date': dueDate,
      if (paymentDate != null) 'payment_date': paymentDate,
      'status': status,
      'is_fixed': isFixed.toString(),
    });
  }
}
