import 'package:equatable/equatable.dart';

class ProductDefaultOption extends Equatable {
  final int productId;
  final int variantOptionId;

  const ProductDefaultOption({
    required this.productId,
    required this.variantOptionId,
  });

  factory ProductDefaultOption.fromJson(Map<String, dynamic> json) {
    return ProductDefaultOption(
      productId: json['product_id'],
      variantOptionId: json['variant_option_id'],
    );
  }

  @override
  List<Object?> get props => [productId, variantOptionId];
}