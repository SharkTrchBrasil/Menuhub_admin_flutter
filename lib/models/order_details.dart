import 'order_print_log.dart';
import 'order_product.dart';

class OrderStatuses {
  static const String pending = 'pending';
  static const String preparing = 'preparing';
  static const String ready = 'ready';
  static const String canceled = 'canceled';
  static const String onRoute = 'on_route';
  static const String delivered = 'delivered';
}

class OrderDetails {
  final int id;
  final int sequentialId;
  final String publicId;
  final String? observation;
  final int storeId;
  final int? customerId;


  final int discountedTotalPrice;
  final int? deliveryFee;
  final int? changeAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String customerName;
  final String customerPhone;
  final String paymentMethodName;
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String city;
  final String? attendantName;
  final String orderType;
  final String deliveryType;
  final int totalPrice;
  final String paymentStatus;
  final String orderStatus;
  final int? totemId;
  final int? paymentMethodId;
  final List<OrderProduct> products;
  final DateTime? scheduledFor;
  final bool isScheduled;
  final String consumptionType;
  final bool needsChange;

  // Novos campos
  final int discountAmount;
  final double? discountPercentage;
  final String? discountType;
  final String? discountReason;
  final int subtotalPrice;
  final int? couponId;
  final String? couponCode;

  final int? customerOrderCount;

  // ✅ 2. Adicione a lista de logs de impressão como uma propriedade
  final List<OrderPrintLog> printLogs;


  OrderDetails({
    required this.id,
    required this.sequentialId,
    required this.publicId,
    this.observation,
    required this.storeId,
    required this.customerId,
    required this.discountedTotalPrice,
    required this.createdAt,
    required this.updatedAt,
    required this.customerName,
    required this.customerPhone,
    required this.paymentMethodName,
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.city,
    this.attendantName,
    required this.orderType,
    required this.deliveryType,
    required this.totalPrice,
    required this.paymentStatus,
    required this.orderStatus,
    this.totemId,
    this.paymentMethodId,
    required this.products,
    this.deliveryFee,
    this.scheduledFor,
    this.isScheduled = false,
    this.consumptionType = 'dine_in',
    this.changeAmount,
    required this.needsChange,
    // Novos campos
    required this.discountAmount,
    this.discountPercentage,
    this.discountType,
    this.discountReason,
    required this.subtotalPrice,
    this.couponId,
    this.couponCode,
    this.customerOrderCount,
    required this.printLogs, // ✅ 3. Adicione ao construtor
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['id'] as int,
      sequentialId: json['sequential_id'] as int,
      publicId: json['public_id'] as String,
      storeId: json['store_id'] as int,
      customerId: json['customer_id'] as int?,
      discountedTotalPrice: json['discounted_total_price'] as int,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      paymentMethodName: json['payment_method_name'] as String,
      street: json['street'] as String,
      number: json['number'] as String,
      complement: json['complement'],
      neighborhood: json['neighborhood'] as String,
      city: json['city'] as String,
      attendantName: json['attendant_name'],
      orderType: json['order_type'] as String,
      deliveryType: json['delivery_type'] as String,
      observation: json['observation'],
      totalPrice: json['total_price'] as int,
      paymentStatus: json['payment_status'] as String,
      orderStatus: json['order_status'] as String,
      totemId: json['totem_id'],
      paymentMethodId: json['payment_method_id'],
      products: (json['products'] as List<dynamic>)
          .map((product) => OrderProduct.fromJson(product as Map<String, dynamic>))
          .toList(),
      deliveryFee: json['delivery_fee'],
      changeAmount: json['change_amount'],
      scheduledFor: json['scheduled_for'] != null
          ? DateTime.parse(json['scheduled_for'] as String).toLocal()
          : null,
      isScheduled: json['is_scheduled'] as bool? ?? false,
      consumptionType: json['consumption_type'] as String? ?? 'dine_in',
      needsChange: json['needs_change'] as bool,
      // Novos campos
      discountAmount: json['discount_amount'] as int? ?? 0,
      discountPercentage: json['discount_percentage']?.toDouble(),
      discountType: json['discount_type'],
      discountReason: json['discount_reason'],
      subtotalPrice: json['subtotal_price'] as int? ?? json['total_price'] as int,
      couponId: json['coupon_id'],
      couponCode: json['coupon_code'],
      customerOrderCount: json['customer_order_count'] as int?,
      // ✅ 4. Adicione a lógica de parsing para a nova lista
      printLogs: (json['print_logs'] as List<dynamic>? ?? [])
          .map((log) => OrderPrintLog.fromJson(log as Map<String, dynamic>))
          .toList(),

    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sequential_id': sequentialId,
      'public_id': publicId,
      'store_id': storeId,
      'customer_id': customerId,
      'discounted_total_price': discountedTotalPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'payment_method_name': paymentMethodName,
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'attendant_name': attendantName,
      'order_type': orderType,
      'delivery_type': deliveryType,
      'observation': observation,
      'total_price': totalPrice,
      'payment_status': paymentStatus,
      'order_status': orderStatus,
      'totem_id': totemId,
      'payment_method_id': paymentMethodId,
      'products': products.map((p) => p.toJson()).toList(),
      'delivery_fee': deliveryFee,
      'change_amount': changeAmount,
      'scheduled_for': scheduledFor?.toIso8601String(),
      'is_scheduled': isScheduled,
      'consumption_type': consumptionType,
      'needs_change': needsChange,
      // Novos campos
      'discount_amount': discountAmount,
      'discount_percentage': discountPercentage,
      'discount_type': discountType,
      'discount_reason': discountReason,
      'subtotal_price': subtotalPrice,
      'coupon_id': couponId,
      'coupon_code': couponCode,
    };
  }
}