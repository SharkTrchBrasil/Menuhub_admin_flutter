// lib/pages/orders/widgets/_order_list_item.dart
import 'package:avatar_glow/avatar_glow.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart'; // Importe o modelo Store
import 'package:totem_pro_admin/pages/orders/utils/order_helpers.dart';
import '_reprint_button.dart';
import 'order_status_button.dart';

class OrderListItem extends StatelessWidget {
  final OrderDetails order;
  final VoidCallback onTap;
  // NOVO: Recebe o objeto da loja ativa.
  final Store? store;
  final bool isStuck;

  const OrderListItem({
    super.key,
    required this.order,
    required this.onTap,
    required this.store, // O store agora é um parâmetro obrigatório.
    this.isStuck = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = statusColors[order.orderStatus] ?? Colors.grey;



final cardContent =  Card(
  elevation: 2,
  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(
      color: Colors.grey.shade200,
      width: 1,
    ),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (ID + Horário)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pedido #${order.sequentialId}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Info Cliente
        Row(
          children: [
            Icon(
              Icons.person_outline,
              size: 20,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                order.customerName,
                style: theme.textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Info Entrega
        // Row(
        //   children: [
        //     Icon(
        //       _getDeliveryIcon(order.deliveryType),
        //       size: 20,
        //       color: Colors.grey.shade600,
        //     ),
        //     const SizedBox(width: 8),
        //     Text(
        //       _getDeliveryTypeName(order.deliveryType),
        //       style: theme.textTheme.bodyMedium,
        //     ),
        //     const Spacer(),
        //     Icon(
        //       Icons.access_time,
        //       size: 20,
        //       color: Colors.grey.shade600,
        //     ),
        //     const SizedBox(width: 8),
        //     Text(
        //       DateFormat('HH:mm').format(order.createdAt),
        //       style: theme.textTheme.bodyMedium,
        //     ),
        //   ],
        // ),

        const SizedBox(height: 16),


        if (store != null)
        // ReprintButton(order: order, store: store!),

        // Adiciona um espaçamento se ambos os botões estiverem visíveis
          const SizedBox(width: 8),
        Row(
          children: [
            Expanded(
              child: OrderStatusButton(
                order: order,
                // AJUSTADO: Passa o 'store' recebido para o botão filho.
                store: store,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
);



    if (isStuck) {
      return AvatarGlow(
        glowColor: Colors.red,

        duration: const Duration(milliseconds: 2000),
        repeat: true,

        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap, // A onTap já tem a lógica de limpar o alerta!
          child: cardContent,
        ),
      );
    }


    // Se não estiver preso, retorna o card normal
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: cardContent,
    );
  }




  }

  IconData _getDeliveryIcon(String deliveryType) {
    switch (deliveryType) {
      case 'takeout':
        return Icons.store_mall_directory;
      case 'delivery':
      case 'cardapio_digital':
        return Icons.delivery_dining;
      case 'dine_in':
        return Icons.table_restaurant;
      default:
        return Icons.help_outline;
    }
  }

  String _getDeliveryTypeName(String deliveryType) {
    switch (deliveryType) {
      case 'takeout':
        return 'Retirada no local';
      case 'delivery':
      case 'cardapio_digital':
        return 'Delivery';
      case 'dine_in':
        return 'Consumo no local';
      default:
        return 'Tipo não especificado';
    }
  }
