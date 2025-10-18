// lib/models/tables/command_item.dart (NOVO ARQUIVO)

class CommandItem {
  final int orderId;
  final int productId;
  final String productName;
  final int quantity;
  final int price;  // Em centavos
  final String? note;
  final String? imageUrl;

  CommandItem({
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    this.note,
    this.imageUrl,
  });

  factory CommandItem.fromJson(Map<String, dynamic> json) {
    return CommandItem(
      orderId: json['order_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      price: json['price'],
      note: json['note'],
      imageUrl: json['image_url'],
    );
  }

  double get priceInReais => price / 100;
  double get totalPrice => (price * quantity) / 100;
}