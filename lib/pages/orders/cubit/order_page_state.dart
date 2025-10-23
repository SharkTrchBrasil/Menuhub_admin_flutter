// lib/pages/orders/cubit/order_page_state.dart

import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/order_details.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrderState {
  const OrdersInitial();
}

class OrdersLoading extends OrderState {
  const OrdersLoading();
}

class OrdersLoaded extends OrderState {
  final List<OrderDetails> orders;
  final int? activeStoreId;
  final String? lastNotifiedOrderId;
  final OrderFilter filter;
  final bool isConnected;
  final int pendingManualPrintsCount;

  const OrdersLoaded({
    required this.orders,
    this.activeStoreId,
    this.lastNotifiedOrderId,
    required this.filter,
    this.isConnected = true,
    this.pendingManualPrintsCount = 0,
  });

  // ✅ NOVO: Getter para retornar os pedidos já filtrados
  List<OrderDetails> get filteredOrders => orders;

  OrdersLoaded copyWith({
    List<OrderDetails>? orders,
    int? activeStoreId,
    String? lastNotifiedOrderId,
    OrderFilter? filter,
    bool? isConnected,
    int? pendingManualPrintsCount,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      activeStoreId: activeStoreId ?? this.activeStoreId,
      lastNotifiedOrderId: lastNotifiedOrderId ?? this.lastNotifiedOrderId,
      filter: filter ?? this.filter,
      isConnected: isConnected ?? this.isConnected,
      pendingManualPrintsCount: pendingManualPrintsCount ?? this.pendingManualPrintsCount,
    );
  }

  @override
  List<Object?> get props => [
    orders,
    activeStoreId,
    lastNotifiedOrderId,
    filter,
    isConnected,
    pendingManualPrintsCount,
  ];
}

class OrdersEmpty extends OrderState {
  final String message;
  const OrdersEmpty({required this.message});

  @override
  List<Object?> get props => [message];
}

class OrdersError extends OrderState {
  final String message;
  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

enum OrderFilter { all, pending, preparing, ready }