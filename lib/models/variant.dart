import 'package:totem_pro_admin/models/product_variant_link.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:equatable/equatable.dart';
import '../core/enums/variant_type.dart';


class Variant extends Equatable {
  final int? id;
  final String name;
  final VariantType type;
  final List<VariantOption> options;
  final List<ProductVariantLink>? productLinks;
  final bool available;
  final List<ProductVariantLink>? linkedProductsRules;

  // ✅ 3. ADICIONE O CONSTRUTOR EMPTY
  const Variant.empty()
      : id = 0, // ou null, dependendo da sua lógica de "novo item"
        name = '',
        type = VariantType.INGREDIENTS, // Um padrão seguro
        options = const [],
        productLinks = const [],
        available = true,
        linkedProductsRules = null;

  const Variant({
    this.id,
    required this.name,
    required this.type,
    required this.options,
    this.productLinks,
    this.available = true,
    this.linkedProductsRules,
  });

  // O método copyWith continua o mesmo
  Variant copyWith({
    int? id,
    String? name,
    VariantType? type,
    List<VariantOption>? options,
    List<ProductVariantLink>? productLinks,
    bool? available,
    List<ProductVariantLink>? linkedProductsRules,
  }) {
    return Variant(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      options: options ?? this.options,
      productLinks: productLinks ?? this.productLinks,
      available: available ?? this.available,
      linkedProductsRules: linkedProductsRules ?? this.linkedProductsRules,
    );
  }



  factory Variant.fromJson(Map<String, dynamic> json) {
    VariantType typeFromString(String? typeStr) {
      // ... (sua lógica de mapeamento de tipo)
      switch (typeStr) {
        case "Ingredientes":
          return VariantType.INGREDIENTS;
        case "Especificações":
          return VariantType.SPECIFICATIONS;
        case "Cross-sell":
          return VariantType.CROSS_SELL;
        case "Descartáveis":
          return VariantType.DISPOSABLES;
        default:
          return VariantType.UNKNOWN;
      }
    }

    return Variant(
      id: json['id'],
      name: json['name'],
      type: typeFromString(json['type']),
      available: json['is_available'] ?? true, // ✅ 4. LENDO DO JSON (com fallback)
      options: (json['options'] as List? ?? [])
          .map((optionJson) => VariantOption.fromJson(optionJson))
          .toList(),
      productLinks: (json['product_links'] as List? ?? [])
          .map((linkJson) => ProductVariantLink.fromJson(linkJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    String typeToString(VariantType type) {
      // ... (sua lógica de mapeamento de tipo)
      switch (type) {
        case VariantType.INGREDIENTS:
          return "Ingredientes";
        case VariantType.SPECIFICATIONS:
          return "Especificações";
        case VariantType.CROSS_SELL:
          return "Cross-sell";
        case VariantType.DISPOSABLES:
          return "Descartáveis";
        default:
          return "";
      }
    }

    return {

      if (id != null && id! > 0) 'id': id,
      'name': name,
      'type': typeToString(type),
      // No backend, o campo é `is_available`
      'is_available': available,

      // Serializa a lista de opções da "Tab 1"
      'options': options.map((option) => option.toJson()).toList(),


      if (linkedProductsRules != null)
        'linked_products_rules': linkedProductsRules!
            .map((link) => link.toJsonForRuleUpdate())
            .toList(),
    };
  }



  Map<String, dynamic> toJsonForLink() {
    String typeToString(VariantType type) {
      // ... (sua lógica de mapeamento de tipo)
      switch (type) {
        case VariantType.INGREDIENTS:
          return "Ingredientes";
        case VariantType.SPECIFICATIONS:
          return "Especificações";
        case VariantType.CROSS_SELL:
          return "Cross-sell";
        case VariantType.DISPOSABLES:
          return "Descartáveis";
        default:
          return "";
      }
    }

    return {
      // A única diferença é esta linha:
      'id': id,

      'name': name,
      'type': typeToString(type),
      'options': options.map((option) => option.toJson()).toList(),
    };
  }


  Map<String, dynamic> toWizardJson() {
    return {
      'name': name,
      'type': type.toApiString(),
      'is_available': available, // ✅ 6. ADICIONADO AQUI TAMBÉM
      'options': options.map((opt) {
        return {
          'name_override': opt.name_override,
          'description': opt.description,
          'price_override': opt.price_override,
          'available': opt.available,
          'pos_code': opt.pos_code,
          'linked_product_id': opt.linked_product_id,
          'track_inventory': opt.track_inventory,
          'stock_quantity': opt.stock_quantity,
        };
      }).toList(),
    };
  }





  @override
  List<Object?> get props => [
    id,
    name,
    type,
    options,
    productLinks,
    available,
    linkedProductsRules,
  ];


}