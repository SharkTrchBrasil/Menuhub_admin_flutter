// ✅ PASSO 1: Adicione estes imports no topo do arquivo. O 'dart:typed_data' é o mais importante.
import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../models/order_details.dart';
import '../../../models/order_product.dart';
import '../../../models/store.dart';

class PdfLayoutUtils {

  static const double _printer58mmWidth = 58 * PdfPageFormat.mm;
  static const double _printer80mmWidth = 80 * PdfPageFormat.mm;

  static List<pw.Widget> buildOrderItems(
    List<OrderProduct> products,
    NumberFormat currencyFormat,
    bool is58mm,
  ) {
    final widgets = <pw.Widget>[];
    final fontSize = is58mm ? 8.0 : 9.0;
    final bold = pw.FontWeight.bold;

    for (final product in products) {
      widgets.add(
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              '${product.quantity}  ${product.name}',
              style: pw.TextStyle(fontSize: fontSize, fontWeight: bold),
            ),
            pw.Text(
              currencyFormat.format(product.price / 100),
              style: pw.TextStyle(fontSize: fontSize, fontWeight: bold),
            ),
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
                  pw.Text(
                    ' - ${option.quantity > 1 ? '${option.quantity}x ' : ''}${option.name}',
                    style: pw.TextStyle(fontSize: fontSize - 1),
                  ),

                  if (option.price > 0)
                    pw.Text(
                      currencyFormat.format(option.price / 100),
                      style: pw.TextStyle(fontSize: fontSize - 1),
                    ),
                ],
              ),
            ),
          );
        }
      }

      // Total do item com complementos
      final itemTotal =
          (product.price +
              product.variants.fold(
                0,
                (sum, v) => sum + v.options.fold(0, (s, o) => s + o.price),
              )) *
          product.quantity;

      if (product.variants.isNotEmpty) {
        widgets.add(pw.SizedBox(height: 3));
        widgets.add(
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total do item com complementos',
                style: pw.TextStyle(fontSize: fontSize - 1),
              ),
              pw.Text(
                currencyFormat.format(itemTotal / 100),
                style: pw.TextStyle(fontSize: fontSize, fontWeight: bold),
              ),
            ],
          ),
        );
      }

      // Observação do produto
      if (product.note.isNotEmpty) {
        widgets.add(pw.SizedBox(height: 3));
        widgets.add(
          pw.Text(
            'Obs: ${product.note}',
            style: pw.TextStyle(
              fontSize: fontSize - 1,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        );
      }

      widgets.add(
        pw.Padding(
          padding: pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
        ),
      );
    }

    return widgets;
  }

  static String formatPhone(String phone) {
    if (phone.length == 11) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 7)}-${phone.substring(7)}';
    } else if (phone.length == 10) {
      return '(${phone.substring(0, 2)}) ${phone.substring(2, 6)}-${phone.substring(6)}';
    }
    return phone;
  }



  static Future<Uint8List> generateOrderPdf(OrderDetails order, Store store,
      String destination, PdfPageFormat format, {bool is58mm = true}) async {
    final currencyFormat =
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    // Determina o tamanho da fonte com base no papel (A4 vs. Cupom)
    final bool isSmallPaper = format.width < 100 * PdfPageFormat.mm;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        // ✅ Usa o 'format' recebido para se adaptar ao papel do usuário.
        pageFormat: format,
        build: (pw.Context context) {
          final textStyle = pw.TextStyle(fontSize: is58mm ? 8 : 10);
          final boldStyle = pw.TextStyle(
              fontSize: is58mm ? 8 : 10, fontWeight: pw.FontWeight.bold);

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text('Pedido Nº ${order.sequentialId}',
                    style: boldStyle.copyWith(fontSize: is58mm ? 10 : 12)),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                    '${dateFormat.format(order.createdAt)} às ${timeFormat
                        .format(order.createdAt)}', style: textStyle),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text('Código: ${order.publicId}', style: textStyle),
              ),
              pw.SizedBox(height: 8),
              pw.Center(
                child: pw.Text('Loja',
                    style: boldStyle.copyWith(fontSize: is58mm ? 7 : 9)),
              ),

              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(store.name, style: textStyle),
              ),
              pw.SizedBox(height: 8),

              pw.Text('Cliente: ${order.customerName}', style: textStyle),
              pw.Text('Telefone: ${PdfLayoutUtils.formatPhone(
                  order.customerPhone)}', style: textStyle),
              pw.SizedBox(height: 8),

              if (order.deliveryType == 'delivery') ...[

                pw.Text('ENDEREÇO PARA ENTREGA',
                    style: boldStyle.copyWith(fontSize: is58mm ? 7 : 9)),
                pw.Text('${order.street}, ${order.number}', style: textStyle),
                if (order.complement != null && order.complement!.isNotEmpty)
                  pw.Text('Comp: ${order.complement}', style: textStyle),
                pw.Text(
                    '${order.neighborhood} - ${order.city}', style: textStyle),
                pw.SizedBox(height: 8),
              ],

              pw.Center(
                child: pw.Text('ITENS DO PEDIDO',
                    style: boldStyle.copyWith(fontSize: is58mm ? 8 : 10)),
              ),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              ...PdfLayoutUtils.buildOrderItems(
                  order.products, currencyFormat, is58mm),


              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Quantidade de itens:', style: textStyle),
                  pw.Text('${order.products.fold(
                      0, (sum, item) => sum + item.quantity)}',
                      style: textStyle),
                ],
              ),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: textStyle),
                  pw.Text(currencyFormat.format(order.subtotalPrice / 100),
                      style: textStyle),

                ],
              ),

              // Espaço vertical entre Subtotal e Taxa de Entrega
              // pw.SizedBox(height: 2),

              //  if (order.deliveryFee != null && order.deliveryFee! > 0)


              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Taxa de Entrega:', style: textStyle),
                  pw.Text(currencyFormat.format(order.deliveryFee! / 100),
                      style: textStyle),
                ],
              ),


              if (order.discountAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [

                    pw.Text('Desconto:', style: textStyle),
                    pw.Text(
                        '-${currencyFormat.format(order.discountAmount / 100)}',
                        style: textStyle),
                  ],
                ),

              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL:', style: boldStyle),
                  pw.Text(
                      currencyFormat.format(order.discountedTotalPrice / 100),
                      style: boldStyle),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),


              pw.Text('FORMA DE PAGAMENTO', style: boldStyle),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(PdfLayoutUtils.getPaymentMethodName(
                      order.paymentMethodName), style: textStyle),
                  pw.Text(
                      currencyFormat.format(order.discountedTotalPrice / 100),
                      style: textStyle),
                ],
              ),
              if (order.needsChange && order.changeAmount != null &&
                  order.changeAmount! > 0)
                pw.Text('Troco para: ${currencyFormat.format(
                    order.changeAmount! / 100)}', style: textStyle),

              pw.SizedBox(height: 8),
              pw.Center(child: pw.Text(store.name, style: textStyle)),
              pw.Center(child: pw.Text(
                  PdfLayoutUtils.formatPhone(store!.phone!), style: textStyle)),
            ],
          );
        },
      ),
    );

    // ✅ No final, a função retorna os bytes do PDF gerado.
    return pdf.save();
  }




  static Future<void> generateAndShareOrderPDF(OrderDetails order, Store store, {bool is58mm = true}) async {
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
                pw.Text('Telefone: ${PdfLayoutUtils.formatPhone(order.customerPhone)}', style: textStyle),
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

                ...PdfLayoutUtils.buildOrderItems(order.products, currencyFormat, is58mm),


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
                    pw.Text(PdfLayoutUtils.getPaymentMethodName(order.paymentMethodName), style: textStyle),
                    pw.Text(currencyFormat.format(order.discountedTotalPrice / 100), style: textStyle),
                  ],
                ),
                if (order.needsChange && order.changeAmount != null && order.changeAmount! > 0)
                  pw.Text('Troco para: ${currencyFormat.format(order.changeAmount! / 100)}', style: textStyle),

                pw.SizedBox(height: 8),
                pw.Center(child: pw.Text(store.name, style: textStyle)),
                pw.Center(child: pw.Text(PdfLayoutUtils.formatPhone(store.phone!), style: textStyle)),
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






























  static String getPaymentMethodName(String method) {
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
}
