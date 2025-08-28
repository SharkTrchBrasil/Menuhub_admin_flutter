import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' hide Category;

import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/product_variant_link.dart';
import 'package:totem_pro_admin/models/variant.dart';
import 'package:totem_pro_admin/widgets/app_selection_form_field.dart';


import '../core/enums/cashback_type.dart';
import '../core/enums/product_type.dart';

import 'category.dart';


// ✅ CLASSE AUXILIAR PARA O VÍNCULO PRODUTO <-> CATEGORIA
// Representa a tabela de junção `product_category_links`
class ProductCategoryLink {
  final Category category;
  final int? priceOverride;
  final String? posCodeOverride;
  final bool? availableOverride;

  ProductCategoryLink({
    required this.category,
    this.priceOverride,
    this.posCodeOverride,
    this.availableOverride,
  });

  // ✅ MÉTODO `copyWith` QUE ESTAVA FALTANDO
  ProductCategoryLink copyWith({
    Category? category,
    int? priceOverride,
    String? posCodeOverride,
    bool? availableOverride,
  }) {
    return ProductCategoryLink(
      category: category ?? this.category,
      priceOverride: priceOverride ?? this.priceOverride,
      posCodeOverride: posCodeOverride ?? this.posCodeOverride,
      availableOverride: availableOverride ?? this.availableOverride,
    );
  }

  factory ProductCategoryLink.fromJson(Map<String, dynamic> json) {
    return ProductCategoryLink(
      category: Category.fromJson(json['category']),
      priceOverride: json['price_override'],
      posCodeOverride: json['pos_code_override'],
      availableOverride: json['available_override'],
    );
  }
}


class Product implements SelectableItem {
  final int? id;
  final String name;
  final String description;
  final int? basePrice;
  final int? costPrice;
  final int? promotionPrice;
  final bool featured;
  final bool activatePromotion;
  final bool available;
  final ImageModel? image;
  final String ean;
  final int stockQuantity;
  final bool controlStock;
  final int minStock;
  final int maxStock;
  final String unit;
  final List<ProductVariantLink>? variantLinks;
  final CashbackType cashbackType;
  final int cashbackValue;
  final ProductType productType;

  // ✅ ATUALIZADO: `category` foi substituído por `categoryLinks`
  final List<ProductCategoryLink> categoryLinks;

  Product({
    this.id,
    this.name = '',
    this.description = '',
    this.basePrice,
    this.costPrice,
    this.promotionPrice,
    this.featured = false,
    this.activatePromotion = false,
    this.available = true,
    this.image,
    this.ean = '',
    this.stockQuantity = 0,
    this.controlStock = false,
    this.minStock = 0,
    this.maxStock = 0,
    this.unit = '',
    this.variantLinks,
    this.cashbackType = CashbackType.none,
    this.cashbackValue = 0,
    this.productType = ProductType.INDIVIDUAL,
    this.categoryLinks = const [], // ✅ ADICIONADO
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      basePrice: json['base_price'],
      costPrice: json['cost_price'],
      available: json['available'],
      promotionPrice: json['promotion_price'],
      activatePromotion: json['activate_promotion'],
      featured: json['featured'],
      image: json['image_path'] != null ? ImageModel(url: json['image_path']) : null,
      ean: json['ean'] ?? '',
      stockQuantity: json['stock_quantity'] ?? 0,
      controlStock: json['control_stock'] ?? false,
      minStock: json['min_stock'] ?? 0,
      maxStock: json['max_stock'] ?? 0,
      unit: json['unit'] ?? '',
      cashbackType: CashbackType.fromString(json['cashback_type']),
      cashbackValue: json['cashback_value'] ?? 0,
      productType: ProductType.fromString(json['product_type']),

      // ✅ ATUALIZADO: Lê a lista de `category_links` em vez de um `category` único
      categoryLinks: (json['category_links'] as List<dynamic>? ?? [])
          .map((link) => ProductCategoryLink.fromJson(link))
          .toList(),

      variantLinks: (json['variant_links'] as List<dynamic>? ?? [])
          .map((link) => ProductVariantLink.fromJson(link))
          .toList(),
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? description,
    int? basePrice,
    int? costPrice,
    bool? available,
    int? promotionPrice,
    bool? featured,
    bool? activatePromotion,
    ImageModel? image,
    String? ean,
    int? stockQuantity,
    bool? controlStock,
    int? minStock,
    int? maxStock,
    String? unit,
    ValueGetter<List<ProductVariantLink>?>? variantLinks,
    CashbackType? cashbackType,
    int? cashbackValue,
    ProductType? productType,
    // ✅ ATUALIZADO: Permite atualizar a lista de `categoryLinks`
    ValueGetter<List<ProductCategoryLink>>? categoryLinks,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      costPrice: costPrice ?? this.costPrice,
      available: available ?? this.available,
      promotionPrice: promotionPrice ?? this.promotionPrice,
      featured: featured ?? this.featured,
      activatePromotion: activatePromotion ?? this.activatePromotion,
      image: image ?? this.image,
      ean: ean ?? this.ean,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      controlStock: controlStock ?? this.controlStock,
      minStock: minStock ?? this.minStock,
      maxStock: maxStock ?? this.maxStock,
      unit: unit ?? this.unit,
      variantLinks: variantLinks != null ? variantLinks() : this.variantLinks,
      cashbackType: cashbackType ?? this.cashbackType,
      cashbackValue: cashbackValue ?? this.cashbackValue,
      productType: productType ?? this.productType,
      categoryLinks: categoryLinks != null ? categoryLinks() : this.categoryLinks,
    );
  }

  /// ✅ NOVO: Gera o JSON para a rota de criação do Wizard (`/wizard`)
  Map<String, dynamic> toWizardJson() {
    return {
      // Campos do ProductBase
      'name': name,
      'description': description,
      'base_price': basePrice,
      'cost_price': costPrice,
      'ean': ean,
      'available': available,
      'product_type': productType.toApiString(),
      'stock_quantity': stockQuantity,
      'control_stock': controlStock,

      // Lista de ProductCategoryLinkCreate
      'category_links': categoryLinks.map((link) => {
        'category_id': link.category.id,
        'price_override': link.priceOverride,
        'pos_code_override': link.posCodeOverride,
      }).toList(),

      // Lista de ProductVariantLinkCreate
      'variant_links': variantLinks?.map((link) {
        final newVariantData = (link.variant.id ?? 0) < 0
            ? {
          'name': link.variant.name,
          'type': link.variant.type.toApiString(),
          'options': link.variant.options.map((opt) => {
            'name_override': opt.name_override,
            'price_override': opt.price_override,
            'pos_code': opt.pos_code,
            'available': opt.available,
          }).toList(),
        }
            : null;

        return {
          'variant_id': link.variant.id,
          'min_selected_options': link.minSelectedOptions,
          'max_selected_options': link.maxSelectedOptions,
          'new_variant_data': newVariantData,
        };
      }).toList(),
    };
  }

  /// ✅ ATUALIZADO: Agora usado apenas para o PATCH (não envia mais categorias)
  Future<FormData> toFormData() async {
    final formData = FormData();

    final formDataMap = <String, dynamic>{
      'name': name,
      'description': description,
      'base_price': basePrice,
      'cost_price': costPrice,
      'promotion_price': promotionPrice,
      'featured': featured,
      'activate_promotion': activatePromotion,
      'available': available,
      'ean': ean,
      'stock_quantity': stockQuantity,
      'control_stock': controlStock,
      'min_stock': minStock,
      'max_stock': maxStock,
      'unit': unit,
      'cashback_type': cashbackType.name,
      'cashback_value': cashbackValue,
    };

    formDataMap.forEach((key, value) {
      if (value != null) {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    if (image?.file != null) {
      final fileBytes = kIsWeb
          ? await image!.file!.readAsBytes()
          : await File(image!.file!.path).readAsBytes();
      formData.files.add(
        MapEntry(
          'image',
          MultipartFile.fromBytes(fileBytes, filename: image!.file!.name),
        ),
      );
    }
    return formData;
  }

  @override
  String get title => name;
}