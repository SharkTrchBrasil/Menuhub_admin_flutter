import 'package:totem_pro_admin/models/image_model.dart'; // Garanta que este import está correto

class VariantOption {
  // --- Atributos que vêm da API ---
  final int? id;
  final int? variantId;
  final String resolvedName;
  final int resolvedPrice;
  final String? imagePath;
  final bool isActuallyAvailable; // ✅ Campo de disponibilidade real

  // --- Atributos que enviamos para a API ---
  final String? name_override;
  final String? description; // ✅ Novo
  final int? price_override;
  final bool available;
  final String? pos_code;
  final int? linked_product_id;
  final bool track_inventory; // ✅ Novo
  final int stock_quantity; // ✅ Novo
  final ImageModel? image; // ✅ Para upload do arquivo

  VariantOption({
    this.id,
    this.variantId,
    String? resolvedName,
    int? resolvedPrice,
    this.imagePath,
    this.isActuallyAvailable = true,
    this.name_override,
    this.description, // ✅ Adicionado ao construtor
    this.price_override,
    this.available = true,
    this.pos_code,
    this.linked_product_id,
    this.track_inventory = false, // ✅ Adicionado ao construtor
    this.stock_quantity = 0, // ✅ Adicionado ao construtor
    this.image, // ✅ Adicionado ao construtor
  })  : resolvedName = resolvedName ?? name_override ?? '',
        resolvedPrice = resolvedPrice ?? price_override ?? 0;

  /// Construtor de fábrica para criar a partir de um JSON vindo da API.
  factory VariantOption.fromJson(Map<String, dynamic> json) {
    return VariantOption(
      id: json['id'],
      variantId: json['variant_id'],
      resolvedName: json['resolved_name'],
      resolvedPrice: json['resolved_price'],
      imagePath: json['image_path'],
      isActuallyAvailable: json['is_actually_available'] ?? true, // ✅ Novo
      name_override: json['name_override'],
      description: json['description'], // ✅ Novo
      price_override: json['price_override'],
      available: json['available'] ?? true,
      pos_code: json['pos_code'],
      linked_product_id: json['linked_product_id'],
      track_inventory: json['track_inventory'] ?? false, // ✅ Novo
      stock_quantity: json['stock_quantity'] ?? 0, // ✅ Novo
      // O 'image' não vem no JSON, ele é apenas para upload
    );
  }

  /// Converte o objeto para um JSON a ser enviado para a API.
  Map<String, dynamic> toJson() {
    return {
      'variant_id': variantId,
      'name_override': name_override,
      'description': description, // ✅ Novo
      'price_override': price_override,
      'available': available,
      'pos_code': pos_code,
      'linked_product_id': linked_product_id,
      'track_inventory': track_inventory, // ✅ Novo
      'stock_quantity': stock_quantity, // ✅ Novo
    };
  }

  /// Método para criar uma cópia do objeto, útil para o BLoC/Cubit.
  VariantOption copyWith({
    int? id,
    int? variantId,
    String? resolvedName,
    int? resolvedPrice,
    String? imagePath,
    bool? isActuallyAvailable,
    String? name_override,
    String? description, // ✅ Novo
    int? price_override,
    bool? available,
    String? pos_code,
    int? linked_product_id,
    bool? track_inventory, // ✅ Novo
    int? stock_quantity, // ✅ Novo
    ImageModel? image, // ✅ Novo
  }) {
    return VariantOption(
      id: id ?? this.id,
      variantId: variantId ?? this.variantId,
      resolvedName: resolvedName ?? this.resolvedName,
      resolvedPrice: resolvedPrice ?? this.resolvedPrice,
      imagePath: imagePath ?? this.imagePath,
      isActuallyAvailable: isActuallyAvailable ?? this.isActuallyAvailable,
      name_override: name_override ?? this.name_override,
      description: description ?? this.description,
      price_override: price_override ?? this.price_override,
      available: available ?? this.available,
      pos_code: pos_code ?? this.pos_code,
      linked_product_id: linked_product_id ?? this.linked_product_id,
      track_inventory: track_inventory ?? this.track_inventory,
      stock_quantity: stock_quantity ?? this.stock_quantity,
      image: image ?? this.image,
    );
  }
}