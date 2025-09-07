import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/product.dart';

class VariantOption {
  // --- Atributos que vêm da API ---
  final int? id;
  final int? variantId;
  // ✨ REMOVIDO: final String resolvedName;
  // ✨ REMOVIDO: final int resolvedPrice;
  final String? imagePath;
  final bool isActuallyAvailable;

  // --- Atributos que enviamos para a API ou usamos localmente ---
  final String? name_override;
  final String? description;
  final int? price_override;
  final bool available;
  final String? pos_code;
  final int? linked_product_id;
  final Product? linkedProduct; // Perfeito!
  final bool track_inventory;
  final int stock_quantity;
  final ImageModel? image;

  // ✨ CONSTRUTOR CORRIGIDO ✨
  VariantOption({
    this.id,
    this.variantId,
    this.imagePath,
    this.isActuallyAvailable = true,
    this.name_override,
    this.description,
    this.price_override,
    this.available = true,
    this.pos_code,
    this.linked_product_id,
    this.linkedProduct,
    this.track_inventory = false,
    this.stock_quantity = 0,
    this.image,
  });

  // ✨ SEU GETTER ESTÁ PERFEITO! ✨
  String get resolvedName {
    // Se há um nome customizado, ele tem prioridade.
    if (name_override != null && name_override!.isNotEmpty) {
      return name_override!;
    }
    // Senão, se há um produto lincado, usamos o nome dele.
    if (linkedProduct != null) {
      return linkedProduct!.name;
    }
    // Senão, usamos um nome padrão.
    return "Item sem nome";
  }

  // ✨ CRIEI UM GETTER PARA O PREÇO, SEGUINDO A MESMA LÓGICA ✨
  int get resolvedPrice {
    // Se há um preço customizado, ele tem prioridade.
    if (price_override != null) {
      return price_override!;
    }
    // Senão, se há um produto lincado, usamos o preço dele.
    if (linkedProduct != null) {
      return linkedProduct?.price ?? 0; // Supondo que seu 'Product' tem um campo 'price'
    }
    // Senão, o preço é 0.
    return 0;
  }

  // O resto do seu código (fromJson, toJson, copyWith) continua praticamente igual,
  // apenas removemos as referências aos campos que não existem mais.

  factory VariantOption.fromJson(Map<String, dynamic> json) {
    // Se a API retornar um `Product` aninhado, podemos construí-lo aqui também.
    Product? linkedProductJson = json['linked_product'] != null
        ? Product.fromJson(json['linked_product'])
        : null;

    return VariantOption(
      id: json['id'],
      variantId: json['variant_id'],
      imagePath: json['image_path'],
      isActuallyAvailable: json['is_actually_available'] ?? true,
      // Se 'name_override' for nulo no JSON, usamos o 'resolved_name' que a API manda.
      name_override: json['name_override'] ?? json['resolved_name'],
      description: json['description'],
      price_override: json['price_override'] ?? json['resolved_price'],
      available: json['available'] ?? true,
      pos_code: json['pos_code'],
      linked_product_id: json['linked_product_id'],
      linkedProduct: linkedProductJson, // Preenche com o objeto construído do JSON
      track_inventory: json['track_inventory'] ?? false,
      stock_quantity: json['stock_quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // É bom enviar o ID se for uma atualização
      'variant_id': variantId,
      'name_override': name_override,
      'description': description,
      'price_override': price_override,
      'available': available,
      'pos_code': pos_code,
      'linked_product_id': linked_product_id,
      'track_inventory': track_inventory,
      'stock_quantity': stock_quantity,
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


