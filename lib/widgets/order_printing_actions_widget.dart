import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart';

import '../services/print.dart';


/// Um widget reutilizável que exibe um botão com um menu de ações
/// para imprimir ou compartilhar um pedido.
class OrderPrintingActionsWidget extends StatelessWidget {
  final OrderDetails order;
  final Store store;
  final PrinterService printerService;

  // Opções para customizar quais itens do menu são exibidos
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

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      // O 'child' é o que o usuário vê como o botão principal.
      child: ElevatedButton.icon(
        onPressed: null, // Deixamos nulo para que o PopupMenuButton controle o toque.
        icon: const Icon(Icons.print),
        label: const Text('Imprimir / Ações'),
        style: ElevatedButton.styleFrom(
          // Estilo para que o botão pareça ativo mesmo estando "disabled"
          disabledBackgroundColor: Theme.of(context).colorScheme.primary,
          disabledForegroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),

      // 'onSelected' é chamado com o 'value' da opção que o usuário escolheu.
      onSelected: (String destination) {
        if (destination == 'share') {
          printerService.generateAndShareOrderPDF(order, store);
        } else {
          printerService.printOrder(
            order,
            store,
            destination: destination, // Passa o destino escolhido!
          );
        }
      },

      // 'itemBuilder' constrói a lista de opções que aparecerão no menu.
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[

        // Renderiza o item do menu apenas se a flag 'showPrintReceipt' for verdadeira
        if (showPrintReceipt)
          const PopupMenuItem<String>(
            value: 'balcao', // O destino para o recibo do cliente
            child: ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text('Imprimir Recibo do Cliente'),
            ),
          ),

        // Renderiza o item do menu apenas se 'showPrintKitchen' for verdadeira
        if (showPrintKitchen)
          const PopupMenuItem<String>(
            value: 'cozinha',
            child: ListTile(
              leading: Icon(Icons.kitchen),
              title: Text('Imprimir Via da Cozinha'),
            ),
          ),

        // Adiciona um divisor se ambas as opções de impressão e o compartilhamento estiverem ativos
        if ((showPrintReceipt || showPrintKitchen) && showShare)
          const PopupMenuDivider(),

        // Renderiza o item do menu apenas se 'showShare' for verdadeira
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