// =======================================================================
// ARQUIVO 4: services/print/layouts/mobile_receipt_layout.dart (NOVO)
// =======================================================================
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store/store.dart';

class EscposReceiptLayout {
  static Future<List<int>> build(
      OrderDetails order, Store store, Generator generator) async {
    List<int> bytes = [];
    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.text(store.core.name, styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2));
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Pedido #${order.sequentialId}', width: 6),
      PosColumn(text: DateFormat('dd/MM HH:mm').format(order.createdAt), width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    bytes += generator.text('Cliente: ${order.customerName}');
    bytes += generator.hr();
    for (final product in order.products) {
      bytes += generator.text('${product.quantity}x ${product.name}', styles: const PosStyles(bold: true));
      for (final variant in product.variants) {
        for (final option in variant.options) {
          bytes += generator.text('  - ${option.name}');
        }
      }
    }
    bytes += generator.hr();
    bytes += generator.row([
      PosColumn(text: 'Total', width: 6, styles: const PosStyles(bold: true, height: PosTextSize.size2)),
      PosColumn(text: 'R\$ ${(order.totalPrice / 100).toStringAsFixed(2)}', width: 6, styles: const PosStyles(align: PosAlign.right, bold: true, height: PosTextSize.size2)),
    ]);
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }
}