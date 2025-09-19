import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart';

import '../cubit/order_page_cubit.dart';

class ReprintButton extends StatelessWidget {
  final OrderDetails order;
  final Store store;

  const ReprintButton({
    super.key,
    required this.order,
    required this.store,
  });

  @override
  Widget build(BuildContext context) {
    // Lógica para decidir se o botão deve aparecer
    final hasFailedJobs = order.printLogs.any((log) => log.status == 'failed');
    final needsManualPrint = store.relations.storeOperationConfig!.autoPrintOrders &&
        order.printLogs.any((log) => log.status == 'pending');

    // Se não houver falhas e a impressão automática estiver ligada, não mostra nada.
    if (!hasFailedJobs && !needsManualPrint) {
      return const SizedBox.shrink(); // Retorna um widget vazio
    }

    // Define o texto e a cor do botão com base na prioridade (falha é mais importante)
    final String buttonText = hasFailedJobs ? 'Reimprimir' : 'Imprimir';
    final Color buttonColor = hasFailedJobs ? Colors.red : Theme.of(context).primaryColor;
    final IconData buttonIcon = hasFailedJobs ? Icons.warning_amber_rounded : Icons.print_outlined;

    return TextButton.icon(
      icon: Icon(buttonIcon, color: buttonColor, size: 20),
      label: Text(
        buttonText,
        style: TextStyle(color: buttonColor, fontWeight: FontWeight.bold),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: buttonColor.withOpacity(0.5)),
        ),
      ),
      onPressed: () {
        // Chama o método do cubit para iniciar a reimpressão
        context.read<OrderCubit>().reprintOrder(order);
      },
    );
  }
}