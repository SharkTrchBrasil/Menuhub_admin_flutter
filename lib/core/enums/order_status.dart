import 'package:flutter/material.dart';

enum OrderStatus {
  pending,

  preparing,
  ready,
  on_route,
  delivered,
  finalized,
  canceled,
  unknown; // Para segurança

  static OrderStatus fromString(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending': return pending;

      case 'preparing': return preparing;
      case 'ready': return ready;
      case 'on_route': return on_route;
      case 'delivered': return delivered;
      case 'finalized': return finalized;
      case 'canceled': return canceled;
      default: return unknown;
    }
  }

  String get displayName {
    switch (this) {
      case OrderStatus.pending: return 'Pendente';

      case OrderStatus.preparing: return 'Em Preparo';
      case OrderStatus.ready: return 'Pronto';
      case OrderStatus.on_route: return 'Em Rota';
      case OrderStatus.delivered: return 'Entregue';
      case OrderStatus.finalized: return 'Finalizado';
      case OrderStatus.canceled: return 'Cancelado';
      default: return 'Desconhecido';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending: return Colors.orange;

      case OrderStatus.preparing: return Colors.blue;
      case OrderStatus.ready: return Colors.purple;
      case OrderStatus.on_route: return Colors.teal;
      case OrderStatus.delivered: return Colors.green;
      case OrderStatus.finalized: return Colors.grey;
      case OrderStatus.canceled: return Colors.red;
      default: return Colors.grey;
    }
  }
}