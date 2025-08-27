// lib/models/payable_category.dart

import 'package:equatable/equatable.dart';

class PayableCategory extends Equatable {
  final int id;
  final String name;

  const PayableCategory({
    required this.id,
    required this.name,
  });

  /// Construtor de fábrica para criar uma instância a partir de um JSON.
  factory PayableCategory.fromJson(Map<String, dynamic> json) {
    return PayableCategory(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name];
}