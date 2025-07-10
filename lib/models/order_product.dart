import 'package:totem_pro_admin/models/order_product_ticket.dart';
import 'package:totem_pro_admin/models/order_product_variant.dart';

class OrderProduct {

  OrderProduct({
    required this.id,
    required this.name,
    required this.quantity,
    required this.variants,
  //  required this.tickets,
    required this.price,
  });

  final int id;
  final String name;
  final int quantity;
  final List<OrderProductVariant> variants;
//  final List<OrderProductTicket> tickets;
  final int price;

  factory OrderProduct.fromJson(Map<String, dynamic> map) {
    return OrderProduct(
      id: map['id'] as int,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      variants: map['variants'].map<OrderProductVariant>((c) => OrderProductVariant.fromJson(c)).toList(),
    //  tickets: map['tickets'].map<OrderProductTicket>((c) => OrderProductTicket.fromJson(c)).toList(),
      price: map['price'],
    );
  }

}