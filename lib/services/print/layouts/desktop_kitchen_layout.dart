// =======================================================================
// ARQUIVO 3: services/print/layouts/desktop_kitchen_layout.dart (NOVO)
// =======================================================================
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'layout_utils.dart';

class PdfKitchenLayout {
  static const double _printer58mmWidth = 58 * PdfPageFormat.mm;
  static const double _printer80mmWidth = 80 * PdfPageFormat.mm;

  static Future<pw.Page> build(
    OrderDetails order,
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

            pw.Text('Cliente: ${order.customerName}', style: textStyle),

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
          ],
        );
      },
    );
  }
}
