import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/products/product.dart';
import 'package:equatable/equatable.dart';

class ProductCategoryLink extends Equatable {
  final int? productId;
  final int categoryId;
  final Product? product;
  final Category? category;

  final int price;
  final int? costPrice;
  final bool isOnPromotion;
  final int? promotionalPrice;
  final bool isAvailable;
  final bool isFeatured;
  final int displayOrder;
  final String? posCode;
  final int? optionItemId; // ✅ NOVO CAMPO


  ProductCategoryLink({
    this.productId,
    required this.categoryId,
     this.product,
     this.category,
    required this.price,
    this.costPrice,
    this.isOnPromotion = false,
    this.promotionalPrice,
    this.isAvailable = true,
    this.isFeatured = false,
    this.displayOrder = 0,
    this.posCode,
    this.optionItemId,
  });

  // ✨ --- MÉTODO COPYWITH CORRIGIDO E COMPLETO --- ✨
  ProductCategoryLink copyWith({
    int? productId,
    int? categoryId,
    Product? product,
    Category? category,
    int? price,
    int? costPrice,
    bool? isOnPromotion,
    int? promotionalPrice,
    bool? isAvailable,
    bool? isFeatured,
    int? displayOrder,
    String? posCode,
    int? optionItemId,
  }) {
    return ProductCategoryLink(
      // Se um novo valor for passado, use-o; senão, use o valor antigo (this. ...).
      productId: productId ?? this.productId,
      categoryId: categoryId ?? this.categoryId,
      product: product ?? this.product,
      category: category ?? this.category,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      isOnPromotion: isOnPromotion ?? this.isOnPromotion,
      promotionalPrice: promotionalPrice ?? this.promotionalPrice,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      displayOrder: displayOrder ?? this.displayOrder,
      posCode: posCode ?? this.posCode,
      optionItemId: optionItemId ?? this.optionItemId,
    );
  }

  // ✨ ALTERAÇÃO 2: A correção principal está aqui, no fromJson
  factory ProductCategoryLink.fromJson(Map<String, dynamic> json) {
    // Permite que o JSON do produto seja nulo
    final productJson = json['product'] as Map<String, dynamic>?;
    Map<String, dynamic>? fullProductJson;

    // Só monta o JSON completo se o produto não for nulo
    if (productJson != null) {
      fullProductJson = {
        ...productJson,
        'price': json['price'],
        'cost_price': json['cost_price'],
        'is_on_promotion': json['is_on_promotion'],
        'promotional_price': json['promotional_price'],
        'category_links': [],
      };
    }

    return ProductCategoryLink(
      productId: json['product_id'],
      categoryId: json['category_id'],

      // ✅ VERIFICAÇÃO DE NULO: Só chama .fromJson se o objeto não for nulo
      product: fullProductJson != null ? Product.fromJson(fullProductJson) : null,

      category: json['category'] != null
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,

      price: json['price'] ?? 0, // Adiciona um fallback para o preço
      costPrice: json['cost_price'],
      isOnPromotion: json['is_on_promotion'] ?? false,
      promotionalPrice: json['promotional_price'],
      isAvailable: json['is_available'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      displayOrder: json['display_order'] ?? 0,
      posCode: json['pos_code'],
    );
  }


// Em prodcut_category_links.dart

  Map<String, dynamic> toJson() {
    return {
      'product_id': product?.id, // ✅ Adicionado
      'category_id': categoryId,
      'price': price,
      'cost_price': costPrice,
      'is_on_promotion': isOnPromotion,
      'promotional_price': promotionalPrice,
      'is_available': isAvailable,
      'is_featured': isFeatured,
      'display_order': displayOrder,
      'pos_code': posCode,
      'option_item_id': optionItemId, // ✅ Adicionado
    };
  }

  @override
  List<Object?> get props => [
    productId,
    categoryId,
    product,
    category,
    price,
    costPrice,
    isOnPromotion,
    promotionalPrice,
    isAvailable,
    isFeatured,
    displayOrder,
    posCode,
    optionItemId,
  ]; // ✅ Lista de props completa
}