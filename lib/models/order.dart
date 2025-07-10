class Order {
  final int id;
  final int sequentialId;
  final String publicId;
  final int storeId;
  final int? customerId;
  final int discountedTotalPrice;
  final String? customerName; // PODE SER NULO
  final String? customerPhone; // PODE SER NULO
  final String? paymentMethodName;
  final String street;
  final String? number;
  final String? complement; // PODE SER NULO
  final String neighborhood;
  final String city;
  final String? attendantName; // PODE SER NULO
  final String orderType;
  final String deliveryType;
  final int totalPrice;
  final String paymentStatus;
  final String orderStatus;

  final int? totemId;

  final int paymentMethodId;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.sequentialId,
    required this.publicId,
    required this.storeId,
    this.customerId,
    required this.discountedTotalPrice,
    this.customerName,
    this.customerPhone,
    this.paymentMethodName,
    required this.street,
    this.number,
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
    required this.paymentMethodId,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      sequentialId: json['sequential_id'] as int,
      publicId: json['public_id'] as String,
      storeId: json['store_id'] as int,
      customerId: json['customer_id'] as int?,
      discountedTotalPrice: json['discounted_total_price'] as int,
      customerName: json['customer_name'] as String?, // Usar 'as String?'
      customerPhone: json['customer_phone'] as String?, // Usar 'as String?'
      paymentMethodName: json['payment_method_name'] as String?,
      street: json['street'] as String,
      number: json['number'] as String?,
      complement: json['complement'] as String?, // Usar 'as String?'
      attendantName: json['attendant_name'] as String?, // Usar 'as String?'
      neighborhood: json['neighborhood'] as String,
      city: json['city'] as String,
      orderType: json['order_type'] as String,
      deliveryType: json['delivery_type'] as String,
      totalPrice: json['total_price'] as int,
      paymentStatus: json['payment_status'] as String,
      orderStatus: json['order_status'] as String,
      totemId: json['totem_id'] as int?,
      paymentMethodId: json['payment_method_id'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}