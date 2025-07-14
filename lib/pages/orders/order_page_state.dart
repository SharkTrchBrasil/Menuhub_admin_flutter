// lib/pages/orders/order_page_state.dart

import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/order_details.dart';

// Enum para filtros de pedidos (se você tiver)
enum OrderFilter {
  all,
  pending,
  accepted,
  // ... outros status
}

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrderState {
  const OrdersInitial();
}

class OrdersLoading extends OrderState {
  // Pode ter um opcional para indicar qual loja está carregando
  // final int? storeId;
  const OrdersLoading(); // {this.storeId}
}

class OrdersLoaded extends OrderState {
  final List<OrderDetails> orders;
  final OrderFilter selectedFilter;
  // Opcional: Para saber de qual conjunto de lojas esses pedidos vieram.
  // final List<int> currentConsolidatedStores; // Ou um map para mostrar quais estão ativas

  const OrdersLoaded({
    required this.orders,
    this.selectedFilter = OrderFilter.all,
    // this.currentConsolidatedStores = const [],
  });

  // Você pode adicionar getters para pedidos filtrados
  List<OrderDetails> get filteredOrders {
    switch (selectedFilter) {
      case OrderFilter.all:
        return orders;
      case OrderFilter.pending:
        return orders.where((order) => order.orderStatus == 'pending').toList();
      case OrderFilter.accepted:
        return orders.where((order) => order.orderStatus == 'accepted').toList();
      default:
        return orders;
    }
  }

  @override
  List<Object?> get props => [orders, selectedFilter]; // currentConsolidatedStores
}

class OrdersError extends OrderState {
  final String message;
  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrdersEmpty extends OrderState {
  final String message; // Opcional, para uma mensagem mais detalhada
  const OrdersEmpty({this.message = 'Nenhum pedido encontrado.'});

  @override
  List<Object?> get props => [message];
}