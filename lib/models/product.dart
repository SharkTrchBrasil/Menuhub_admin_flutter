import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:totem_pro_admin/models/image_model.dart';
import 'package:totem_pro_admin/models/variant.dart';

import 'package:totem_pro_admin/widgets/app_selection_form_field.dart';

import 'category.dart';

class Product implements SelectableItem {
  Product({
    this.id,
    this.category,
    this.promotionPrice,
    this.featured = false,
    this.activatePromotion = false,
    this.name = '',
    this.description = '',
    this.basePrice,
    this.costPrice,
    this.available = true,
    this.image,
    this.ean = '',

    this.stockQuantity = 0,
    this.controlStock = false,
    this.minStock = 0,
    this.maxStock = 0,
    this.unit = '',

    this.variants, // Certifique-se de que `variants` está sendo recebido/passado corretamente
  });

  final int? id;
  final String name;
  final String description;
  final int? basePrice;
  final int? costPrice;
  final int? promotionPrice;
  final bool featured;
  final bool activatePromotion;
  final bool available;

  final Category? category;

  final ImageModel? image;

  final String ean;

  final int stockQuantity;
  final bool controlStock;
  final int minStock;
  final int maxStock;
  final String unit;

  final List<Variant>? variants; // Se `variants` for ProductVariant, certifique-se de mapear para IDs

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      category: Category.fromJson(json['category']),
      name: json['name'],
      description: json['description'],
      basePrice: json['base_price'],
      costPrice: json['cost_price'],
      available: json['available'],
      promotionPrice: json['promotion_price'],
      activatePromotion: json['activate_promotion'],
      featured: json['featured'],

      image: ImageModel(url: json['image_path']),
      ean: json['ean'] ?? '',

      stockQuantity: json['stock_quantity'] ?? 0,
      controlStock: json['control_stock'] ?? false,
      minStock: json['min_stock'] ?? 0,
      maxStock: json['max_stock'] ?? 0,
      unit: json['unit'] ?? '',

      variants: (json['variants'] as List)
          .map((variant) => Variant.fromJson(variant))
          .toList(),

      // variantss: (json['variants'] != null)
      //     ? (json['variants'] as List)
      //     .map((variant) => Variant.fromJson(variant))
      //     .toList()
      //     : [], // ou null, dependendo do seu modelo
    );
  }

  Product copyWith({
    String? name,
    String? description,
    int? basePrice,
    int? costPrice,
    bool? available,
    int? promotionPrice,
    bool? featured,
    bool? activatePromotion,
    ValueGetter<Category?>? category,

    ImageModel? image,
    String? ean,

    int? stockQuantity,
    bool? controlStock,
    int? minStock,
    int? maxStock,
    String? unit,

    ValueGetter<List<Variant>?>? variants, // Adicionado para copyWith
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      basePrice: basePrice ?? this.basePrice,
      costPrice: costPrice ?? this.costPrice,
      available: available ?? this.available,
      category: category != null ? category() : this.category,
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
      variants: variants != null ? variants() : this.variants, // Usando ValueGetter para variantes
    );
  }


  Future<FormData> toFormData() async {
    final formData = FormData();

    final formDataMap = <String, dynamic>{
      'name': name,
      'description': description,
      'base_price': basePrice,
      'cost_price': costPrice ?? 0,
      'promotion_price': promotionPrice ?? 0,
      'featured': featured,
      'activate_promotion': activatePromotion,
      'available': available,
      'category_id': category?.id,
      'ean': ean,
      'stock_quantity': stockQuantity,
      'control_stock': controlStock,
      'min_stock': minStock,
      'max_stock': maxStock,
      'unit': unit,

    };

    // Adiciona os campos normais no formData
    formDataMap.forEach((key, value) {
      if (value != null) {
        formData.fields.add(MapEntry(key, value.toString()));
      }
    });

    // Adiciona os variant_ids, se houver
    if (variants != null && variants!.isNotEmpty) {
      for (final variant in variants!) {
        if (variant.id != null) {
          formData.fields.add(MapEntry('variant_ids', variant.id.toString()));
        }
      }
    }

    // Adiciona o arquivo de imagem
    if (image?.file != null) {
      formData.files.add(
        MapEntry(
          'image',
          MultipartFile.fromBytes(
            await image!.file!.readAsBytes(),
            filename: image!.file!.name,
          ),
        ),
      );
    }

    // Debug
    debugPrint('--- FormData Content ---');
    for (final field in formData.fields) {
      debugPrint('${field.key}: ${field.value}');
    }
    for (final file in formData.files) {
      debugPrint('${file.key}: <MultipartFile>');
    }
    debugPrint('------------------------');

    return formData;
  }




  @override
  String get title => name;
}