import 'order_product.dart';

class OrderDetails {
  final int id;
  final int sequentialId;
  final String publicId;
  final int storeId;
  final int customerId;
  final int discountedTotalPrice;
  final int? deliveryFee;
  final DateTime createdAt;
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

  OrderDetails({
    required this.id,
    required this.sequentialId,
    required this.publicId,
    required this.storeId,
    required this.customerId,
    required this.discountedTotalPrice,
    required this.createdAt,
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
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      id: json['id'] as int,
      sequentialId: json['sequential_id'] as int,
      publicId: json['public_id'] as String,
      storeId: json['store_id'] as int,
      customerId: json['customer_id'] as int,
      discountedTotalPrice: json['discounted_total_price'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
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
      products: (json['products'] as List)
          .map((product) => OrderProduct.fromJson(product))
          .toList(),
      deliveryFee: json['delivery_fee'] as int?, // <- permite null
    );
  }
}

