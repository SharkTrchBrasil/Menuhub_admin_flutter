import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/services/print/print_manager.dart';


// Constantes para os destinos, para evitar erros de digitação.
class PrintDestinations {
  static const String receipt = 'balcao'; // ou 'caixa', dependendo da sua configuração
  static const String kitchen = 'cozinha';
  static const String share = 'share';
}

class OrderPrintingActionsWidget extends StatelessWidget {
  final OrderDetails order;
  final Store store;
  final bool showPrintReceipt;
  final bool showPrintKitchen;
  final bool showShare;

  const OrderPrintingActionsWidget({
    super.key,
    required this.order,
    required this.store,
    this.showPrintReceipt = true,
    this.showPrintKitchen = true,
    this.showShare = true,
  });

  /// Lida com a ação selecionada no menu.
  void _handleAction(BuildContext context, String action) async {
    // Pega os serviços necessários do GetIt
    final printManager = getIt<PrintManager>();


    // Ação de compartilhar é tratada separadamente
    if (action == PrintDestinations.share) {
      // O PrintManager agora pode ter uma função para isso, ou chamamos o layout service
      // Vamos assumir que o PrintManager tem um método para compartilhar
      await printManager.shareOrderAsPdf(order, store);
      return;
    }



      print('[Printing Actions] Usando impressão direta para o destino: $action');
      final bool success = await printManager.manualPrint(
        order: order,
        store: store,
        destination: action,
      );

      if (success && context.mounted) {
        _showSuccessSnackbar(context);
      }

  }

  /// Mostra um feedback visual de sucesso.
  void _showSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('Enviado para a impressão com sucesso!'),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.print_outlined),
      tooltip: 'Opções de Impressão',
      onSelected: (String action) => _handleAction(context, action),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (showPrintReceipt)
          const PopupMenuItem<String>(
            value: PrintDestinations.receipt,
            child: ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text('Imprimir Pedido (Via Cliente)'),
            ),
          ),
        if (showPrintKitchen)
          const PopupMenuItem<String>(
            value: PrintDestinations.kitchen,
            child: ListTile(
              leading: Icon(Icons.kitchen),
              title: Text('Imprimir Via da Cozinha'),
            ),
          ),
        if ((showPrintReceipt || showPrintKitchen) && showShare)
          const PopupMenuDivider(),
        if (showShare)
          const PopupMenuItem<String>(
            value: PrintDestinations.share,
            child: ListTile(
              leading: Icon(Icons.share),
              title: Text('Compartilhar PDF'),
            ),
          ),
      ],
    );
  }
}