import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/pages/orders/cubit/order_page_cubit.dart';
import 'package:totem_pro_admin/services/print/print_manager.dart';

import '../../../core/di.dart';
import '../../../core/enums/order_status.dart';
import '../../../widgets/ds_primary_button.dart';

class OrderStatusButton extends StatelessWidget {
  final OrderDetails order;
  final Store? store;

  const OrderStatusButton({
    super.key,
    required this.order,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Colors.grey;
    String buttonText = 'Ação Indisponível';
    VoidCallback? onPressed;

    final OrderStatus currentStatus = OrderStatus.fromString(order.orderStatus);

    switch (currentStatus) {
    // ✅ FLUXO CORRIGIDO
      case OrderStatus.pending:
        buttonText = 'Aceitar Pedido';
        buttonColor = Colors.green;
        onPressed = () {
          // Ação correta: PENDENTE -> ACEITO
          context.read<OrderCubit>().updateOrderStatus(order.id, 'preparing');
        };
        break;

      case OrderStatus.preparing:
        buttonText = 'Marcar como Pronto';
        buttonColor = Colors.blue;
        onPressed = () {
          context.read<OrderCubit>().updateOrderStatus(order.id, 'ready');
        };
        break;

      case OrderStatus.ready:
        if (order.deliveryType == 'delivery') {
          buttonText = 'Saiu para Entrega';
          buttonColor = Colors.purple;
          onPressed = () {
            context.read<OrderCubit>().updateOrderStatus(order.id, 'on_route');
          };
        } else {
          buttonText = 'Marcar como Entregue'; // Para balcão/mesa, já vai para entregue
          buttonColor = Colors.green;
          onPressed = () {
            context.read<OrderCubit>().updateOrderStatus(order.id, 'delivered');
          };
        }
        break;

      case OrderStatus.on_route:
        buttonText = 'Marcar como Entregue';
        buttonColor = Colors.green.shade700;
        onPressed = () {
          context.read<OrderCubit>().updateOrderStatus(order.id, 'delivered');
        };
        break;

    // ✅ NOVO ESTADO
      case OrderStatus.delivered:
        buttonText = 'Finalizar Pedido';
        buttonColor = Colors.teal;
        onPressed = () {
          context.read<OrderCubit>().updateOrderStatus(order.id, 'finalized');
        };
        break;

      case OrderStatus.finalized:
      case OrderStatus.canceled:
        buttonText = currentStatus == OrderStatus.finalized ? 'Pedido Finalizado' : 'Pedido Cancelado';
        buttonColor = Colors.grey;
        onPressed = null;
        break;

      default:
        buttonText = 'Ação Indisponível';
        buttonColor = Colors.grey;
        onPressed = null;
    }

    return Row(

      children: [
        if (onPressed != null)
          Expanded(
            child: DsButton(
              backgroundColor: buttonColor,

              onPressed: onPressed,
              child: Text(
                buttonText,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        //
        // if (order.orderStatus != 'delivered' && order.orderStatus != 'canceled')
        //   Flexible(
        //     child: DsButton(
        //       style: DsButtonStyle.secondary,
        //
        //       onPressed: () => _showCancelDialog(context),
        //       child: const Text('Cancelar Pedido', style: TextStyle(color: Colors.red)),
        //     ),
        //   ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Cancelamento'),
          content: Text('Tem certeza que deseja cancelar o pedido #${order.publicId}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Não'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sim', style: TextStyle(color: Colors.white)),
              onPressed: () {
                context.read<OrderCubit>().updateOrderStatus(order.id, 'canceled');
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}