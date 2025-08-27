// lib/widgets/orders_data_table.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/models/order_details.dart';

class OrdersDataTable extends StatelessWidget {
  final List<OrderDetails> orders;
  final Function(OrderDetails order)? onOrderTap; // Opcional para ver detalhes

  const OrdersDataTable({
    super.key,
    required this.orders,
    this.onOrderTap,
  });

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('dd/MM HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Nenhum pedido encontrado para os filtros selecionados.'),
        ),
      );
    }

    return DataTable(
      columns: const [
        DataColumn(label: Text('Pedido')),
        DataColumn(label: Text('Data')),
        DataColumn(label: Text('Cliente')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Valor'), numeric: true),
      ],
      rows: orders.map((order) {
        return DataRow(
          cells: [
            DataCell(Text('#${order.publicId}')),
            DataCell(Text(_formatDateTime(order.createdAt))),
            DataCell(Text(order.customerName ?? 'N/A')),
            DataCell(Text(order.orderStatus)), // Você pode customizar com um badge de cor aqui
            DataCell(Text(_formatCurrency(order.totalPrice / 100.0))),
          ],
          onSelectChanged: onOrderTap != null ? (_) => onOrderTap!(order) : null,
        );
      }).toList(),
    );
  }
}