import 'package:totem_pro_admin/models/variant_option.dart';

class Variant {
  const Variant({
    this.id,
    this.name = '',
    this.description = '',
    this.minQuantity = 1,
    this.maxQuantity = 1,
    this.available = false,
    this.repeatable = false,
    this.options,
  });

  final int? id;
  final String name;
  final String description;
  final int minQuantity;
  final int maxQuantity;
  final bool available;
  final bool repeatable;
  final List<VariantOption>? options;

  Variant copyWith({
    String? name,
    String? description,
    int? minQuantity,
    int? maxQuantity,
    bool? available,
    bool? repeatable,
  }) {
    return Variant(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      minQuantity: minQuantity ?? this.minQuantity,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      available: available ?? this.available,
      repeatable: repeatable ?? this.repeatable,
      options: options,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'min_quantity': minQuantity,
      'max_quantity': maxQuantity,
      'available': available,
      'repeatable': repeatable,
    };
  }

  factory Variant.fromJson(Map<String, dynamic> map) {
    return Variant(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      minQuantity: map['min_quantity'] as int,
      maxQuantity: map['max_quantity'] as int,
      available: map['available'] as bool,
      repeatable: map['repeatable'] as bool,
      options: (map['options'] as List)
          .map((option) => VariantOption.fromJson(option))
          .toList(),
    );
  }
}
