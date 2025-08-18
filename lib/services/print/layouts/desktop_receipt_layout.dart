// =======================================================================
// ARQUIVO 2: services/print/layouts/desktop_receipt_layout.dart (NOVO)
// =======================================================================
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'layout_utils.dart';

class PdfReceiptLayout {
  static const double _printer58mmWidth = 58 * PdfPageFormat.mm;
  static const double _printer80mmWidth = 80 * PdfPageFormat.mm;

  static Future<pw.Page> build(
    OrderDetails order,
    Store store,
    PdfPageFormat format, {
    bool is58mm = false,
  }) async {
    final currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final pageWidth = is58mm ? _printer58mmWidth : _printer80mmWidth;

    final textStyle = pw.TextStyle(fontSize: is58mm ? 8 : 10);
    final boldStyle = pw.TextStyle(
      fontSize: is58mm ? 8 : 10,
      fontWeight: pw.FontWeight.bold,
    );

    return pw.Page(
      pageFormat: PdfPageFormat(
        pageWidth,
        double.infinity,
        marginAll: 3 * PdfPageFormat.mm,
      ),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'Pedido Nº ${order.sequentialId}',
                style: boldStyle.copyWith(fontSize: is58mm ? 10 : 12),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                '${dateFormat.format(order.createdAt)} às ${timeFormat.format(order.createdAt)}',
                style: textStyle,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text('Código: ${order.publicId}', style: textStyle),
            ),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Text(
                'Loja',
                style: boldStyle.copyWith(fontSize: is58mm ? 7 : 9),
              ),
            ),

            pw.SizedBox(height: 2),
            pw.Center(child: pw.Text(store.core.name, style: textStyle)),
            pw.SizedBox(height: 8),

            pw.Text('Cliente: ${order.customerName}', style: textStyle),
            pw.Text(
              'Telefone: ${PdfLayoutUtils.formatPhone(order.customerPhone)}',
              style: textStyle,
            ),
            pw.SizedBox(height: 8),

            if (order.deliveryType == 'delivery') ...[
              pw.Text(
                'ENDEREÇO PARA ENTREGA',
                style: boldStyle.copyWith(fontSize: is58mm ? 7 : 9),
              ),
              pw.Text('${order.street}, ${order.number}', style: textStyle),
              if (order.complement != null && order.complement!.isNotEmpty)
                pw.Text('Comp: ${order.complement}', style: textStyle),
              pw.Text(
                '${order.neighborhood} - ${order.city}',
                style: textStyle,
              ),
              pw.SizedBox(height: 8),
            ],

            pw.Center(
              child: pw.Text(
                'ITENS DO PEDIDO',
                style: boldStyle.copyWith(fontSize: is58mm ? 8 : 10),
              ),
            ),
            pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

            ...PdfLayoutUtils.buildOrderItems(
              order.products,
              currencyFormat,
              is58mm,
            ),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Quantidade de itens:', style: textStyle),
                pw.Text(
                  '${order.products.fold(0, (sum, item) => sum + item.quantity)}',
                  style: textStyle,
                ),
              ],
            ),
            pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Subtotal:', style: textStyle),
                pw.Text(
                  currencyFormat.format(order.subtotalPrice / 100),
                  style: textStyle,
                ),
              ],
            ),

            // Espaço vertical entre Subtotal e Taxa de Entrega
            // pw.SizedBox(height: 2),

            //  if (order.deliveryFee != null && order.deliveryFee! > 0)
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Taxa de Entrega:', style: textStyle),
                pw.Text(
                  currencyFormat.format(order.deliveryFee! / 100),
                  style: textStyle,
                ),
              ],
            ),

            if (order.discountAmount > 0)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Desconto:', style: textStyle),
                  pw.Text(
                    '-${currencyFormat.format(order.discountAmount / 100)}',
                    style: textStyle,
                  ),
                ],
              ),

            pw.SizedBox(height: 8),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL:', style: boldStyle),
                pw.Text(
                  currencyFormat.format(order.discountedTotalPrice / 100),
                  style: boldStyle,
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

            pw.Text('FORMA DE PAGAMENTO', style: boldStyle),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  PdfLayoutUtils.getPaymentMethodName(order.paymentMethodName),
                  style: textStyle,
                ),
                pw.Text(
                  currencyFormat.format(order.discountedTotalPrice / 100),
                  style: textStyle,
                ),
              ],
            ),
            if (order.needsChange &&
                order.changeAmount != null &&
                order.changeAmount! > 0)
              pw.Text(
                'Troco para: ${currencyFormat.format(order.changeAmount! / 100)}',
                style: textStyle,
              ),

            pw.SizedBox(height: 8),
            pw.Center(child: pw.Text(store.core.name, style: textStyle)),
            pw.Center(
              child: pw.Text(
                PdfLayoutUtils.formatPhone(store.core.phone!),
                style: textStyle,
              ),
            ),
          ],
        );
      },
    );
  }
}
