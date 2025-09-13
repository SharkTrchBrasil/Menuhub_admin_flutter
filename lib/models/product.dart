import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/prodcut_category_links.dart';
import 'package:totem_pro_admin/models/product_default_option.dart';
import 'package:totem_pro_admin/models/product_rating.dart';
import 'package:totem_pro_admin/models/product_variant_link.dart';
import 'package:totem_pro_admin/models/flavor_price.dart';


import '../core/enums/beverage.dart';
import '../core/enums/cashback_type.dart';
import '../core/enums/foodtags.dart';
import '../core/enums/product_status.dart';
import '../core/enums/product_type.dart';
import '../widgets/app_selection_form_field.dart';
import 'category.dart';
import 'kit_component.dart';

import 'package:equatable/equatable.dart';

// ✅ 1. ADICIONE 'extends Equatable' AQUI
class Product extends Equatable implements SelectableItem {

  final int? id;
  final String name;
  final String? description; // ✅ Tornado nullable
  final ProductStatus status;
  final ImageModel? image;
  final String? ean; // ✅ Tornado nullable
  final int stockQuantity;
  final bool controlStock;
  final int minStock;
  final int maxStock;
  final String unit;
  final int priority;
  final bool featured;
  final int storeId;
  final int? servesUpTo; // ✅ Novo campo
  final int? weight; // ✅ Novo campo (em gramas ou ml)
  final int soldCount;
  final List<ProductVariantLink>? variantLinks;
  final CashbackType cashbackType;
  final int cashbackValue;
  final ProductType productType;
  final List<ProductCategoryLink> categoryLinks;
  final int? price;
  final int? costPrice;
  final bool isOnPromotion;
  final int? promotionalPrice;
  final int? primaryCategoryId;
  final bool hasMultiplePrices;
  final Set<FoodTag> dietaryTags;
  final Set<BeverageTag> beverageTags;
  final int? masterProductId;
  final List<FlavorPrice> prices;
  final List<ProductDefaultOption>? defaultOptions; // ✅ Novo campo
  final List<KitComponent>? components; // ✅ Novo campo
  final List<ProductRating>? productRatings; // ✅ Novo campo
  final String? fileKey; // ✅ Novo campo

 const Product({
    this.id,
    this.name = '',
    this.description,
   this.status = ProductStatus.ACTIVE,
    this.image,
    this.ean,
    this.stockQuantity = 0,
    this.controlStock = false,
    this.minStock = 0,
    this.maxStock = 0,
    this.unit = 'Unidade',
    this.priority = 0,
    this.featured = false,
    this.storeId = 0,
    this.servesUpTo,
    this.weight,
    this.soldCount = 0,
    this.variantLinks,
    this.cashbackType = CashbackType.none,
    this.cashbackValue = 0,
    this.productType = ProductType.INDIVIDUAL,
    this.categoryLinks = const [],
    this.price,
    this.costPrice,
    this.isOnPromotion = false,
    this.promotionalPrice,
    this.primaryCategoryId,
    this.hasMultiplePrices = false,
    this.dietaryTags = const {},
    this.beverageTags = const {},
    this.masterProductId,
    this.prices = const [],
    this.defaultOptions,
    this.components,
    this.productRatings,
    this.fileKey,
  });

  factory Product.fromJson(Map<String, dynamic> json) {


    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      status: productStatusFromString(json['status']),
      image: json['image_path'] != null
          ? ImageModel(url: json['image_path'])
          : null,
      ean: json['ean'],
      stockQuantity: json['stock_quantity'] ?? 0,
      controlStock: json['control_stock'] ?? false,
      minStock: json['min_stock'] ?? 0,
      maxStock: json['max_stock'] ?? 0,
      unit: json['unit'] ?? 'Unidade',
      priority: json['priority'] ?? 0,
      featured: json['featured'] ?? false,
      storeId: json['store_id'] ?? 0,
      servesUpTo: json['serves_up_to'],
      weight: json['weight'],
      soldCount: json['sold_count'] ?? 0,
      cashbackType: CashbackType.fromString(json['cashback_type']),
      cashbackValue: json['cashback_value'] ?? 0,
      productType: ProductType.fromString(json['product_type']),
      price: json['price'],
      costPrice: json['cost_price'],
      isOnPromotion: json['is_on_promotion'] ?? false,
      promotionalPrice: json['promotional_price'],
      primaryCategoryId: json['primary_category_id'],
      hasMultiplePrices: json['has_multiple_prices'] ?? false,


      categoryLinks: (json['category_links'] as List<dynamic>? ?? [])
          .map((link) => ProductCategoryLink.fromJson(link))
          .toList(),
      variantLinks: (json['variant_links'] as List<dynamic>? ?? [])
          .map((link) => ProductVariantLink.fromJson(link))
          .toList(),
      prices: (json['prices'] as List<dynamic>? ?? [])
          .map((p) => FlavorPrice.fromJson(p))
          .toList(),
      masterProductId: json['master_product_id'],
      defaultOptions: (json['default_options'] as List<dynamic>? ?? [])
          .map((option) => ProductDefaultOption.fromJson(option))
          .toList(),
      components: (json['components'] as List<dynamic>? ?? [])
          .map((component) => KitComponent.fromJson(component))
          .toList(),
      productRatings: (json['product_ratings'] as List<dynamic>? ?? [])
          .map((rating) => ProductRating.fromJson(rating))
          .toList(),
      fileKey: json['file_key'],


      dietaryTags: (json['dietary_tags'] as List<dynamic>? ?? [])
          .map((tagString) => apiValueToFoodTag[tagString]) // Usa o mapa reverso
          .whereType<FoodTag>() // Filtra qualquer valor nulo se a API enviar uma tag desconhecida
          .toSet(),

      beverageTags: (json['beverage_tags'] as List<dynamic>? ?? [])
          .map((tagString) => apiValueToBeverageTag[tagString]) // Usa o mapa reverso
          .whereType<BeverageTag>() // Filtra nulos
          .toSet(),



    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    ProductStatus? status,
    ImageModel? image,
    String? ean,
    int? stockQuantity,
    bool? controlStock,
    int? minStock,
    int? maxStock,
    String? unit,
    int? priority,
    bool? featured,
    int? storeId,
    int? servesUpTo,
    int? weight,
    int? soldCount,
    List<ProductVariantLink>? variantLinks,
    CashbackType? cashbackType,
    int? cashbackValue,
    ProductType? productType,
    List<ProductCategoryLink>? categoryLinks,
    int? price,
    int? costPrice,
    bool? isOnPromotion,
    int? promotionalPrice,
    int? primaryCategoryId,
    bool? hasMultiplePrices,
    Set<FoodTag>? dietaryTags,
    Set<BeverageTag>? beverageTags,
    int? masterProductId,
    List<FlavorPrice>? prices,
    List<ProductDefaultOption>? defaultOptions,
    List<KitComponent>? components,
    List<ProductRating>? productRatings,
    String? fileKey,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      image: image ?? this.image,
      ean: ean ?? this.ean,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      controlStock: controlStock ?? this.controlStock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      unit: unit ?? this.unit,
      priority: priority ?? this.priority,
      featured: featured ?? this.featured,
      storeId: storeId ?? this.storeId,
      servesUpTo: servesUpTo ?? this.servesUpTo,
      weight: weight ?? this.weight,
      soldCount: soldCount ?? this.soldCount,
      variantLinks: variantLinks ?? this.variantLinks,
      cashbackType: cashbackType ?? this.cashbackType,
      cashbackValue: cashbackValue ?? this.cashbackValue,
      productType: productType ?? this.productType,
      categoryLinks: categoryLinks ?? this.categoryLinks,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      isOnPromotion: isOnPromotion ?? this.isOnPromotion,
      promotionalPrice: promotionalPrice ?? this.promotionalPrice,
      primaryCategoryId: primaryCategoryId ?? this.primaryCategoryId,
      hasMultiplePrices: hasMultiplePrices ?? this.hasMultiplePrices,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      beverageTags: beverageTags ?? this.beverageTags,
      masterProductId: masterProductId ?? this.masterProductId,
      prices: prices ?? this.prices,
      defaultOptions: defaultOptions ?? this.defaultOptions,
      components: components ?? this.components,
      productRatings: productRatings ?? this.productRatings,
      fileKey: fileKey ?? this.fileKey,
    );
  }

// ✅ toJson para o wizard de PRODUTOS SIMPLES, completo e corrigido
  Map<String, dynamic> toSimpleProductJson() {
    return {
      'name': name,
      'description': description,
      'ean': ean,
      'status': status.name,
      'product_type': productType.name.toUpperCase(),
      'stock_quantity': stockQuantity,
      'control_stock': controlStock,
      'master_product_id': masterProductId,
      'unit': unit,
      'weight': weight,
      'serves_up_to': servesUpTo,
      'dietary_tags': dietaryTags.map((tag) => foodTagNames[tag]!).toList(),
      'beverage_tags': beverageTags.map((tag) => beverageTagNames[tag]!).toList(),
      'category_links': categoryLinks.map((link) => link.toJson()).toList(),
      'variant_links': (variantLinks ?? []).map((link) => link.toWizardJson()).toList(),
    };
  }



  Map<String, dynamic> toFlavorProductJson({required int parentCategoryId}) {
    return {
      'name': name,
      'description': description,
      'ean': ean,
      'status': status.name,
      'product_type': ProductType.INDIVIDUAL.name,
      'stock_quantity': stockQuantity,
      'control_stock': controlStock,
      'dietary_tags': dietaryTags.map((tag) => tag.name).toList(),
      'beverage_tags': beverageTags.map((tag) => tag.name).toList(),
      'parent_category_id': parentCategoryId,
      'prices': prices.map((p) => p.toJson()).toList(),
    };
  }


  Map<String, dynamic> toUpdateJson() {
    return {
      // --- Dados Básicos (Aba "Sobre o Produto") ---
      'name': name,
      'description': description,
      'ean': ean,

      // --- Opções (Aba "Disponibilidade e Opções") ---
      'status': status.name,
      'featured': featured,
      'priority': priority, // ✅ Re-adicionado

      // --- Estoque ---
      'control_stock': controlStock,
      'stock_quantity': stockQuantity,
      'min_stock': minStock,
      'max_stock': maxStock,

      // --- Cashback ---
      'cashback_type': cashbackType.name,
      'cashback_value': cashbackValue,

      // --- Atributos ---
      'unit': unit,
      'weight': weight,
      'serves_up_to': servesUpTo,
      'dietary_tags': dietaryTags.map((tag) => foodTagNames[tag]!).toList(),
      'beverage_tags': beverageTags.map((tag) => beverageTagNames[tag]!).toList(),

      // --- ✅ VÍNCULOS (O mais importante que faltava) ---
      'category_links': categoryLinks.map((link) => link.toJson()).toList(),
      'variant_links': (variantLinks ?? []).map((link) => link.toWizardJson()).toList(),

      // --- ✅ Preços (para sabores de produtos customizáveis) ---
      'prices': prices.map((price) => price.toJson()).toList(),
    };
  }

  // ✅ 2. ADICIONE A LISTA 'props' COMPLETA
  @override
  List<Object?> get props => [
    id,
    name,
    description,
    status,
    image,
    ean,
    stockQuantity,
    controlStock,
    minStock,
    maxStock,
    unit,
    priority,
    featured,
    storeId,
    servesUpTo,
    weight,
    soldCount,
    variantLinks,
    cashbackType,
    cashbackValue,
    productType,
    categoryLinks,
    price,
    costPrice,
    isOnPromotion,
    promotionalPrice,
    primaryCategoryId,
    hasMultiplePrices,
    dietaryTags,
    beverageTags,
    masterProductId,
    prices,
    defaultOptions,
    components,
    productRatings,
    fileKey,
  ];

  @override
  String get title => name;
}