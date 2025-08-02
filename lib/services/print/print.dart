import 'dart:io';
import 'dart:typed_data';

import 'package:directprint/directprint.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart';

import 'package:totem_pro_admin/services/print/printer_mapping_service.dart';


import '../../models/printer_config.dart';
import 'layouts/layout_utils.dart';
import 'layouts/mobile_kitchen_layout.dart';
import 'layouts/mobile_receipt_layout.dart';

class PrinterService {
  final PrinterMappingService _mappingService;
  final _directprintPlugin = Directprint();


  PrinterService(this._mappingService);

  // ✅ MUDANÇA 1: O retorno agora é Future<bool>
  Future<bool> printOrder(OrderDetails order, Store store,
      {required String destination}) async {
    try {
      final config = await _mappingService.getConfigForDestination(destination);
      if (config == null) {
        print(
            '[PrinterService] Nenhuma impressora configurada para o destino "$destination".');
        return false; // Retorna falha
      }

      print(
          '[PrinterService] Imprimindo para "$destination" com impressora tipo: ${config
              .type.name}');

      // ✅ MUDANÇA 2: A função agora retorna o resultado das funções filhas.
      switch (config.type) {
        case PrinterType.bluetooth:
          return await _printToBluetooth(
              config.identifier, order, store, destination);
        case PrinterType.desktop:
          return await _printDirectToWindows(
              config.identifier, order, store, destination);
      }
    } catch (e) {
      print('[PrinterService] Erro inesperado em printOrder: $e');
      return false; // Captura qualquer erro não esperado e retorna falha.
    }
  }

  // ✅ MUDANÇA 3: O retorno do método de Bluetooth agora é Future<bool>
  Future<bool> _printToBluetooth(String macAddress, OrderDetails order,
      Store store, String destination) async {
    try {
      final bool isConnected = await PrintBluetoothThermal.connect(
          macPrinterAddress: macAddress);
      if (!isConnected) {
        print(
            '[PrinterService] Falha ao conectar na impressora Bluetooth $macAddress.');
        return false; // Retorna falha
      }

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> ticketBytes;

      if (destination.toLowerCase() == 'cozinha') {
        ticketBytes = await EscposKitchenLayout.build(order, generator);
      } else {
        ticketBytes = await EscposReceiptLayout.build(order, store, generator);
      }

      await PrintBluetoothThermal.writeBytes(ticketBytes);
      // Se chegou até aqui sem erros, considera sucesso.
      return true;
    } catch (e) {
      print('[PrinterService] Erro durante a impressão Bluetooth: $e');
      return false; // Qualquer exceção resulta em falha.
    }
  }


  // ✅ PASSO 3: Substitua o conteúdo do seu método de impressão do Windows
  Future<bool> _printDirectToWindows(String printerName, OrderDetails order,
      Store store, String destination) async {
    try {
      final String jobTitle = 'Pedido #${order.id} (${order.customerName})';
      print('[PrinterService] Enviando trabalho via directprint: "$jobTitle"');

      // ... (sua lógica para gerar os ticketBytes com esc_pos_utils continua a mesma)
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      List<int> ticketBytes;

      if (destination.toLowerCase() == 'cozinha') {
        ticketBytes = await EscposKitchenLayout.build(order, generator);
      } else {
        ticketBytes = await EscposReceiptLayout.build(order, store, generator);
      }

      // ✅ PASSO 4: Chame o método do novo pacote
      final String? result = await _directprintPlugin.print(
        printerName,
        jobTitle, // Passando o nome personalizado do trabalho
        Uint8List.fromList(ticketBytes),
      );

      // A documentação diz que o retorno é "OK" em caso de sucesso.
      if (result == 'OK') {
        print('[PrinterService] Trabalho "$jobTitle" enviado com SUCESSO.');
        return true;
      } else {
        // O plugin retorna mensagens de erro como "ERROR:1", "ERROR:2", etc.
        print(
            '[PrinterService] FALHA ao enviar o trabalho "$jobTitle". Motivo: $result');
        return false;
      }
    } catch (e) {
      print('[PrinterService] Erro durante a impressão com directprint: $e');
      return false;
    }
  }


// ✅ FUNÇÃO 1: "A GERENTE" - Inicia o processo de impressão com diálogo.
  Future<void> printOrderWithDialog(OrderDetails order, Store store,
      {required String destination}) async {
    print('[PrinterService] Gerando PDF para impressão com diálogo...');
    await Printing.layoutPdf(
      name: 'Pedido #${order.id} - ${store.name}',
      // O onLayout pede à "construtora" para criar o PDF.
      // Ele também fornece o 'format' correto da impressora selecionada pelo usuário.
      onLayout: (PdfPageFormat format) {
        return PdfLayoutUtils.generateOrderPdf(order, store, destination, format);
      },
    );
  }

  Future<void> generateAndShareOrderPDF(OrderDetails order, Store store, {bool is58mm = true}) async {
    print('[PrinterService] Iniciando fluxo para gerar e compartilhar PDF...');
    try {
      // Apenas chama o método estático que já está no lugar certo (PdfLayoutUtils).
      // O PrinterService atua como um organizador/intermediário.
      await PdfLayoutUtils.generateAndShareOrderPDF(
        order,
        store,
        is58mm: is58mm,
      );
      print('[PrinterService] Fluxo de compartilhamento concluído com sucesso.');
    } catch (e) {
      print('[PrinterService] Erro capturado ao gerar e compartilhar PDF: $e');
      // Aqui você pode, opcionalmente, mostrar uma notificação de erro para o usuário
      // usando um serviço de Toast ou Dialog.
    }
  }
















}
















// import 'dart:io';
//
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:intl/intl.dart';
// import 'package:share_plus/share_plus.dart';
//
// import '../models/order_details.dart';
// import '../models/order_product.dart';
// import '../models/store.dart';
//
// class PrinterService {
//   static const double _printer58mmWidth = 58 * PdfPageFormat.mm;
//   static const double _printer80mmWidth = 80 * PdfPageFormat.mm;
//
//   Future<void> printOrder(OrderDetails order, Store store, {bool is58mm = true}) async {
//     try {
//       final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
//       final dateFormat = DateFormat('dd/MM/yyyy');
//       final timeFormat = DateFormat('HH:mm');
//       final pageWidth = is58mm ? _printer58mmWidth : _printer80mmWidth;
//
//       final pdf = pw.Document();
//
//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat(pageWidth, double.infinity, marginAll: 3 * PdfPageFormat.mm),
//           build: (pw.Context context) {
//             final textStyle = pw.TextStyle(fontSize: is58mm ? 8 : 10);
//             final boldStyle = pw.TextStyle(fontSize: is58mm ? 8 : 10, fontWeight: pw.FontWeight.bold);
//
//             return pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Center(
//                   child: pw.Text('Pedido Nº ${order.sequentialId}', style: boldStyle.copyWith(fontSize: is58mm ? 10 : 12)),
//                 ),
//                 pw.SizedBox(height: 4),
//                 pw.Center(
//                   child: pw.Text('${dateFormat.format(order.createdAt)} às ${timeFormat.format(order.createdAt)}', style: textStyle),
//                 ),
//                 pw.SizedBox(height: 4),
//                 pw.Center(
//                   child: pw.Text('Código: ${order.publicId}', style: textStyle),
//                 ),
//                 pw.SizedBox(height: 8),
//                 pw.Center(
//                   child: pw.Text('Loja',  style: boldStyle.copyWith(fontSize: is58mm ? 7 : 9)),
//                 ),
//
//                 pw.SizedBox(height: 2),
//                 pw.Center(
//                   child: pw.Text(store.name, style: textStyle),
//                 ),
//                 pw.SizedBox(height: 8),
//
//                 pw.Text('Cliente: ${order.customerName}', style: textStyle),
//                 pw.Text('Telefone: ${_formatPhone(order.customerPhone)}', style: textStyle),
//                 pw.SizedBox(height: 8),
//
//                 if (order.deliveryType == 'delivery') ...[
//
//                   pw.Text('ENDEREÇO PARA ENTREGA', style: boldStyle.copyWith(fontSize: is58mm ? 7 : 9)),
//                   pw.Text('${order.street}, ${order.number}', style: textStyle),
//                   if (order.complement != null && order.complement!.isNotEmpty)
//                     pw.Text('Comp: ${order.complement}', style: textStyle),
//                   pw.Text('${order.neighborhood} - ${order.city}', style: textStyle),
//                   pw.SizedBox(height: 8),
//                 ],
//
//                 pw.Center(
//                   child: pw.Text('ITENS DO PEDIDO', style: boldStyle.copyWith(fontSize: is58mm ? 8 : 10)),
//                 ),
//                 pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
//
//                 ..._buildOrderItems(order.products, currencyFormat, is58mm),
//
//
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text('Quantidade de itens:', style: textStyle),
//                     pw.Text('${order.products.fold(0, (sum, item) => sum + item.quantity)}', style: textStyle),
//                   ],
//                 ),
//                   pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
//                 pw.SizedBox(height: 4),
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text('Subtotal:', style: textStyle),
//                     pw.Text(currencyFormat.format(order.subtotalPrice / 100), style: textStyle),
//
//                   ],
//                 ),
//
//                 // Espaço vertical entre Subtotal e Taxa de Entrega
//                // pw.SizedBox(height: 2),
//
//                 //  if (order.deliveryFee != null && order.deliveryFee! > 0)
//
//
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//                       pw.Text('Taxa de Entrega:', style: textStyle),
//                       pw.Text(currencyFormat.format(order.deliveryFee! / 100), style: textStyle),
//                     ],
//                   ),
//
//
//
//                 if (order.discountAmount > 0)
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//
//                       pw.Text('Desconto:', style: textStyle),
//                       pw.Text('-${currencyFormat.format(order.discountAmount / 100)}', style: textStyle),
//                     ],
//                   ),
//
//                 pw.SizedBox(height: 8),
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text('TOTAL:', style: boldStyle),
//                     pw.Text(currencyFormat.format(order.discountedTotalPrice / 100), style: boldStyle),
//                   ],
//                 ),
//                 pw.SizedBox(height: 8),
//                 pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
//
//
//                 pw.Text('FORMA DE PAGAMENTO', style: boldStyle),
//                 pw.SizedBox(height: 4),
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text(_getPaymentMethodName(order.paymentMethodName), style: textStyle),
//                     pw.Text(currencyFormat.format(order.discountedTotalPrice / 100), style: textStyle),
//                   ],
//                 ),
//                 if (order.needsChange && order.changeAmount != null && order.changeAmount! > 0)
//                   pw.Text('Troco para: ${currencyFormat.format(order.changeAmount! / 100)}', style: textStyle),
//
//                 pw.SizedBox(height: 8),
//                 pw.Center(child: pw.Text(store.name, style: textStyle)),
//                 pw.Center(child: pw.Text(_formatPhone(store.phone), style: textStyle)),
//               ],
//             );
//           },
//         ),
//       );
//
//       await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
//     } catch (e) {
//       print('Erro ao imprimir: $e');
//       rethrow;
//     }
//   }
//
//
//
//   Future<void> generateAndShareOrderPDF(OrderDetails order, Store store, {bool is58mm = true}) async {
//     try {
//       final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
//       final dateFormat = DateFormat('dd/MM/yyyy');
//       final timeFormat = DateFormat('HH:mm');
//       final pageWidth = is58mm ? _printer58mmWidth : _printer80mmWidth;
//
//       final pdf = pw.Document();
//
//       pdf.addPage(
//         pw.Page(
//           pageFormat: PdfPageFormat(pageWidth, double.infinity, marginAll: 3 * PdfPageFormat.mm),
//           build: (pw.Context context) {
//             final textStyle = pw.TextStyle(fontSize: is58mm ? 8 : 10);
//             final boldStyle = pw.TextStyle(fontSize: is58mm ? 8 : 10, fontWeight: pw.FontWeight.bold);
//
//             return pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Center(
//                   child: pw.Text('Pedido Nº ${order.sequentialId}', style: boldStyle.copyWith(fontSize: is58mm ? 10 : 12)),
//                 ),
//                 pw.SizedBox(height: 4),
//                 pw.Center(
//                   child: pw.Text('${dateFormat.format(order.createdAt)} às ${timeFormat.format(order.createdAt)}', style: textStyle),
//                 ),
//                 pw.SizedBox(height: 4),
//                 pw.Center(
//                   child: pw.Text('Código: ${order.publicId}', style: textStyle),
//                 ),
//                 pw.SizedBox(height: 8),
//                 pw.Center(
//                   child: pw.Text('Loja',  style: boldStyle.copyWith(fontSize: is58mm ? 7 : 9)),
//                 ),
//
//                 pw.SizedBox(height: 2),
//                 pw.Center(
//                   child: pw.Text(store.name, style: textStyle),
//                 ),
//                 pw.SizedBox(height: 8),
//
//                 pw.Text('Cliente: ${order.customerName}', style: textStyle),
//                 pw.Text('Telefone: ${_formatPhone(order.customerPhone)}', style: textStyle),
//                 pw.SizedBox(height: 8),
//
//                 if (order.deliveryType == 'delivery') ...[
//
//                   pw.Text('ENDEREÇO PARA ENTREGA', style: boldStyle.copyWith(fontSize: is58mm ? 7 : 9)),
//                   pw.Text('${order.street}, ${order.number}', style: textStyle),
//                   if (order.complement != null && order.complement!.isNotEmpty)
//                     pw.Text('Comp: ${order.complement}', style: textStyle),
//                   pw.Text('${order.neighborhood} - ${order.city}', style: textStyle),
//                   pw.SizedBox(height: 8),
//                 ],
//
//                 pw.Center(
//                   child: pw.Text('ITENS DO PEDIDO', style: boldStyle.copyWith(fontSize: is58mm ? 8 : 10)),
//                 ),
//                 pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
//
//                 ..._buildOrderItems(order.products, currencyFormat, is58mm),
//
//
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text('Quantidade de itens:', style: textStyle),
//                     pw.Text('${order.products.fold(0, (sum, item) => sum + item.quantity)}', style: textStyle),
//                   ],
//                 ),
//                 pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
//                 pw.SizedBox(height: 4),
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text('Subtotal:', style: textStyle),
//                     pw.Text(currencyFormat.format(order.subtotalPrice / 100), style: textStyle),
//
//                   ],
//                 ),
//
//                 // Espaço vertical entre Subtotal e Taxa de Entrega
//                 // pw.SizedBox(height: 2),
//
//                 //  if (order.deliveryFee != null && order.deliveryFee! > 0)
//
//
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text('Taxa de Entrega:', style: textStyle),
//                     pw.Text(currencyFormat.format(order.deliveryFee! / 100), style: textStyle),
//                   ],
//                 ),
//
//
//
//                 if (order.discountAmount > 0)
//                   pw.Row(
//                     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                     children: [
//
//                       pw.Text('Desconto:', style: textStyle),
//                       pw.Text('-${currencyFormat.format(order.discountAmount / 100)}', style: textStyle),
//                     ],
//                   ),
//
//                 pw.SizedBox(height: 8),
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text('TOTAL:', style: boldStyle),
//                     pw.Text(currencyFormat.format(order.discountedTotalPrice / 100), style: boldStyle),
//                   ],
//                 ),
//                 pw.SizedBox(height: 8),
//                 pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
//
//
//                 pw.Text('FORMA DE PAGAMENTO', style: boldStyle),
//                 pw.SizedBox(height: 4),
//                 pw.Row(
//                   mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                   children: [
//                     pw.Text(_getPaymentMethodName(order.paymentMethodName), style: textStyle),
//                     pw.Text(currencyFormat.format(order.discountedTotalPrice / 100), style: textStyle),
//                   ],
//                 ),
//                 if (order.needsChange && order.changeAmount != null && order.changeAmount! > 0)
//                   pw.Text('Troco para: ${currencyFormat.format(order.changeAmount! / 100)}', style: textStyle),
//
//                 pw.SizedBox(height: 8),
//                 pw.Center(child: pw.Text(store.name, style: textStyle)),
//                 pw.Center(child: pw.Text(_formatPhone(store.phone), style: textStyle)),
//               ],
//             );
//           },
//         ),
//       );
//
//       // Salvar em arquivo temporário
//       final output = await getTemporaryDirectory();
//       final file = File("${output.path}/pedido_${order.sequentialId}.pdf");
//       await file.writeAsBytes(await pdf.save());
//
//       // Compartilhar
//       await Share.shareXFiles(
//         [XFile(file.path)],
//         text: 'Pedido nº ${order.sequentialId}',
//       );
//     } catch (e) {
//       print('Erro ao gerar e compartilhar PDF: $e');
//       rethrow;
//     }
//   }
//
//
//
//
//   Future<bool> checkPrinterAvailability() async {
//     // Implemente de acordo com sua biblioteca de impressão
//     return true;
//   }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//   List<pw.Widget> _buildOrderItems(List<OrderProduct> products, NumberFormat currencyFormat, bool is58mm) {
//     final widgets = <pw.Widget>[];
//     final fontSize = is58mm ? 8.0 : 9.0;
//     final bold = pw.FontWeight.bold;
//
//     for (final product in products) {
//       widgets.add(
//         pw.Row(
//           mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//           children: [
//             pw.Text('${product.quantity}  ${product.name}', style: pw.TextStyle(fontSize: fontSize, fontWeight: bold)),
//             pw.Text(currencyFormat.format(product.price / 100), style: pw.TextStyle(fontSize: fontSize, fontWeight: bold)),
//           ],
//         ),
//       );
//
//       // Variantes e opções
//       for (final variant in product.variants) {
//         for (final option in variant.options) {
//           widgets.add(
//             pw.Padding(
//               padding: pw.EdgeInsets.only(left: 8),
//               child: pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//
//                   pw.Text(
//                     ' - ${option.quantity > 1 ? '${option.quantity}x ' : ''}${option.name}',
//                     style: pw.TextStyle(fontSize: fontSize - 1),
//                   ),
//
//                   if (option.price > 0)
//                     pw.Text(currencyFormat.format(option.price / 100), style: pw.TextStyle(fontSize: fontSize - 1)),
//                 ],
//               ),
//             ),
//           );
//         }
//       }
//
//       // Total do item com complementos
//       final itemTotal = (product.price +
//           product.variants.fold(
//             0,
//                 (sum, v) => sum + v.options.fold(0, (s, o) => s + o.price),
//           )) *
//           product.quantity;
//
//       if (product.variants.isNotEmpty) {
//         widgets.add(pw.SizedBox(height: 3));
//         widgets.add(
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Text('Total do item com complementos', style: pw.TextStyle(fontSize: fontSize - 1)),
//               pw.Text(currencyFormat.format(itemTotal / 100), style: pw.TextStyle(fontSize: fontSize, fontWeight: bold)),
//             ],
//           ),
//         );
//       }
//
//       // Observação do produto
//       if (product.note.isNotEmpty) {
//         widgets.add(pw.SizedBox(height: 3));
//         widgets.add(
//           pw.Text('Obs: ${product.note}', style: pw.TextStyle(fontSize: fontSize - 1, fontStyle: pw.FontStyle.italic)),
//         );
//       }
//
//       widgets.add(
//         pw.Padding(
//           padding: pw.EdgeInsets.symmetric(vertical: 2),
//           child: pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
//         ),
//       );
//     }
//
//     return widgets;
//   }
//
//   String _formatPhone(String phone) {
//     if (phone.length == 11) {
//       return '(${phone.substring(0, 2)}) ${phone.substring(2, 7)}-${phone.substring(7)}';
//     } else if (phone.length == 10) {
//       return '(${phone.substring(0, 2)}) ${phone.substring(2, 6)}-${phone.substring(6)}';
//     }
//     return phone;
//   }
//
//   String _getPaymentMethodName(String method) {
//     switch (method.toLowerCase()) {
//       case 'credit':
//         return 'Cartão de Crédito';
//       case 'debit':
//         return 'Cartão de Débito';
//       case 'money':
//         return 'Dinheiro';
//       case 'pix':
//         return 'PIX';
//       case 'online':
//         return 'Online';
//       default:
//         return method;
//     }
//   }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
