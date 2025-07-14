import 'order_product.dart';

class OrderStatuses {
  static const String pending = 'pending';
  static const String preparing = 'preparing';
  static const String ready = 'ready';
  static const String canceled = 'canceled';
}

class OrderDetails {
  final int id;
  final int sequentialId;
  final String publicId;
  final int storeId;
  final int customerId;
  final int discountedTotalPrice;
  final int? deliveryFee;
  final DateTime createdAt;
  final DateTime updatedAt; // <--- Adicione esta propriedade
  final String customerName;
  final String customerPhone;
  final String paymentMethodName;
  final String street;
  final String number;
  final String ? complement;
  final String neighborhood;
  final String city;
  final String ? attendantName;
  final String orderType;
  final String deliveryType;
  final int totalPrice;
  final String paymentStatus;
  final String orderStatus;
  final int? totemId;
  final int paymentMethodId;
  final List<OrderProduct> products;

  final DateTime? scheduledFor;
  final bool isScheduled;
  final String consumptionType;


  OrderDetails({
    required this.id,
    required this.sequentialId,
    required this.publicId,
    required this.storeId,
    required this.customerId,
    required this.discountedTotalPrice,
    required this.createdAt,
    required this.updatedAt, // <--- E aqui no construtor
    required this.customerName,
    required this.customerPhone,
    required this.paymentMethodName,
    required this.street,
    required this.number,
    required this.complement,
    required this.neighborhood,
    required this.city,
    required this.attendantName,
    required this.orderType,
    required this.deliveryType,
    required this.totalPrice,
    required this.paymentStatus,
    required this.orderStatus,
    required this.totemId,
    required this.paymentMethodId,
    required this.products,
    required this.deliveryFee,
    this.scheduledFor,
    this.isScheduled = false,
    this.consumptionType = 'dine_in',

  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['id'] as int,
      sequentialId: json['sequential_id'] as int,
      publicId: json['public_id'] as String,
      storeId: json['store_id'] as int,
      customerId: json['customer_id'] as int,
      discountedTotalPrice: json['discounted_total_price'] as int,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String,
      paymentMethodName: json['payment_method_name'] as String,
      street: json['street'] as String,
      number: json['number'] as String,
      complement: json['complement'] ?? "",
      neighborhood: json['neighborhood'] as String,
      city: json['city'] as String,
      attendantName: json['attendant_name'] ?? "",
      orderType: json['order_type'] as String,
      deliveryType: json['delivery_type'] as String,
      totalPrice: json['total_price'] as int,
      paymentStatus: json['payment_status'] as String,
      orderStatus: json['order_status'] as String,
      totemId: json['totem_id'] as int?, // <- permite null
      paymentMethodId: json['payment_method_id'] as int,
      products: (json['products'] as List<dynamic>)
          .map((product) => OrderProduct.fromJson(product as Map<String, dynamic>))
          .toList(),

      deliveryFee: json['delivery_fee'] as int?, // <- permite null

      scheduledFor: json['scheduled_for'] != null
          ? DateTime.parse(json['scheduled_for'] as String).toLocal()
          : null,
      isScheduled: json['is_scheduled'] as bool? ?? false,
      consumptionType: json['consumption_type'] as String? ?? 'dine_in',
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
      'total_price': totalPrice,
      'payment_status': paymentStatus,
      'order_status': orderStatus,
      'totem_id': totemId,
      'payment_method_id': paymentMethodId,
      'products': products.map((p) => p.toJson()).toList(),
      'delivery_fee': deliveryFee,
      'updated_at': updatedAt.toIso8601String(),
      'scheduled_for': scheduledFor?.toIso8601String(),
      'is_scheduled': isScheduled,
      'consumption_type': consumptionType,
    };
  }
}







