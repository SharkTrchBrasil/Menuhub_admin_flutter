
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/order_details.dart';

class OrderHeaderCard extends StatelessWidget {
  final OrderDetails order;

  const OrderHeaderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(order),
        const SizedBox(height: 16),
        if (order.isScheduled) _buildScheduledInfo(order),
      ],
    );
  }

  Widget _buildHeader(OrderDetails order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '#${order.sequentialId} - ${order.customerName}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (order.customerOrderCount != null)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                order.customerOrderCount == 1
                    ? 'Cliente novo!'
                    : '${_ordinal(order.customerOrderCount!)} pedido na loja',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduledInfo(OrderDetails order) {
    if (order.scheduledFor == null) return const SizedBox.shrink();
    final formattedDate = DateFormat("EEEE, dd 'de' MMMM", 'pt_BR').format(order.scheduledFor!);
    final formattedTime = DateFormat.Hm('pt_BR').format(order.scheduledFor!);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule, color: Colors.blue[800]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pedido Agendado para:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${formattedDate.substring(0, 1).toUpperCase()}${formattedDate.substring(1)} às $formattedTime'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _ordinal(int number) {
    switch (number) {
      case 2: return 'Segundo';
      case 3: return 'Terceiro';
      default: return '${number}º';
    }
  }
}