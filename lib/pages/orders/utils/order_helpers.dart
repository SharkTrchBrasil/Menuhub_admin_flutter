// lib/pages/orders/utils/order_helpers.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/pages/orders/cubit/order_page_state.dart';
import '../cubit/order_page_cubit.dart';

// ==========================================================================
// Mapeamentos e Constantes de UI
// ==========================================================================

const Map<OrderFilter, String> orderFilterToDisplayName = {
  OrderFilter.all: 'Todos',
  OrderFilter.pending: 'Pendentes',
  OrderFilter.preparing: 'Em Preparo',
  OrderFilter.ready: 'Prontos',
};

const Map<String, String> internalStatusToDisplayName = {
  'pending': 'Pendente',
  'preparing': 'Em Preparo',
  'ready': 'Pronto',
  'on_route': 'Em Rota',
  'delivered': 'Concluído',
  'canceled': 'Cancelado',
  'finalized': 'Finalizado'
};

const Map<String, Color> statusColors = {
  'pending': Colors.orange,
  'preparing': Colors.blue,
  'ready': Colors.purple,
  'on_route': Colors.teal,
  'delivered': Colors.grey,
  'canceled': Colors.red,
};



// --- ADICIONE ESTAS FUNÇÕES AO SEU ARQUIVO order_helpers.dart ---

// ==========================================================================
// Funções de Lógica de Pedidos
// ==========================================================================

/// Ordena uma lista de pedidos pela ordem de status e, em seguida, pela data.
List<OrderDetails> sortOrdersByStatusAndDate(List<OrderDetails> orders) {
  if (orders.isEmpty) return [];

  const statusOrder = ['pending', 'preparing', 'ready', 'on_route', 'delivered', 'canceled'];

  final sortedOrders = List<OrderDetails>.from(orders);
  sortedOrders.sort((a, b) {
    final statusIndexA = statusOrder.indexOf(a.orderStatus);
    final statusIndexB = statusOrder.indexOf(b.orderStatus);

    if (statusIndexA != statusIndexB) {
      return statusIndexA.compareTo(statusIndexB);
    }
    // Se os status forem iguais, o mais recente vem primeiro.
    return b.createdAt.compareTo(a.createdAt);
  });

  return sortedOrders;
}

/// Filtra uma lista de pedidos com base no `OrderFilter` selecionado.
List<OrderDetails> filterOrders(List<OrderDetails> orders, OrderFilter filter) {
  switch (filter) {
    case OrderFilter.all:
      return orders;
    case OrderFilter.pending:
      return orders.where((order) => order.orderStatus == 'pending').toList();
    case OrderFilter.preparing:
      return orders.where((order) => order.orderStatus == 'preparing').toList();
    case OrderFilter.ready:
      return orders.where((order) => order.orderStatus == 'ready').toList();
    default:
      return orders;
  }
}


// Adicione esta função ao seu arquivo de helpers

/// Verifica se um pedido ainda pode ser cancelado pela loja.
bool canStoreCancelOrder(String currentOrderStatus) {
  // A loja pode cancelar enquanto o pedido não saiu para entrega ou foi finalizado.
  return ['pending', 'preparing', 'ready'].contains(currentOrderStatus);
}


// ==========================================================================
// Funções de Lógica de Status de Pedidos
// ==========================================================================

/// Retorna o texto do botão de ação principal com base no status e tipo de entrega.
String getButtonTextForStatus(String currentStatus, String deliveryType) {
  switch (currentStatus) {
    case 'pending':
      return 'Aceitar Pedido';
    case 'preparing':
      return 'Marcar como Pronto';
    case 'ready':
      return deliveryType == 'delivery' ? 'Saiu para Entrega' : 'Finalizar Pedido';
    case 'on_route':
      return 'Marcar como Entregue';
    default:
      return 'Ação';
  }
}

/// Retorna o próximo status de um pedido com base no status atual e tipo de entrega.
String? getNextStatusInternal(String currentStatus, String deliveryType) {
  switch (currentStatus) {
    case 'pending':
      return 'preparing';
    case 'preparing':
      return 'ready';
    case 'ready':
      return deliveryType == 'delivery' ? 'on_route' : 'delivered';
    case 'on_route':
      return 'delivered';
    default:
      return null;
  }
}

// ==========================================================================
// Funções de Formatação e UI Helpers
// ==========================================================================

String timeAgoFromDate(DateTime dateTime) {
  final difference = DateTime.now().difference(dateTime);
  if (difference.inMinutes < 1) return 'agora';
  if (difference.inMinutes < 60) return 'há ${difference.inMinutes} min';
  if (difference.inHours < 24) return 'há ${difference.inHours}h';
  return DateFormat('dd/MM HH:mm').format(dateTime.toLocal());
}

/// Exibe um diálogo de confirmação para cancelar um pedido.
void showCancelConfirmationDialog(BuildContext context, OrderDetails order) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: const Text('Confirmar Cancelamento'),
        content: Text('Tem certeza que deseja cancelar o pedido #${order.publicId}?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Não'),
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sim', style: TextStyle(color: Colors.white)),
            onPressed: () {
              context.read<OrderCubit>().updateOrderStatus(order.id, 'canceled');
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}

