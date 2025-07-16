import 'package:totem_pro_admin/models/order_product_variant.dart';
import 'package:totem_pro_admin/models/image_model.dart';

class OrderProduct {
  final int id;
  final String name;
  final String note;
  final int quantity;
  final List<OrderProductVariant> variants;
  final int price;

  final int originalPrice;
  final int discountAmount;
  final double? discountPercentage;
  final Map<String, dynamic>? appliedDiscounts;

  final ImageModel? image;

  OrderProduct({
    required this.id,
    required this.name,
    required this.quantity,
    required this.variants,
    required this.note,
    required this.price,
    // Novos campos
    this.image,
    required this.originalPrice,
    required this.discountAmount,
    this.discountPercentage,
    this.appliedDiscounts,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> map) {
    return OrderProduct(
      id: map['id'] as int,
      name: map['name'] as String,
      note: map['note'] as String,
      quantity: map['quantity'] as int,
      variants: (map['variants'] as List<dynamic>)
          .map<OrderProductVariant>((c) => OrderProductVariant.fromJson(c))
          .toList(),
      price: map['price'] as int,
      // Novos campos
      image: ImageModel(url: map['image_url']),
      originalPrice: map['original_price'] as int? ?? map['price'] as int,
      discountAmount: map['discount_amount'] as int? ?? 0,
      discountPercentage: map['discount_percentage']?.toDouble(),
      appliedDiscounts: map['applied_discounts'] != null
          ? Map<String, dynamic>.from(map['applied_discounts'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'variants': variants.map((v) => v.toJson()).toList(),
      'note': note,
      'price': price,
      // Novos campos
      'image_url': image,

      'original_price': originalPrice,
      'discount_amount': discountAmount,
      'discount_percentage': discountPercentage,
      'applied_discounts': appliedDiscounts,
    };
  }
}