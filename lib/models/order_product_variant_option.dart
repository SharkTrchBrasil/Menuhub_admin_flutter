class OrderProductVariantOption {

  OrderProductVariantOption({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price
  });

  final int id;
  final String name;
  final int quantity;
  final int price;

  factory OrderProductVariantOption.fromJson(Map<String, dynamic> map) {
    return OrderProductVariantOption(
      id: map['id'] as int,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      price: map['price'] as int,
    );
  }

  // Add this toJson method
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'price': price
    };
  }
}