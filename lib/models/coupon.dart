import 'package:totem_pro_admin/models/product.dart';

class Coupon {
  Coupon({
    this.id,
    this.maxUsesPerCustomer,
    this.minOrderValue,
    this.code = '',
    this.product,
    this.discountPercent,
    this.discountFixed,
    this.maxUses,
    this.used = 0,
    this.startDate,
    this.endDate,
    this.available = true,
    this.onlyNewCustomers = false,
  });

  final int? id;
  final String code;
  final Product? product;
  final int? discountPercent;
  final int? discountFixed;
  final int? maxUses;
  final int? maxUsesPerCustomer;
  final int? minOrderValue;
  final int used;
  final bool available;
  final bool onlyNewCustomers;
  final DateTime? startDate;
  final DateTime? endDate;

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
    id: json['id'] as int,
    code: json['code'] as String,
    minOrderValue: json['minOrderValue'] as int?,
    maxUsesPerCustomer: json['maxUsesPerCustomer'] as int?,



   product: json['product'] != null ? Product.fromJson(json['product']) : null,
    discountPercent: json['discount_percent'] as int?,
    discountFixed: json['discount_fixed'] as int?,
    maxUses: json['max_uses'] as int,
    used: json['used'] as int,
    available: json['available'] as bool,
    onlyNewCustomers: json['onlyNewCustomers'] as bool,
    startDate: DateTime.parse(json['start_date'] as String),
    endDate: DateTime.parse(json['end_date'] as String),
  );

  Coupon copyWith({
    int? id,
    String? code,
    Product? product,
    int? discountPercent,
    int? discountFixed,
    int? minOrderValue,
    int? maxUses,
    int? maxUsesPerCustomer,
    DateTime? startDate,
    DateTime? endDate,
    bool? available,
    bool? onlyNewCustomers,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      product: product ?? this.product,
      discountPercent: discountPercent ?? this.discountPercent,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      maxUsesPerCustomer: maxUsesPerCustomer ?? this.maxUsesPerCustomer,
      discountFixed: discountFixed ?? this.discountFixed,
      maxUses: maxUses ?? this.maxUses,
      used: used,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      available: available ?? this.available,
      onlyNewCustomers: onlyNewCustomers ?? this.onlyNewCustomers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'maxUsesPerCustomer': maxUsesPerCustomer,
      'minOrderValue': minOrderValue,
      'product_id': product?.id,
      'discount_percent': discountPercent != 0 ? discountPercent : null,
      'discount_fixed': discountFixed != 0 ? discountFixed : null,
      'max_uses': maxUses,
      'start_date': startDate!.toIso8601String(),
      'end_date': endDate!.toIso8601String(),
      'available': available,
      'onlyNewCustomers': onlyNewCustomers,
    };
  }
}
