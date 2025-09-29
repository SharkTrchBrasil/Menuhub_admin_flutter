class StoreCustomer {
  final int customerId;
  final String name;
  final String? phone;
  final String? email;
  final int totalOrders;
  final int totalSpent;
  final DateTime? lastOrderAt;

  StoreCustomer({
    required this.customerId,
    required this.name,
    this.phone,
    this.email,
    required this.totalOrders,
    required this.totalSpent,
    this.lastOrderAt,
  });

  factory StoreCustomer.fromJson(Map<String, dynamic> json) {
    return StoreCustomer(
      customerId: json['customer_id'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      totalOrders: json['total_orders'],
      totalSpent: json['total_spent'],
      lastOrderAt: json['last_order_at'] != null
          ? DateTime.parse(json['last_order_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'name': name,
      'phone': phone,
      'email': email,
      'total_orders': totalOrders,
      'total_spent': totalSpent,
      'last_order_at': lastOrderAt?.toIso8601String(),
    };
  }
}
