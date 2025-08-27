import 'package:equatable/equatable.dart';

class ReceivableCategory extends Equatable {
  final int id;
  final String name;

  const ReceivableCategory({
    required this.id,
    required this.name,
  });

  /// Construtor de fábrica para criar uma instância a partir de um JSON.
  factory ReceivableCategory.fromJson(Map<String, dynamic> json) {
    return ReceivableCategory(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  @override
  List<Object?> get props => [id, name];
}