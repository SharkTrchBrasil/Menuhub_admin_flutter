// lib/pages/orders/widgets/order_details_mobile.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/pages/orders/order_page_cubit.dart';
import 'package:totem_pro_admin/pages/orders/utils/order_helpers.dart'; // Para statusColors, deliveryTypeIcons, formatOrderDate, statusInternalMap

class OrderDetailsPage extends StatelessWidget {
  final OrderDetails order;
  final Function(OrderDetails order) onPrintOrder;

  const OrderDetailsPage({
    Key? key,
    required this.order,
    required this.onPrintOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color statusColor = statusColors[order.orderStatus] ?? Colors.grey;
    final String deliveryType = order.deliveryType; // Pega o tipo de entrega
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.customerName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Pedido #${order.publicId}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dados do Cliente
            const Text(
              'Dados do Cliente',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Nome:',
              order.customerName,
              Icons.person,
            ),
            _buildDetailRow(
              'Telefone:',
              order.customerPhone,
              Icons.phone,
            ),
            _buildDetailRow(
              'Endereço:',
              order.city ?? 'Não informado',
              Icons.location_on,
            ),
            _buildDetailRow(
              'Tipo de Entrega:',
              order.deliveryType,
              deliveryTypeIcons[order.deliveryType] ?? Icons.receipt,
            ),
            const SizedBox(height: 24),

            // Status do Pedido com Barras
            const Text(
              'Status do Pedido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildStatusBar(order.orderStatus),
            const SizedBox(height: 24),

            // Itens do Pedido
            const Text(
              'Itens do Pedido',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...order.products.map((product) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${product.quantity}x ${product.name}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  Text(
                    'R\$ ${(product.price / 100).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )).toList(),
            const Divider(height: 32, thickness: 1),

            // Resumo de Preços
            _buildPriceRow('Subtotal:', order.products.fold(0.0, (sum, p) => sum + (p.price / 100)).toStringAsFixed(2)),
            _buildPriceRow('Taxa de Entrega:', (order.deliveryFee ?? 0 / 100).toStringAsFixed(2)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'R\$ ${(order.totalPrice / 100).toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 10.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (canStoreCancelOrder(order.orderStatus))

                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () =>
                        showCancelConfirmationDialog(context, order),
                    child: const Text(
                        'Cancelar Pedido', style: TextStyle(color: Colors.red)),
                  ),
                ),




              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    _changeOrderStatus(context);
                  },
                  child: Text(
                    getButtonTextForStatus(order.orderStatus, deliveryType),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor ?? Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            'R\$ $value',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(String currentStatus) {
    final List<String> displayStatuses = ['pending', 'preparing','ready', 'on_route','delivered'];
    final int currentStatusIndex = displayStatuses.indexOf(currentStatus);

    return Row(
      children: List.generate(displayStatuses.length, (index) {
        final bool isActive = index <= currentStatusIndex;
        final Color segmentColor = isActive
            ? statusColors[displayStatuses[index]] ?? Colors.grey
            : Colors.grey[300]!;

        return Expanded(
          child: Column(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: segmentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mobileStatusTabs[mobileStatusInternalMap.values.toList().indexOf(displayStatuses[index])], // Ajustado, mas verifique o contexto
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
      }).expand((widget) => [widget, const SizedBox(width: 8)]).toList()..removeLast(), // Add space between segments
    );
  }

  void _changeOrderStatus(BuildContext context) {
    String? nextStatus;
    switch (order.orderStatus) {
      case 'pending':
        nextStatus = 'preparing';

        onPrintOrder(order); // Imprime ao aceitar

        break;
      case 'preparing':
        nextStatus = 'ready';
        break;
      case 'ready':
        nextStatus = 'on_route';

        break;
      case 'on_route':
        nextStatus = 'delivered';
        break;
      default:
        nextStatus = null; // Para delivered e cancelled, sem ação de "próximo status"
    }

    if (nextStatus != null) {
      context.read<OrderCubit>().updateOrderStatus(order.id, nextStatus);
      // Opcional: Navegar de volta ou fechar o modal após a alteração de status
      // Navigator.of(context).pop();
    }
  }


}