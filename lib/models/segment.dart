// lib/models/segment.dart

import 'package:equatable/equatable.dart';

class Segment extends Equatable {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  const Segment({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  // Factory constructor para criar uma instância de Segment a partir de um JSON (mapa).
  // É aqui que a "mágica" da conversão de API para objeto acontece.
  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'],
    );
  }



  bool filter(String query) {
    return name.toLowerCase().contains(query.toLowerCase());
  }

  @override
  String toString() {
    return name;
  }
  // Equatable ajuda a comparar objetos Segment pelo seu conteúdo, não pela referência de memória.
  // Essencial para o flutter_bloc funcionar corretamente.
  @override
  List<Object?> get props => [id, name, description, isActive];
}