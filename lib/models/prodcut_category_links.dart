// ARQUIVO: lib/models/product_category_link.dart

import 'package:totem_pro_admin/models/category.dart';

class ProductCategoryLink {
  final Category category;

  // Dados de preço e promoção específicos deste link
  final int price;
  final int? costPrice;
  final bool isOnPromotion;
  final int? promotionalPrice;

  // Outros overrides que você definiu
  final bool isAvailable;
  final bool isFeatured;
  final int displayOrder;
  final String? posCode;

  ProductCategoryLink({
    required this.category,
    required this.price,
    this.costPrice,
    this.isOnPromotion = false,
    this.promotionalPrice,
    this.isAvailable = true,
    this.isFeatured = false,
    this.displayOrder = 0,
    this.posCode,
  });

  // ✅ --- MÉTODO COPYWITH ADICIONADO --- ✅
  ProductCategoryLink copyWith({
    Category? category,
    int? price,
    int? costPrice,
    bool? isOnPromotion,
    int? promotionalPrice,
    bool? isAvailable,
    bool? isFeatured,
    int? displayOrder,
    String? posCode,
  }) {
    return ProductCategoryLink(
      category: category ?? this.category,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      isOnPromotion: isOnPromotion ?? this.isOnPromotion,
      promotionalPrice: promotionalPrice ?? this.promotionalPrice,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      displayOrder: displayOrder ?? this.displayOrder,
      posCode: posCode ?? this.posCode,
    );
  }












  factory ProductCategoryLink.fromJson(Map<String, dynamic> json) {
    return ProductCategoryLink(
      category: Category.fromJson(json['category']),
      price: json['price'],
      costPrice: json['cost_price'],
      isOnPromotion: json['is_on_promotion'] ?? false,
      promotionalPrice: json['promotional_price'],
      isAvailable: json['is_available'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      displayOrder: json['display_order'] ?? 0,
      posCode: json['pos_code'],
    );
  }

  // Converte para o JSON que o wizard espera
  Map<String, dynamic> toJson() {
    return {
      'category_id': category.id,
      'price': price,
      'cost_price': costPrice,
      'is_on_promotion': isOnPromotion,
      'promotional_price': promotionalPrice,
      'is_available': isAvailable,
      'is_featured': isFeatured,
      'display_order': displayOrder,
      'pos_code': posCode,
    };
  }
}