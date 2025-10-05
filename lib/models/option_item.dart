import '../core/enums/foodtags.dart';
import 'package:equatable/equatable.dart';
import 'image_model.dart'; // ✅ 1. IMPORTE O IMAGE MODEL

class OptionItem extends Equatable {
  final int? id;
  final String? localId;
  final String name;
  final String? description;
  final int price;
  final bool isActive;
  final int? priority;
  final String? externalCode;
  final int? slices;
  final int? maxFlavors;
  final Set<FoodTag> tags;
  final ImageModel? image; // ✅ 2. ADICIONE O CAMPO DE IMAGEM

  const OptionItem({
    this.id,
    this.localId,
    required this.name,
    this.description,
    this.price = 0,
    this.isActive = true,
    this.priority,
    this.externalCode,
    this.slices,
    this.maxFlavors,
    this.tags = const {},
    this.image, // ✅ 3. ADICIONE AO CONSTRUTOR
  });

  @override
  List<Object?> get props => [
    id, localId, name, description, price, isActive, priority,
    externalCode, slices, maxFlavors, tags, image // ✅ 4. ADICIONE AOS PROPS
  ];

  OptionItem copyWith({
    int? id,
    String? localId,
    String? name,
    String? description,
    int? price,
    bool? isActive,
    int? priority,
    String? externalCode,
    int? slices,
    int? maxFlavors,
    Set<FoodTag>? tags,
    ImageModel? image, // ✅ 5. ADICIONE AO COPYWITH
    bool forceImageToNull = false, // Flag para limpar a imagem
  }) {
    return OptionItem(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      priority: priority ?? this.priority,
      externalCode: externalCode ?? this.externalCode,
      slices: slices ?? this.slices,
      maxFlavors: maxFlavors ?? this.maxFlavors,
      tags: tags ?? this.tags,
      image: forceImageToNull ? null : (image ?? this.image), // ✅ 6. LÓGICA DO COPYWITH
    );
  }

  factory OptionItem.fromJson(Map<String, dynamic> json) {
    final tagsSet = (json['tags'] as List<dynamic>? ?? [])
        .map((tagString) => FoodTag.values.firstWhere((e) => e.name == tagString, orElse: () => FoodTag.vegetarian))
        .toSet();

    return OptionItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: ((json['price'] as num? ?? 0.0) * 100).round(),
      isActive: json['is_active'],
      priority: json['priority'],
      externalCode: json['external_code'],
      slices: json['slices'],
      maxFlavors: json['max_flavors'],
      tags: tagsSet,
      // ✅ 7. LEIA A IMAGEM DO JSON
      image: json['image_path'] != null ? ImageModel(url: json['image_path']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price / 100,
      'is_active': isActive,
      'priority': priority,
      'external_code': externalCode,
      'slices': slices,
      'max_flavors': maxFlavors,
      'tags': tags.map((tag) => tag.name).toList(),
      // A imagem não é enviada no JSON principal. O upload é um processo separado.
    };
  }
}