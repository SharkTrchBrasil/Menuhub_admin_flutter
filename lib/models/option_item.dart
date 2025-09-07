import '../core/enums/foodtags.dart';
import 'package:equatable/equatable.dart';

// Adicionado Equatable para facilitar comparações no CUBIT
class OptionItem extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final int price; // ✅ Alterado para int (centavos)
  final bool isActive;
  final int? priority;
  final String? externalCode;
  final int? slices;       // ✨ NOVO
  final int? maxFlavors;   // ✨ NOVO
  final Set<FoodTag> tags;

  const OptionItem({
    this.id,
    required this.name,
    this.description,
    this.price = 0, // ✅
    this.isActive = true,
    this.priority,
    this.externalCode,
    this.slices,     // ✨
    this.maxFlavors, // ✨
    this.tags = const {},
  });

  factory OptionItem.fromJson(Map<String, dynamic> json) {
    // Lógica para tags, se houver
    final tagsSet = (json['tags'] as List<dynamic>? ?? [])
        .map((tagString) => FoodTag.values.firstWhere((e) => e.name == tagString, orElse: () => FoodTag.vegetarian))
        .toSet();

    return OptionItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      // ✅ O backend envia um float/decimal, convertemos para int (centavos)
      price: ((json['price'] as num? ?? 0.0) * 100).round(),
      isActive: json['is_active'],
      priority: json['priority'],
      externalCode: json['external_code'],
      slices: json['slices'],           // ✨
      maxFlavors: json['max_flavors'], // ✨
      tags: tagsSet,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // Enviar o ID é crucial para a lógica de update!
      'name': name,
      'description': description,
      'price': price / 100, // ✅ Converte centavos de volta para o formato decimal para a API
      'is_active': isActive,
      'priority': priority,
      'external_code': externalCode,
      'slices': slices,           // ✨
      'max_flavors': maxFlavors, // ✨
      'tags': tags.map((tag) => tag.name).toList(),
    };
  }

  // copyWith e props atualizados
  @override
  List<Object?> get props => [id, name, description, price, isActive, priority, externalCode, slices, maxFlavors, tags];


  OptionItem copyWith({
    int? id,
    String? name,
    String? description,
    int? price,
    bool? isActive,
    int? priority,
    String? externalCode,
    int? slices,
    int? maxFlavors,
    Set<FoodTag>? tags,
  }) {
    return OptionItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      externalCode: externalCode ?? this.externalCode,
      slices: slices ?? this.slices,
      maxFlavors: maxFlavors ?? this.maxFlavors,
      tags: tags ?? this.tags,
    );
  }
}