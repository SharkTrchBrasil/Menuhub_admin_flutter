import 'package:flutter/material.dart';
import '../../../models/order_details.dart';


class MobileOrderList extends StatelessWidget {
  final List<OrderDetails> orders;
  final int currentTabIndex;
  final List<String> statusTabs;
  final void Function(BuildContext context, OrderDetails order) onOrderTap;
  final Widget Function(OrderDetails order, int tabIndex) buildOrderCard;

  const MobileOrderList({
    super.key,
    required this.orders,
    required this.currentTabIndex,
    required this.statusTabs,
    required this.onOrderTap,
    required this.buildOrderCard,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Text(
          'Nenhum pedido ${statusTabs[currentTabIndex]}',
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return GestureDetector(
          onTap: () => onOrderTap(context, order),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: buildOrderCard(order, currentTabIndex),
          ),
        );
      },
    );
  }
}
