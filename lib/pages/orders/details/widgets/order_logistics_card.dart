import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/order_details.dart';

class OrderLogisticsCard extends StatelessWidget {
  final OrderDetails order;

  const OrderLogisticsCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          if (order.deliveryType == 'delivery') ...[
            _buildAddressCard(order, theme),
            const Divider(height: 24),
          ],
          _buildPaymentMethodCard(order, theme, currencyFormat),
        ],
      ),
    );
  }

  Widget _buildAddressCard(OrderDetails order, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Endereço de entrega', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('${order.street}, ${order.number}', style: theme.textTheme.bodyMedium),
        Text('${order.neighborhood} - ${order.city}', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
        if (order.complement?.isNotEmpty ?? false)
          Text(order.complement!, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildPaymentMethodCard(OrderDetails order, ThemeData theme, NumberFormat currencyFormat) {
    final total = (order.discountedTotalPrice + (order.deliveryFee ?? 0)) / 100;
    final isDinheiro = order.paymentMethodName.toLowerCase().contains('dinheiro');
    final troco = (order.changeAmount ?? 0) / 100;

    String title;
    String description;
    IconData icon;

    if (isDinheiro) {
      icon = Icons.payments_outlined;
      title = 'Pagamento em Dinheiro';
      description = troco > 0
          ? 'Troco necessário: ${currencyFormat.format(troco)}'
          : 'Não é necessário troco.';
    } else {
      icon = Icons.credit_card;
      title = 'Pagamento com Cartão';
      description = 'O pagamento será feito na entrega via maquininha.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Forma de Pagamento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(icon, color: Colors.grey[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
                  Text(description, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                ],
              ),
            ),
            Text(
              currencyFormat.format(total),
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        )
      ],
    );
  }
}