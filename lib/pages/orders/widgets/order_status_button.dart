import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/pages/orders/cubit/order_page_cubit.dart';
import 'package:totem_pro_admin/services/print/print_manager.dart';

import '../../../core/di.dart';

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

    switch (order.orderStatus) {
      case 'pending':
        buttonText = 'Aceitar Pedido';
        buttonColor = Colors.green;
        // ✅ CORREÇÃO AQUI: Adicionado 'async'
        onPressed = () async {
          // 1. A atualização de status sempre acontece.
          context.read<OrderCubit>().updateOrderStatus(order.id, 'preparing');

          // 2. A CONDIÇÃO: Só imprime se a configuração for explicitamente 'false'.
          if (store?.relations.storeOperationConfig?.autoPrintOrders == false) {
            print('Impressão automática desligada. Imprimindo manualmente ao aceitar...');

            final printManager = getIt<PrintManager>();

            // O 'await' agora funciona porque a função é 'async'
            await printManager.manualPrint(
              order: order,
              store: store!,
              destination: 'cozinha', // ou 'balcao'
            );
          }
        };
        break;

      case 'preparing':
        if (order.deliveryType == 'delivery') {
          buttonText = 'Pronto para Entrega';
          buttonColor = Colors.blue;
          onPressed = () {
            context.read<OrderCubit>().updateOrderStatus(order.id, 'ready');
          };
        } else { // takeout ou dine_in
          buttonText = 'Marcar como Pronto';
          buttonColor = Colors.orange;
          onPressed = () {
            context.read<OrderCubit>().updateOrderStatus(order.id, 'ready');
          };
        }
        break;

      case 'ready':
        if (order.deliveryType == 'delivery') {
          buttonText = 'Saiu para Entrega';
          buttonColor = Colors.purple;
          onPressed = () {
            context.read<OrderCubit>().updateOrderStatus(order.id, 'on_route');
          };
        } else { // takeout ou dine_in
          buttonText = 'Marcar como Concluído';
          buttonColor = Colors.green;
          onPressed = () {
            context.read<OrderCubit>().updateOrderStatus(order.id, 'delivered');
          };
        }
        break;

      case 'on_route':
        buttonText = 'Marcar como Entregue';
        buttonColor = Colors.green.shade700;
        onPressed = () {
          context.read<OrderCubit>().updateOrderStatus(order.id, 'delivered');
        };
        break;

      case 'delivered':
        buttonText = 'Pedido Concluído';
        buttonColor = Colors.grey;
        onPressed = null;
        break;

      case 'canceled':
        buttonText = 'Pedido Cancelado';
        buttonColor = Colors.grey;
        onPressed = null;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onPressed != null)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              minimumSize: const Size(double.infinity, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onPressed,
            child: Text(
              buttonText,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        if (order.orderStatus != 'delivered' && order.orderStatus != 'canceled')
          Padding(
            padding: EdgeInsets.only(top: onPressed != null ? 8.0 : 0.0),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _showCancelDialog(context),
              child: const Text('Cancelar Pedido', style: TextStyle(color: Colors.red)),
            ),
          ),
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