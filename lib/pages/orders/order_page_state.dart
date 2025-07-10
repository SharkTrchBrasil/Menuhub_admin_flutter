import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/order.dart';

import '../../models/order_details.dart';

//enum OrderStatus { pendent, preparing, ready, canceled }

enum OrderStatus { initial, loading, success, failure }

class OrderState extends Equatable {
  final List<OrderDetails> orders;
  final OrderStatus status;
  final String? error;

  const OrderState({
    this.orders = const [],
    this.status = OrderStatus.initial,
    this.error,
  });

  OrderState copyWith({
    List<OrderDetails>? orders,
    OrderStatus? status,
    String? error,
  }) {
    return OrderState(
      orders: orders ?? this.orders,
      status: status ?? this.status,
      error: error,
    );
  }

  @override
  List<Object?> get props => [orders, status, error];
}
