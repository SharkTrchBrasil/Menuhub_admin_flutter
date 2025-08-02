// =======================================================================
// ARQUIVO 5: services/print/layouts/mobile_kitchen_layout.dart (NOVO)
// =======================================================================
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/models/order_details.dart';

class EscposKitchenLayout {
  static Future<List<int>> build(OrderDetails order, Generator generator) async {
    List<int> bytes = [];
    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.text('COZINHA', styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size3, width: PosTextSize.size3));
    bytes += generator.text('Pedido #${order.sequentialId}', styles: const PosStyles(align: PosAlign.center, height: PosTextSize.size2));
    bytes += generator.text(DateFormat('HH:mm').format(order.createdAt), styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr();
    for (final product in order.products) {
      bytes += generator.text('${product.quantity}x ${product.name}', styles: const PosStyles(bold: true, height: PosTextSize.size2));
      if (product.note != null && product.note!.isNotEmpty) {
        bytes += generator.text('  Obs: ${product.note}', styles: const PosStyles(bold: true));
      }
      for (final variant in product.variants) {
        for (final option in variant.options) {
          bytes += generator.text('  - ${option.name}');
        }
      }
      bytes += generator.hr(ch: '-');
    }
    bytes += generator.feed(2);
    bytes += generator.cut();
    return bytes;
  }
}