// lib/widgets/orders/order_kanban_column.dart

import 'package:flutter/material.dart';
import '../../../../../models/order_details.dart';

import 'order_kanban_card.dart';

class OrderKanbanColumn extends StatelessWidget {
  final String title;
  final List<OrderDetails> orders;
  final IconData? emptyIcon;
  final String? emptyDescription;
  final Function(OrderDetails)? onOrderTap;

  const OrderKanbanColumn({
    Key? key,
    required this.title,
    required this.orders,
    this.emptyIcon,
    this.emptyDescription,
    this.onOrderTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da coluna
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: orders.isEmpty ? Colors.grey[200] : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${orders.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: orders.isEmpty ? Colors.grey[700] : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.expand_less,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),

          // Lista de pedidos ou estado vazio
          Expanded(
            child: orders.isEmpty
                ? _buildEmptyState()
                : _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon ?? Icons.inbox_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              emptyDescription ?? 'Nenhum pedido nesta etapa',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderKanbanCard(
          order: order,
          onTap: onOrderTap != null ? () => onOrderTap!(order) : null,
        );
      },
    );
  }
}