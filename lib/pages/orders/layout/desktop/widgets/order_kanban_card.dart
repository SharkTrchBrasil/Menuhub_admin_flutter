// lib/widgets/orders/order_kanban_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../models/order_details.dart';


class OrderKanbanCard extends StatelessWidget {
  final OrderDetails order;
  final VoidCallback? onTap;

  const OrderKanbanCard({
    Key? key,
    required this.order,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Número do pedido e tempo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '#${order.sequentialId}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(order.orderStatus),
                      ),
                    ),
                  ),
                  Text(
                    _getTimeAgo(order.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Cliente
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.customerName ?? 'Cliente não identificado',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Tipo de entrega
              Row(
                children: [
                  Icon(
                    _getDeliveryIcon(order.deliveryType),
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 8),
                  Text(
                    _getDeliveryLabel(order.deliveryType),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),

              // Endereço (apenas para delivery)
              if (order.deliveryType == 'delivery') ...[
                SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _getFullAddress(order),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey[300]),
              SizedBox(height: 12),

              // Footer: Valor e forma de pagamento
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatCurrency(order.totalPrice),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.grey[300]!,
                      ),
                    ),
                    child: Text(
                      order.paymentMethodName ?? 'Não informado',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'in_transit':
        return Colors.purple;
      case 'delivered':
      case 'completed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getDeliveryIcon(String deliveryType) {
    switch (deliveryType.toLowerCase()) {
      case 'delivery':
        return Icons.delivery_dining;
      case 'pickup':
        return Icons.shopping_bag;
      case 'table':
        return Icons.restaurant;
      default:
        return Icons.help_outline;
    }
  }

  String _getDeliveryLabel(String deliveryType) {
    switch (deliveryType.toLowerCase()) {
      case 'delivery':
        return 'Entrega';
      case 'pickup':
        return 'Retirada';
      case 'table':
        return 'Mesa';
      default:
        return deliveryType;
    }
  }

  String _getFullAddress(OrderDetails order) {
    List<String> parts = [
      order.street,
      if (order.number != null) order.number!,
      order.neighborhood,
      order.city,
    ];
    return parts.join(', ');
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  String _formatCurrency(int cents) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(cents / 100);
  }
}