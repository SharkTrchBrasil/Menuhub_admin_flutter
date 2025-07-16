import 'package:totem_pro_admin/models/product.dart';

class Coupon {
  Coupon({
    this.id,
    this.code = '',
    this.discountType = 'percentage',
    this.discountValue = 0,
    this.maxUses,
    this.used = 0,
    this.maxUsesPerCustomer,
    this.minOrderValue,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.onlyFirstPurchase = false,
    this.product,

  });

  final int? id;
  final String code;
  final String discountType; // 'percentage' ou 'fixed'
  final int discountValue; // sempre em centavos ou percentual
  final int? maxUses;
  final int used;
  final int? maxUsesPerCustomer;
  final int? minOrderValue;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final bool onlyFirstPurchase;
  final Product? product;


  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
    id: json['id'] as int?,
    code: json['code'] as String,
    discountType: json['discount_type'] as String,
    discountValue: json['discount_value'] as int,
    maxUses: json['max_uses'] as int?,
    used: json['used'] as int? ?? 0,
    maxUsesPerCustomer: json['max_uses_per_customer'] as int?,
    minOrderValue: json['min_order_value'] as int?,
    startDate: json['start_date'] != null
        ? DateTime.parse(json['start_date'] as String)
        : null,
    endDate: json['end_date'] != null
        ? DateTime.parse(json['end_date'] as String)
        : null,
    isActive: json['is_active'] as bool? ?? true,
    onlyFirstPurchase: json['only_first_purchase'] as bool? ?? false,
    product: json['product'] != null
        ? Product.fromJson(json['product'])
        : null,

  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount_type': discountType,
      'discount_value': discountValue,
      'max_uses': maxUses,
      'used': used,
      'max_uses_per_customer': maxUsesPerCustomer,
      'min_order_value': minOrderValue,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'only_first_purchase': onlyFirstPurchase,
      'product_id': product?.id,

    };
  }

  Coupon copyWith({
    int? id,
    String? code,
    String? discountType,
    int? discountValue,
    int? maxUses,
    int? used,
    int? maxUsesPerCustomer,
    int? minOrderValue,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? onlyFirstPurchase,
    Product? product,
    int? storeId,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      maxUses: maxUses ?? this.maxUses,
      used: used ?? this.used,
      maxUsesPerCustomer: maxUsesPerCustomer ?? this.maxUsesPerCustomer,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      onlyFirstPurchase: onlyFirstPurchase ?? this.onlyFirstPurchase,
      product: product ?? this.product,

    );
  }
}
