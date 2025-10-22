import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/order_details.dart';

class IfoodOrderCard extends StatelessWidget {
  final OrderDetails order;
  final VoidCallback onTap;

  const IfoodOrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getStatusColor(order.orderStatus),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(order.orderStatus),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          '#${order.publicId}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.customerName),
            const SizedBox(height: 4),
            Text(
              '${order.products.length} itens • R\$${(order.totalPrice / 100).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _formatTime(order.createdAt),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(order.orderStatus),
                style: TextStyle(
                  color: _getStatusColor(order.orderStatus),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'on_route':
        return Colors.purple;
      case 'delivered':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.check_circle;
      case 'on_route':
        return Icons.delivery_dining;
      case 'delivered':
        return Icons.thumb_up;
      default:
        return Icons.receipt;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'NOVO';
      case 'preparing':
        return 'PREPARO';
      case 'ready':
        return 'PRONTO';
      case 'on_route':
        return 'ENTREGA';
      case 'delivered':
        return 'ENTREGUE';
      default:
        return status.toUpperCase();
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}