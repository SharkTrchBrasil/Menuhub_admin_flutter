import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../models/order_details.dart';
import '../models/order_product.dart';
import '../models/store.dart';

class PrinterService {
  static const double _printer58mmWidth = 58 * PdfPageFormat.mm;
  static const double _printer80mmWidth = 80 * PdfPageFormat.mm;

  // ===========================================================================
  // 1. MÉTODO PRINCIPAL ATUALIZADO (O ROTEADOR)
  // ===========================================================================
  /// Este é o ponto de entrada principal. Ele recebe o destino e decide qual
  /// layout de PDF construir antes de enviar para a impressora.
  Future<void> printOrder(
      OrderDetails order,
      Store store, {
        required String destination,
        bool is58mm = true,
      }) async {
    try {
      final pdf = pw.Document();
      final pageWidth = is58mm ? _printer58mmWidth : _printer80mmWidth;
      final pageFormat = PdfPageFormat(pageWidth, double.infinity, marginAll: 3 * PdfPageFormat.mm);

      // Usamos um switch para decidir qual layout construir
      switch (destination.toLowerCase()) {
        case 'cozinha':
          pdf.addPage(_buildKitchenTicket(order, store, pageFormat, is58mm));
          break;
        case 'balcao':
        case 'caixa':
        default: // Se o destino não for reconhecido, imprime o recibo completo como padrão
          pdf.addPage(_buildFullReceipt(order, store, pageFormat, is58mm));
          break;
      }

      await Printing.layoutPdf(onLayout: (_) async => pdf.save());
      print('Impressão para o destino "$destination" enviada com sucesso.');

    } catch (e) {
      print('Erro ao imprimir para o destino "$destination": $e');
      rethrow;
    }
  }

  // ===========================================================================
  // 2. MÉTODOS DE BUILD PARA CADA TIPO DE CUPOM
  // ===========================================================================

  /// Constrói o layout completo do recibo para o cliente (destino: Balcão/Caixa).
  pw.Page _buildFullReceipt(OrderDetails order, Store store, PdfPageFormat pageFormat, bool is58mm) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return pw.Page(
      pageFormat: pageFormat,
      build: (pw.Context context) {
        final textStyle = pw.TextStyle(fontSize: is58mm ? 8 : 10);
        final boldStyle = pw.TextStyle(fontSize: is58mm ? 8 : 10, fontWeight: pw.FontWeight.bold);

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildHeader(order, store, is58mm),
            pw.Text('Cliente: ${order.customerName}', style: textStyle),
            pw.Text('Telefone: ${_formatPhone(order.customerPhone)}', style: textStyle),
            pw.SizedBox(height: 8),

            if (order.deliveryType == 'delivery') ...[
              _buildAddress(order, is58mm),
            ],

            pw.Center(
              child: pw.Text('ITENS DO PEDIDO', style: boldStyle.copyWith(fontSize: is58mm ? 8 : 10)),
            ),
            pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

            // ✅ AQUI A MÁGICA: Mostramos os itens COM PREÇO
            ..._buildOrderItems(order.products, currencyFormat, is58mm, showPrices: true),

            _buildTotals(order, currencyFormat, is58mm),
            pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
            _buildPaymentInfo(order, currencyFormat, is58mm),
            _buildFooter(store, is58mm),
          ],
        );
      },
    );
  }

  /// Constrói um layout simplificado para a cozinha (sem preços, sem endereço).
  pw.Page _buildKitchenTicket(OrderDetails order, Store store, PdfPageFormat pageFormat, bool is58mm) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return pw.Page(
      pageFormat: pageFormat,
      build: (pw.Context context) {
        final textStyle = pw.TextStyle(fontSize: is58mm ? 9 : 11);
        final boldStyle = pw.TextStyle(fontSize: is58mm ? 10 : 12, fontWeight: pw.FontWeight.bold);

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(child: pw.Text('Pedido Nº ${order.sequentialId}', style: boldStyle.copyWith(fontSize: is58mm ? 12: 14))),
            pw.Center(child: pw.Text('${DateFormat('HH:mm').format(order.createdAt)}', style: textStyle)),
            pw.SizedBox(height: 8),

            pw.Text('Cliente: ${order.customerName}', style: textStyle),
            pw.Text('Tipo: ${order.deliveryType == 'delivery' ? 'ENTREGA' : 'RETIRADA'}', style: boldStyle),
            pw.SizedBox(height: 8),

            pw.Center(child: pw.Text('ITENS PARA PREPARO', style: boldStyle)),
            pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

            // ✅ AQUI A MÁGICA: Mostramos os itens SEM PREÇO
            ..._buildOrderItems(order.products, currencyFormat, is58mm, showPrices: false),

            if (order.observation != null && order.observation!.isNotEmpty) ...[
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),
              pw.Text('OBSERVAÇÃO GERAL:', style: boldStyle),
              pw.Text(order.observation!, style: textStyle),
            ]
          ],
        );
      },
    );
  }

  // ===========================================================================
  // 3. COMPONENTES REUTILIZÁVEIS PARA OS LAYOUTS
  // ===========================================================================

  /// Helper para construir a lista de itens, agora com a opção de mostrar ou não os preços.
  List<pw.Widget> _buildOrderItems(List<OrderProduct> products, NumberFormat currencyFormat, bool is58mm, {required bool showPrices}) {
    final widgets = <pw.Widget>[];
    final fontSize = is58mm ? 8.0 : 9.0;
    final bold = pw.FontWeight.bold;
    final kitchenFontSize = is58mm ? 9.0 : 10.0;

    for (final product in products) {
      widgets.add(
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text('${product.quantity}x ${product.name}', style: pw.TextStyle(fontSize: showPrices ? fontSize : kitchenFontSize, fontWeight: bold)),
            ),
            if (showPrices)
              pw.Text(currencyFormat.format(product.price / 100), style: pw.TextStyle(fontSize: fontSize, fontWeight: bold)),
          ],
        ),
      );

      // Variantes e opções
      for (final variant in product.variants) {
        for (final option in variant.options) {
          widgets.add(
            pw.Padding(
              padding: pw.EdgeInsets.only(left: 8),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(' - ${option.quantity > 1 ? '${option.quantity}x ' : ''}${option.name}', style: pw.TextStyle(fontSize: (showPrices ? fontSize : kitchenFontSize) - 1)),
                  ),
                  if (showPrices && option.price > 0)
                    pw.Text(currencyFormat.format(option.price / 100), style: pw.TextStyle(fontSize: fontSize - 1)),
                ],
              ),
            ),
          );
        }
      }

      // Observação do produto
      if (product.note.isNotEmpty) {
        widgets.add(pw.SizedBox(height: 3));
        widgets.add(
            pw.Padding(
              padding: pw.EdgeInsets.only(left: 8),
              child: pw.Text('Obs: ${product.note}', style: pw.TextStyle(fontSize: (showPrices ? fontSize : kitchenFontSize) - 1, fontStyle: pw.FontStyle.italic)),
            )
        );
      }
      widgets.add(pw.Padding(padding: pw.EdgeInsets.symmetric(vertical: 2), child: pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed)));
    }
    return widgets;
  }


  String _formatPhone(String phone) {
    if (phone.length == 11) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 7)}-${phone.substring(7)}';
    } else if (phone.length == 10) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 6)}-${phone.substring(6)}';
    }
    return phone;
  }

  String _getPaymentMethodName(String method) {
    switch (method.toLowerCase()) {
      case 'credit':
        return 'Cartão de Crédito';
      case 'debit':
        return 'Cartão de Débito';
      case 'money':
        return 'Dinheiro';
      case 'pix':
        return 'PIX';
      case 'online':
        return 'Online';
      default:
        return method;
    }
  }



  // --- Outros helpers que podem ser extraídos para limpar o código ---
  pw.Widget _buildHeader(OrderDetails order, Store store, bool is58mm) {
    final textStyle = pw.TextStyle(fontSize: is58mm ? 8 : 10);
    final boldStyle = pw.TextStyle(fontSize: is58mm ? 8 : 10, fontWeight: pw.FontWeight.bold);
    return pw.Column(children: [ /* ... Cole aqui o código do cabeçalho ... */ ]);
  }
  pw.Widget _buildAddress(OrderDetails order, bool is58mm) { /* ... */ return pw.SizedBox(); }
  pw.Widget _buildTotals(OrderDetails order, NumberFormat currencyFormat, bool is58mm) { /* ... */ return pw.SizedBox(); }
  pw.Widget _buildPaymentInfo(OrderDetails order, NumberFormat currencyFormat, bool is58mm) { /* ... */ return pw.SizedBox(); }
  pw.Widget _buildFooter(Store store, bool is58mm) { /* ... */ return pw.SizedBox(); }

  Future<void> generateAndShareOrderPDF(OrderDetails order, Store store, {bool is58mm = true}) async {
    try {
      final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
      final dateFormat = DateFormat('dd/MM/yyyy');
      final timeFormat = DateFormat('HH:mm');
      final pageWidth = is58mm ? _printer58mmWidth : _printer80mmWidth;

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(pageWidth, double.infinity, marginAll: 3 * PdfPageFormat.mm),
          build: (pw.Context context) {
            final textStyle = pw.TextStyle(fontSize: is58mm ? 8 : 10);
            final boldStyle = pw.TextStyle(fontSize: is58mm ? 8 : 10, fontWeight: pw.FontWeight.bold);

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text('Pedido Nº ${order.sequentialId}', style: boldStyle.copyWith(fontSize: is58mm ? 10 : 12)),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text('${dateFormat.format(order.createdAt)} às ${timeFormat.format(order.createdAt)}', style: textStyle),
                ),
                pw.SizedBox(height: 4),
                pw.Center(
                  child: pw.Text('Código: ${order.publicId}', style: textStyle),
                ),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text('Loja',  style: boldStyle.copyWith(fontSize: is58mm ? 7 : 9)),
                ),

                pw.SizedBox(height: 2),
                pw.Center(
                  child: pw.Text(store.name, style: textStyle),
                ),
                pw.SizedBox(height: 8),

                pw.Text('Cliente: ${order.customerName}', style: textStyle),
                pw.Text('Telefone: ${_formatPhone(order.customerPhone)}', style: textStyle),
                pw.SizedBox(height: 8),

                if (order.deliveryType == 'delivery') ...[

                  pw.Text('ENDEREÇO PARA ENTREGA', style: boldStyle.copyWith(fontSize: is58mm ? 7 : 9)),
                  pw.Text('${order.street}, ${order.number}', style: textStyle),
                  if (order.complement != null && order.complement!.isNotEmpty)
                    pw.Text('Comp: ${order.complement}', style: textStyle),
                  pw.Text('${order.neighborhood} - ${order.city}', style: textStyle),
                  pw.SizedBox(height: 8),
                ],

                pw.Center(
                  child: pw.Text('ITENS DO PEDIDO', style: boldStyle.copyWith(fontSize: is58mm ? 8 : 10)),
                ),
                pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

                ..._buildOrderItems(order.products, currencyFormat, is58mm,showPrices: true ),


                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Quantidade de itens:', style: textStyle),
                    pw.Text('${order.products.fold(0, (sum, item) => sum + item.quantity)}', style: textStyle),
                  ],
                ),
                pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Subtotal:', style: textStyle),
                    pw.Text(currencyFormat.format(order.subtotalPrice / 100), style: textStyle),

                  ],
                ),

                // Espaço vertical entre Subtotal e Taxa de Entrega
                // pw.SizedBox(height: 2),

                //  if (order.deliveryFee != null && order.deliveryFee! > 0)


                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Taxa de Entrega:', style: textStyle),
                    pw.Text(currencyFormat.format(order.deliveryFee! / 100), style: textStyle),
                  ],
                ),



                if (order.discountAmount > 0)
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [

                      pw.Text('Desconto:', style: textStyle),
                      pw.Text('-${currencyFormat.format(order.discountAmount / 100)}', style: textStyle),
                    ],
                  ),

                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL:', style: boldStyle),
                    pw.Text(currencyFormat.format(order.discountedTotalPrice / 100), style: boldStyle),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),


                pw.Text('FORMA DE PAGAMENTO', style: boldStyle),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(_getPaymentMethodName(order.paymentMethodName), style: textStyle),
                    pw.Text(currencyFormat.format(order.discountedTotalPrice / 100), style: textStyle),
                  ],
                ),
                if (order.needsChange && order.changeAmount != null && order.changeAmount! > 0)
                  pw.Text('Troco para: ${currencyFormat.format(order.changeAmount! / 100)}', style: textStyle),

                pw.SizedBox(height: 8),
                pw.Center(child: pw.Text(store.name, style: textStyle)),
                pw.Center(child: pw.Text(_formatPhone(store.phone), style: textStyle)),
              ],
            );
          },
        ),
      );

      // Salvar em arquivo temporário
      final output = await getTemporaryDirectory();
      final file = File("${output.path}/pedido_${order.sequentialId}.pdf");
      await file.writeAsBytes(await pdf.save());

      // Compartilhar
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Pedido nº ${order.sequentialId}',
      );
    } catch (e) {
      print('Erro ao gerar e compartilhar PDF: $e');
      rethrow;
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
// }
