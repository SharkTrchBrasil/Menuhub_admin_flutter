import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/pages/orders/utils/order_helpers.dart';

class OrderStatusBar extends StatelessWidget {
  final OrderDetails order;

  const OrderStatusBar({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    var displayStatuses = ['pending', 'preparing', 'ready', 'on_route', 'delivered'];

    if (order.deliveryType != 'delivery') {
      displayStatuses.remove('on_route');
    }

    final currentStatus = order.orderStatus;
    var currentStatusIndex = displayStatuses.indexOf(currentStatus);

    if (currentStatus == 'finalized') {
      currentStatusIndex = displayStatuses.length - 1;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Status do Pedido', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(displayStatuses.length, (index) {
              final isActive = index <= currentStatusIndex;
              final status = displayStatuses[index];
              final color = isActive ? (statusColors[status] ?? Colors.grey) : Colors.grey[300]!;

              return Expanded(
                child: Column(
                  children: [
                    Container(height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 4),
                    Text(
                      internalStatusToDisplayName[status] ?? status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive ? Colors.black : Colors.grey,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).expand((widget) => [widget, const SizedBox(width: 4)]).toList()..removeLast(),
          ),
        ],
      ),
    );
  }
}