// lib/pages/orders/widgets/order_list_item.dart
import 'package:avatar_glow/avatar_glow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/pages/orders/utils/order_helpers.dart';

// ✅ 1. IMPORTE O NOVO WIDGET DE TIMER
import 'order_countdown_timer.dart';
import 'order_status_button.dart';

class OrderListItem extends StatelessWidget {
  final OrderDetails order;
  final VoidCallback onTap;
  final Store? store;
  final bool isStuck;

  const OrderListItem({
    super.key,
    required this.order,
    required this.onTap,
    required this.store,
    this.isStuck = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    // Conteúdo principal do card, agora mais informativo
    final cardContent = Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isStuck ? Colors.red.shade300 : Colors.grey.shade200,
          width: isStuck ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Linha 1: ID, Timer/Status e Valor Total
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ 2. ÁREA DO TIMER / ÍCONE DE STATUS
                // Se o pedido está pendente, mostra o timer.
                if (order.orderStatus == 'pending')
                  OrderCountdownTimer(createdAt: order.createdAt)
                else
                // Caso contrário, mostra um ícone representando o status atual.
                  _buildStatusIcon(),

                const SizedBox(width: 12),

                // Coluna com ID e Nome do Cliente
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido #${order.sequentialId}',
                        style: theme.textTheme.bodySmall?.copyWith(),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.customerName,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ✅ 3. MELHORIA DE ALTO VALOR: VALOR TOTAL DO PEDIDO
                Text(
                  currencyFormat.format(order.totalPrice / 100),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColors[order.orderStatus] ?? Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),



            // ✅ 4. MELHORIA DE ALTO VALOR: INFOS DE LOGÍSTICA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoChip(
                  icon: _getDeliveryIcon(order.deliveryType),
                  text: _getDeliveryTypeName(order.deliveryType),
                ),
                _InfoChip(
                  icon: Icons.payments_outlined,
                  text: order.paymentMethodName,
                ),
                _InfoChip(
                  icon: Icons.access_time,
                  text: DateFormat('HH:mm').format(order.createdAt),
                ),
              ],
            ),

            const SizedBox(height: 22),

            OrderStatusButton(
              order: order,
              store: store,
            ),



          ],
        ),
      ),
    );

    // Lógica do AvatarGlow (efeito de alerta para pedidos presos)
    if (isStuck) {
      return AvatarGlow(
        glowColor: Colors.red,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: cardContent,
        ),
      );
    }

    // Retorna o card normal com InkWell para ser clicável
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: cardContent,
    );
  }

  // Helper para mostrar o ícone de status para pedidos não pendentes
  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (order.orderStatus) {
      case 'preparing':
        icon = Icons.kitchen_outlined;
        color = Colors.blue.shade600;
        break;
      case 'ready':
        icon = Icons.check_circle_outline;
        color = Colors.green.shade600;
        break;
      case 'on_route':
        icon = Icons.delivery_dining_outlined;
        color = Colors.purple.shade600;
        break;
      default:
        icon = Icons.receipt_long_outlined;
        color = Colors.grey;
    }

    // Container para dar um fundo e alinhar o tamanho com o timer
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  // Helpers que você já tinha
  IconData _getDeliveryIcon(String deliveryType) {
    switch (deliveryType) {
      case 'takeout': return Icons.store_mall_directory_outlined;
      case 'delivery': return Icons.delivery_dining_outlined;
      case 'dine_in': return Icons.table_restaurant_outlined;
      default: return Icons.help_outline;
    }
  }

  String _getDeliveryTypeName(String deliveryType) {
    switch (deliveryType) {
      case 'takeout': return 'Retirada';
      case 'delivery': return 'Delivery';
      case 'dine_in': return 'Consumo Local';
      default: return 'Não especificado';
    }
  }
}

// ✅ 5. NOVO WIDGET HELPER PARA OS CHIPS DE INFORMAÇÃO
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade700),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}