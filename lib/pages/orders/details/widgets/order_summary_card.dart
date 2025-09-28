import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/order_details.dart';

class OrderSummaryCard extends StatelessWidget {
  final OrderDetails order;

  const OrderSummaryCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final deliveryFee = (order.deliveryFee ?? 0) / 100;
    final subtotal = order.totalPrice / 100;
    final discountAmount = (order.discountAmount ?? 0) / 100;
    final total = (order.discountedTotalPrice + (order.deliveryFee ?? 0)) / 100;

    final hasDiscount = discountAmount > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Resumo Financeiro', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal', currencyFormat.format(subtotal), theme),
          _buildSummaryRow('Taxa de entrega', currencyFormat.format(deliveryFee), theme),
          if (hasDiscount)
            _buildSummaryRow(
              'Desconto aplicado',
              '-${currencyFormat.format(discountAmount)}',
              theme,
              valueColor: Colors.green,
            ),
          const Divider(height: 16),
          _buildSummaryRow(
            'Total',
            currencyFormat.format(total),
            theme,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, ThemeData theme, {Color? valueColor, bool isTotal = false}) {
    final style = isTotal
        ? theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
        : theme.textTheme.bodyMedium;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(
            value,
            style: style?.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}