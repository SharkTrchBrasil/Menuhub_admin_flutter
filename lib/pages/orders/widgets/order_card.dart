import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';

import '../../../models/order_details.dart';

class OrderCard extends StatelessWidget {
  final OrderDetails order;
  final int currentStatusIndex;
  final List<Color> statusColors;
  final List<String> statusTabs;
  final Map<String, int> statusInternalMap;
  final Map<String, IconData> deliveryTypeIcons;
  final String Function(int, String) getButtonTextForStatus;
  final void Function(int orderId, int nextStatus) onUpdateOrderStatus;
  final String Function(DateTime) formatDate;

  const OrderCard({
    Key? key,
    required this.order,
    required this.currentStatusIndex,
    required this.statusColors,
    required this.statusTabs,
    required this.statusInternalMap,
    required this.deliveryTypeIcons,
    required this.getButtonTextForStatus,
    required this.onUpdateOrderStatus,
    required this.formatDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = statusColors[currentStatusIndex];
    final deliveryIcon = deliveryTypeIcons[order.deliveryType] ?? Icons.help_outline;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Delivery Icon, Order ID, Date & Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Icon(deliveryIcon, size: 20, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Pedido #${order.id}',
                        style: const TextStyle(
                          fontSize: 18,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    formatDate(order.createdAt),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer Info & Total/Payment
            if (order.customerName != null || order.customerPhone != null)
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          order.customerName ?? 'N/A',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        order.totalPrice.toPrice(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          order.customerPhone ?? 'N/A',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          order.paymentMethodName ?? 'N/A',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            const SizedBox(height: 12),

            // Address or Takeout Info
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.deliveryType == 'takeout'
                        ? 'Retirada na loja'
                        : (order.street ?? '') +
                        (order.number == null ? '' : ', ${order.number}') +
                        (order.neighborhood != null ? ', ${order.neighborhood}' : '') +
                        (order.city != null ? ', ${order.city}' : ''),
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Button
            if (currentStatusIndex < statusTabs.length)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (currentStatusIndex < statusTabs.length - 1) {
                      final label = statusTabs[currentStatusIndex + 1];
                      final nextStatus = statusInternalMap[label]!;
                      onUpdateOrderStatus(order.id, nextStatus);
                    } else if (order.orderStatus == 'ready') {
                      onUpdateOrderStatus(order.id, 'finished' as int); // Ajuste conforme seu tipo
                    }
                  },
                  child: Text(
                    getButtonTextForStatus(currentStatusIndex, order.orderStatus),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
