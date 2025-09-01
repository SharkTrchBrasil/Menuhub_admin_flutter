import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/prodcut_category_links.dart';

import 'package:totem_pro_admin/models/product_variant_link.dart';
import 'package:totem_pro_admin/widgets/app_selection_form_field.dart';
import '../core/enums/cashback_type.dart';
import '../core/enums/product_type.dart';
import 'category.dart';

class Product implements SelectableItem {
  final int? id;
  final String name;
  final String description;
  final bool available;
  final ImageModel? image;
  final String ean;

  // Estoque
  final int stockQuantity;
  final bool controlStock;
  final int minStock;
  final int maxStock;
  final String unit;

  // ✅ 1. NOVOS ATRIBUTOS ADICIONADOS
  final int priority;
  final bool featured;
  final String tag;
  final int sold_count;

  // Outros
  final List<ProductVariantLink>? variantLinks;
  final CashbackType cashbackType;
  final int cashbackValue;
  final ProductType productType;
  final List<ProductCategoryLink> categoryLinks;

  // Preço Primário (da API)
  final int price;
  final int? costPrice;
  final bool isOnPromotion;
  final int? promotionalPrice;

  // ✅ 2. CONSTRUTOR ATUALIZADO
  Product({
    this.id,
    this.name = '',
    this.description = '',
    this.available = true,
    this.image,
    this.ean = '',
    this.stockQuantity = 0,
    this.controlStock = false,
    this.minStock = 0,
    this.maxStock = 0,
    this.unit = '',
    this.priority = 0,
    this.featured = false,
    this.tag = '',
    this.sold_count = 0,
    this.variantLinks,
    this.cashbackType = CashbackType.none,
    this.cashbackValue = 0,
    this.productType = ProductType.INDIVIDUAL,
    this.categoryLinks = const [],
    required this.price,
    this.costPrice,
    this.isOnPromotion = false,
    this.promotionalPrice,
  });

  // ✅ 3. `FROMJSON` ATUALIZADO
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      available: json['available'],
      image:
          json['image_path'] != null
              ? ImageModel(url: json['image_path'])
              : null,
      ean: json['ean'] ?? '',
      stockQuantity: json['stock_quantity'] ?? 0,
      controlStock: json['control_stock'] ?? false,
      minStock: json['min_stock'] ?? 0,
      maxStock: json['max_stock'] ?? 0,
      unit: json['unit'] ?? '',
      priority: json['priority'] ?? 0,
      featured: json['featured'] ?? false,
      tag: json['tag'] ?? '',
      sold_count: json['sold_count'] ?? 0,
      cashbackType: CashbackType.fromString(json['cashback_type']),
      cashbackValue: json['cashback_value'] ?? 0,
      productType: ProductType.fromString(json['product_type']),
      price: json['price'],
      costPrice: json['cost_price'],
      isOnPromotion: json['is_on_promotion'] ?? false,
      promotionalPrice: json['promotional_price'],
      categoryLinks:
          (json['category_links'] as List<dynamic>? ?? [])
              .map((link) => ProductCategoryLink.fromJson(link))
              .toList(),
      variantLinks:
          (json['variant_links'] as List<dynamic>? ?? [])
              .map((link) => ProductVariantLink.fromJson(link))
              .toList(),
    );
  }


  Map<String, dynamic> toWizardJson() {
    // Contém APENAS os campos definidos no schema `ProductWizardCreate` do backend
    final productData = {
      'name': name.isNotEmpty ? name : 'Produto sem nome',
      'description': description,
      'ean': ean,
      'available': available,
      'product_type': productType.toApiString(),
      'stock_quantity': stockQuantity,
      'control_stock': controlStock,
    };

    // Mapeia os links de categoria e variantes
    final categoryLinksJson = categoryLinks.map((link) => link.toJson()).toList();
    final variantLinksJson = (variantLinks ?? []).map((link) => link.toWizardJson()).toList();

    // Junta tudo
    return {
      ...productData,
      'category_links': categoryLinksJson,
      'variant_links': variantLinksJson,
    };
  }

  // ✅ 4. `COPYWITH` ATUALIZADO
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
    String? tag,
    int? sold_count,
    ValueGetter<List<ProductVariantLink>?>? variantLinks,
    CashbackType? cashbackType,
    int? cashbackValue,
    ProductType? productType,
    ValueGetter<List<ProductCategoryLink>>? categoryLinks,
    int? price,
    int? costPrice,
    bool? isOnPromotion,
    int? promotionalPrice,
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
      tag: tag ?? this.tag,
      sold_count: sold_count ?? this.sold_count,
      variantLinks: variantLinks != null ? variantLinks() : this.variantLinks,
      cashbackType: cashbackType ?? this.cashbackType,
      cashbackValue: cashbackValue ?? this.cashbackValue,
      productType: productType ?? this.productType,
      categoryLinks:
          categoryLinks != null ? categoryLinks() : this.categoryLinks,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      isOnPromotion: isOnPromotion ?? this.isOnPromotion,
      promotionalPrice: promotionalPrice ?? this.promotionalPrice,
    );
  }


  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'description': description,
      'available': available,
      'ean': ean,
      'stock_quantity': stockQuantity,
      'control_stock': controlStock,
      'min_stock': minStock,
      'max_stock': maxStock,
      'unit': unit,
      'featured': featured,
      'tag': tag,
      'cashback_type': cashbackType.name,
      'cashback_value': cashbackValue,
    };
  }




  @override
  String get title => name;
}
