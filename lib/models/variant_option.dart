
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/products/product.dart';
import 'package:uuid/uuid.dart'; // ✅ 1. IMPORTE O PACOTE UUID

class VariantOption extends Equatable {
  // ✅ 2. ID ÚNICO GERADO PELO CLIENTE (APP)
  // Este ID é usado para identificar o widget na tela de forma estável.
  final String clientId;

  // --- Atributos que vêm da API ---
  final int? id; // ID que vem do banco de dados
  final int? variantId;
  final String? imagePath;
  final bool isActuallyAvailable;

  // --- Atributos que usamos localmente e enviamos para a API ---
  final String? name_override;
  final String? description;
  final int? price_override;
  final bool available;
  final String? pos_code;
  final int? linked_product_id;
  final Product? linkedProduct;
  final bool track_inventory;
  final int stock_quantity;
  final ImageModel? image;


  // ✅ CONSTRUTOR EMPTY ADICIONADO AQUI
  const VariantOption.empty()
      : clientId = '', // O ID do cliente será gerado no construtor principal se for nulo
        id = null,
        variantId = null,
        imagePath = null,
        isActuallyAvailable = true,
        name_override = '',
        description = '',
        price_override = 0,
        available = true,
        pos_code = null,
        linked_product_id = null,
        linkedProduct = null,
        track_inventory = false,
        stock_quantity = 0,
        image = null;












  VariantOption({
    String? clientId, // Permite passar um clientId se já existir (útil no copyWith)
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
  }) : clientId = clientId ?? const Uuid().v4(); // ✅ 3. GERA UM NOVO ID ÚNICO SE NENHUM FOR FORNECIDO

  // Getters (os seus já estavam perfeitos)
  String get resolvedName {
    if (name_override != null && name_override!.isNotEmpty) {
      return name_override!;
    }
    if (linkedProduct != null) {
      return linkedProduct!.name;
    }
    return "Item sem nome";
  }

  int get resolvedPrice {
    if (price_override != null) {
      return price_override!;
    }
    if (linkedProduct != null) {
      return linkedProduct?.price ?? 0;
    }
    return 0;
  }

  // fromJson e toJson (os seus já estavam bons, apenas adaptados)
  factory VariantOption.fromJson(Map<String, dynamic> json) {
    return VariantOption(
      id: json['id'],
      variantId: json['variant_id'],
      name_override: json['name_override'] ?? json['resolved_name'],
      description: json['description'],
      price_override: json['price_override'] ?? json['resolved_price'],
      available: json['available'] ?? true,
      pos_code: json['pos_code'],
      linked_product_id: json['linked_product_id'],
      linkedProduct: json['linked_product'] != null ? Product.fromJson(json['linked_product']) : null,
      track_inventory: json['track_inventory'] ?? false,
      stock_quantity: json['stock_quantity'] ?? 0,
      imagePath: json['image_path'],
      isActuallyAvailable: json['is_actually_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() { /* ... (seu toJson está ok) ... */
    return {
      if (id != null) 'id': id,
      if (variantId != null) 'variant_id': variantId,
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

  // ✅ 4. MÉTODO copyWith ATUALIZADO E COMPLETO
  VariantOption copyWith({
    int? id,
    int? variantId,
    String? imagePath,
    bool? isActuallyAvailable,
    String? name_override,
    String? description,
    int? price_override,
    bool? available,
    String? pos_code,
    int? linked_product_id,
    Product? linkedProduct, // Melhoria: adicionado
    bool? track_inventory,
    int? stock_quantity,
    ImageModel? image,
  }) {
    return VariantOption(
      clientId: clientId, // O mais importante: mantém o ID do cliente original
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
      linkedProduct: linkedProduct ?? this.linkedProduct, // Melhoria: adicionado
      track_inventory: track_inventory ?? this.track_inventory,
      stock_quantity: stock_quantity ?? this.stock_quantity,
      image: image ?? this.image,
    );
  }

  // ✅ 5. ADICIONE O clientId À LISTA DE PROPS
  @override
  List<Object?> get props => [
    clientId,
    id,
    variantId,
    name_override,
    description,
    price_override,
    available,
    pos_code,
    linked_product_id,
    track_inventory,
    stock_quantity,
    image,
    linkedProduct,
  ];
}