

enum UIDisplayMode { SINGLE, MULTIPLE, QUANTITY, UNKNOWN }


class VariantOption {
  final int? id;
  final int? variantId;

  // Estes são os nomes e preços "finais", calculados no backend.
  // Eles podem ser diferentes dos overrides se a opção estiver ligada a um produto.
  final String resolvedName;
  final int resolvedPrice;
  final String? imagePath;

  // Estes são os campos que enviamos para a API ao criar/editar.
  final String? name_override;
  final int? price_override;
  final bool available;
  final String? pos_code;
  final int? linked_product_id;

  // ✅ CONSTRUTOR CORRIGIDO E INTELIGENTE
  VariantOption({
    this.id,
    this.imagePath,
    this.name_override,
    this.price_override,
    this.available = true,
    this.pos_code,
    this.linked_product_id,
  this.variantId,

    // Parâmetros que vêm da API, mas que podemos deduzir ao criar
    String? resolvedName,
    int? resolvedPrice,
  })  : // Esta é a parte inteligente:
  // Se resolvedName não for passado, use name_override. Se nem esse existir, use um padrão.
        this.resolvedName = resolvedName ?? name_override ?? '',
  // Se resolvedPrice não for passado, use price_override. Se nem esse existir, use 0.
        this.resolvedPrice = resolvedPrice ?? price_override ?? 0;


  Map<String, dynamic> toJson() {
    return {
      'variant_id': variantId, // ✅ ADICIONE AO JSON
      'name_override': name_override,
      'price_override': price_override,
      'available': available,
      'pos_code': pos_code,
      'linked_product_id': linked_product_id,
    };
  }

  // ✅ ADICIONE ESTE MÉTODO COMPLETO DENTRO DA CLASSE
  VariantOption copyWith({
    int? id,
    int? variantId,
    String? resolvedName,
    int? resolvedPrice,
    String? imagePath,
    String? name_override,
    int? price_override,
    bool? available,
    String? pos_code,
    int? linked_product_id,
  }) {
    return VariantOption(
      id: id ?? this.id,
      variantId: variantId ?? this.variantId,
      resolvedName: resolvedName ?? this.resolvedName,
      resolvedPrice: resolvedPrice ?? this.resolvedPrice,
      imagePath: imagePath ?? this.imagePath,
      name_override: name_override ?? this.name_override,
      price_override: price_override ?? this.price_override,
      available: available ?? this.available,
      pos_code: pos_code ?? this.pos_code,
      linked_product_id: linked_product_id ?? this.linked_product_id,
    );
  }

  factory VariantOption.fromJson(Map<String, dynamic> json) {
    return VariantOption(
      id: json['id'],

      resolvedName: json['resolved_name'],
      resolvedPrice: json['resolved_price'],
      imagePath: json['image_path'],
      name_override: json['name_override'],
      price_override: json['price_override'],
      available: json['available'] ?? true,
      pos_code: json['pos_code'],
      linked_product_id: json['linked_product_id'],
    );
  }
}