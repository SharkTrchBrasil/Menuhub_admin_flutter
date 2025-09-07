import 'package:equatable/equatable.dart';

class ProductRating extends Equatable {
  final int id;
  final int stars;
  final String? comment;
  final int customerId;
  final int orderId;
  final int productId;
  final bool isActive;
  final String? ownerReply;

  const ProductRating({
    required this.id,
    required this.stars,
    this.comment,
    required this.customerId,
    required this.orderId,
    required this.productId,
    required this.isActive,
    this.ownerReply,
  });

  factory ProductRating.fromJson(Map<String, dynamic> json) {
    return ProductRating(
      id: json['id'],
      stars: json['stars'],
      comment: json['comment'],
      customerId: json['customer_id'],
      orderId: json['order_id'],
      productId: json['product_id'],
      isActive: json['is_active'],
      ownerReply: json['owner_reply'],
    );
  }

  @override
  List<Object?> get props => [id, stars, comment, customerId, orderId, productId, isActive, ownerReply];
}