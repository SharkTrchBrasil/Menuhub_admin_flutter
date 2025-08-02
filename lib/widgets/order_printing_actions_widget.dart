// Em: widgets/OrderPrintingActionsWidget.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/di.dart';

import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart';
import '../services/print/constants/print_destinations.dart';
import '../services/print/print.dart';
import '../services/subscription/subscription_service.dart';

class OrderPrintingActionsWidget extends StatelessWidget {
  final OrderDetails order;
  final Store store;
  final PrinterService printerService;
  final bool showPrintReceipt;
  final bool showPrintKitchen;
  final bool showShare;

  const OrderPrintingActionsWidget({
    super.key,
    required this.order,
    required this.store,
    required this.printerService,
    this.showPrintReceipt = true,
    this.showPrintKitchen = true,
    this.showShare = true,
  });

  // ✅ PASSO 1: Criamos um método 'async' para lidar com a lógica.
  // Isso mantém o 'build' e o 'onSelected' síncronos e limpos.
  void _handlePrintAction(BuildContext context, String destination) async {
    final accessControl = getIt<AccessControlService>();
    final canPrintDirectly = accessControl.canAccess('auto_printing');

    if (destination == 'share') {
      printerService.generateAndShareOrderPDF(order, store);
    } else {
      if (canPrintDirectly) {
        print('[Printing Actions] Usando impressão direta para o destino: $destination');

        // ✅ PASSO 2: Usamos 'await' para esperar o resultado da impressão.
        final bool success = await printerService.printOrder(
          order,
          store,
          destination: destination,
        );

        // ✅ PASSO 3: Se a impressão foi bem-sucedida, mostramos o SnackBar.
        // A verificação 'context.mounted' é uma boa prática de segurança.
        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Enviado para a impressão com sucesso!'),
                ],
              ),
              backgroundColor: Colors.green[700], // Cor verde, como pedido
              behavior: SnackBarBehavior.floating, // Estilo moderno
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
            ),
          );
        }

      } else {
        print('[Printing Actions] Usando diálogo de impressão do sistema para o destino: $destination');
        // A impressão com diálogo não retorna um status, então não mostramos o snackbar aqui.
        printerService.printOrderWithDialog(
          order,
          store,
          destination: destination,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.print_outlined),
      tooltip: 'Opções de Impressão',

      // ✅ PASSO 4: O 'onSelected' agora simplesmente chama nosso método assíncrono.
      onSelected: (String destination) => _handlePrintAction(context, destination),

      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (showPrintReceipt)
          const PopupMenuItem<String>(
            value: PrintDestinations.counter,
            child: ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text('Imprimir Pedido'),
            ),
          ),
        if (showPrintKitchen)
          const PopupMenuItem<String>(
            value: PrintDestinations.kitchen,
            child: ListTile(
              leading: Icon(Icons.kitchen),
              title: Text('Imprimir Via Resumida'),
            ),
          ),
        if ((showPrintReceipt || showPrintKitchen) && showShare)
          const PopupMenuDivider(),
        if (showShare)
          const PopupMenuItem<String>(
            value: 'share',
            child: ListTile(
              leading: Icon(Icons.share),
              title: Text('Compartilhar PDF'),
            ),
          ),
      ],
    );
  }
}