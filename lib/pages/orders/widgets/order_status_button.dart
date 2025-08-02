// lib/pages/orders/widgets/_order_status_button.dart


// lib/pages/orders/widgets/_order_status_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart'; // Importe o modelo Store
import 'package:totem_pro_admin/pages/orders/order_page_cubit.dart';

import '../../../services/print/print.dart';


class OrderStatusButton extends StatelessWidget {
  final OrderDetails order;
  // NOVO: O widget agora recebe o objeto Store diretamente.
  final Store? store;

  const OrderStatusButton({
    super.key,
    required this.order,
    required this.store, // O store agora é um parâmetro obrigatório
  });

  @override
  Widget build(BuildContext context) {
    Color buttonColor = Colors.red;
    String buttonText = '';
    VoidCallback? onPressed;

    // REMOVIDO: A busca de dados foi removida daqui.
    // final store = context.read<StoresManagerCubit>().getActiveStore()?.store;

    // Lógica para o botão principal de avanço de status
    switch (order.orderStatus) {
    // ... dentro do seu switch/case

      case 'pending':
        buttonText = 'Aceitar Pedido';
        buttonColor = Colors.green;
        onPressed = () {
          // 1. A atualização de status sempre acontece.
          context.read<OrderCubit>().updateOrderStatus(order.id, 'preparing');

          // ✅ 2. A CONDIÇÃO: Só imprime se a configuração for explicitamente 'false'.
          // A verificação `store?.storeSettings?` lida com segurança caso store ou settings sejam nulos.
          if (store?.storeSettings?.autoPrintOrders == false) {
            print('Impressão automática desligada. Imprimindo manualmente ao aceitar...');

            // Usando GetIt para pegar a instância do PrinterService (melhor prática)
            final printerService = GetIt.I<PrinterService>();

            // Chama a impressão, provavelmente para a cozinha.
            printerService.printOrder(
                order,
                store!,
                destination: 'cozinha' // ou 'balcao', dependendo do seu fluxo
            );
          }
        };
        break;

// ... resto do seu switch/case

      case 'preparing':
      // Lógica condicional baseada no tipo de pedido
        if (order.deliveryType == 'delivery') {
          buttonText = 'Pronto para Entrega'; // Direto para "out_for_delivery"
          buttonColor = Colors.blue;
          onPressed = () {
            context.read<OrderCubit>().updateOrderStatus(order.id, 'ready');
          };
        } else if (order.deliveryType == 'takeout' || order.orderType == 'dine_in') {
          buttonText = 'Marcar como Pronto'; // Para "ready"
          buttonColor = Colors.orange; // Cor diferente para 'ready'
          onPressed = () {
            context.read<OrderCubit>().updateOrderStatus(order.id, 'ready');
          };
        } else {
          // Caso um tipo de pedido desconhecido ou não gerenciado
          buttonText = 'Ação Indisponível';
          buttonColor = Colors.grey.shade300;
          onPressed = null;
        }
        break;

      case 'ready':
        if (order.deliveryType == 'delivery') {
          buttonText = 'Saiu para Entrega'; // de 'ready' para 'on_route'
          buttonColor = Colors.purple;
          onPressed = () {
            context.read<OrderCubit>().updateOrderStatus(order.id, 'on_route');
          };
        } else if (order.deliveryType == 'takeout' || order.orderType == 'dine_in') {
          buttonText = 'Marcar como Concluído'; // de 'ready' para 'delivered'
          buttonColor = Colors.green;
          onPressed = () {
            context.read<OrderCubit>().updateOrderStatus(order.id, 'delivered');
          };
        } else {
          buttonText = 'Ação Indisponível (Ready)';
          buttonColor = Colors.grey.shade300;
          onPressed = null;
        }
        break;


      case 'on_route': // Somente para 'delivery'
        if (order.deliveryType == 'delivery') {
          buttonText = 'Marcar como Entregue'; // 'out_for_delivery' para 'delivered'
          buttonColor = Colors.green.shade700;
          onPressed = () {
            context.read<OrderCubit>().updateOrderStatus(order.id, 'delivered');
          };
        } else {
          // Se um pedido não delivery acidentalmente chega aqui
          buttonText = 'Ação Indisponível (Out for Delivery)';
          buttonColor = Colors.grey.shade300;
          onPressed = null;
        }
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

      default:
        buttonText = 'Ação Indisponível';
        buttonColor = Colors.grey.shade300;
        onPressed = null;
        break;
    }

    // O restante do build do widget permanece o mesmo.
    return Column(
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
              overflow: TextOverflow.ellipsis,
              buttonText,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        // if (order.orderStatus != 'delivered' && order.orderStatus != 'canceled')
        //   Padding(
        //     padding: EdgeInsets.only(top: onPressed != null ? 8.0 : 0.0),
        //     child: OutlinedButton(
        //       style: OutlinedButton.styleFrom(
        //         side: const BorderSide(color: Colors.red),
        //         minimumSize: const Size(double.infinity, 40),
        //         shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(8),
        //         ),
        //       ),
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


















