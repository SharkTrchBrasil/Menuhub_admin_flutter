import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/prodcut_category_links.dart';
import 'package:totem_pro_admin/models/product_default_option.dart';
import 'package:totem_pro_admin/models/product_rating.dart';
import 'package:totem_pro_admin/models/product_variant_link.dart';
import 'package:totem_pro_admin/models/flavor_price.dart';


import '../core/enums/beverage.dart';
import '../core/enums/cashback_type.dart';
import '../core/enums/foodtags.dart';
import '../core/enums/product_type.dart';
import '../widgets/app_selection_form_field.dart';
import 'category.dart';
import 'kit_component.dart';

class Product implements SelectableItem {
  final int? id;
  final String name;
  final String? description; // ✅ Tornado nullable
  final bool available;
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

  Product({
    this.id,
    this.name = '',
    this.description,
    this.available = true,
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
    final dietaryTagsSet = (json['dietary_tags'] as List<dynamic>? ?? [])
        .map((tagString) => FoodTag.values.byName(tagString.toLowerCase()))
        .toSet();

    final beverageTagsSet = (json['beverage_tags'] as List<dynamic>? ?? [])
        .map((tagString) => BeverageTag.values.byName(tagString.toLowerCase()))
        .toSet();

    return Product(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      available: json['available'] ?? true,
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
      dietaryTags: dietaryTagsSet,
      beverageTags: beverageTagsSet,
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
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    bool? available,
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
      available: available ?? this.available,
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
      'available': available,
      'product_type': productType.name.toUpperCase(),
      'stock_quantity': stockQuantity,
      'control_stock': controlStock,
      'master_product_id': masterProductId,
      'unit': unit,
      'weight': weight,
      'serves_up_to': servesUpTo,
      'dietary_tags': dietaryTags.map((tag) => tag.name.toUpperCase()).toList(),
      'beverage_tags': beverageTags.map((tag) => tag.name.toUpperCase()).toList(),
      'category_links': categoryLinks.map((link) => link.toJson()).toList(),
      'variant_links': (variantLinks ?? []).map((link) => link.toWizardJson()).toList(),
    };
  }

  Map<String, dynamic> toFlavorProductJson({required int parentCategoryId}) {
    return {
      'name': name,
      'description': description,
      'ean': ean,
      'available': available,
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
      'name': name,
      'description': description,
      'ean': ean,
      'available': available,
      'stock_quantity': stockQuantity,
      'control_stock': controlStock,
      'min_stock': minStock,
      'max_stock': maxStock,
      'unit': unit,
      'featured': featured,
      'priority': priority,
      'cashback_type': cashbackType.name,
      'cashback_value': cashbackValue,
      'dietary_tags': dietaryTags.map((tag) => tag.name).toList(),
      'beverage_tags': beverageTags.map((tag) => tag.name).toList(),
      'serves_up_to': servesUpTo,
      'weight': weight,
    };
  }

  @override
  String get title => name;
}