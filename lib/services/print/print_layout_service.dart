import 'dart:io';
import 'dart:typed_data';
import 'package:directprint/directprint.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:share_plus/share_plus.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'layouts/layout_utils.dart'; // Seu gerador de PDF, verifique o caminho
import 'layouts/mobile_kitchen_layout.dart'; // Verifique o caminho
import 'layouts/mobile_receipt_layout.dart'; // Verifique o caminho


/// Responsável APENAS por gerar os bytes ou layouts para diferentes formatos de impressão.
class PrintLayoutService {
  final _directprintPlugin = Directprint();

  /// Gera os bytes para impressão térmica direta (ESC/POS).
  Future<List<int>> generateEscPosBytes(OrderDetails order, Store store, String destination) async {
    final profile = await CapabilityProfile.load();
    // Use PaperSize.mm80 se sua impressora for de 80mm
    final generator = Generator(PaperSize.mm58, profile);

    if (destination.toLowerCase() == 'cozinha') {
      // Supondo que você tenha uma classe que gera o layout da cozinha
      return await EscposKitchenLayout.build(order, generator);
    } else {
      // Supondo que você tenha uma classe que gera o layout do recibo
      return await EscposReceiptLayout.build(order, store, generator);
    }
  }

  /// Abre o diálogo de impressão do sistema operacional (Celular/Desktop/Web).
  Future<void> printWithDialog(OrderDetails order, Store store, String destination) async {
    await Printing.layoutPdf(
      name: 'Pedido #${order.sequentialId} - ${store.core.name}',
      onLayout: (PdfPageFormat format) {
        // Supondo que você tenha uma classe com este método estático para gerar o PDF
        return PdfLayoutUtils.generateOrderPdf(order, store, destination, format);
      },
    );
  }

  /// Envia os bytes para uma impressora Bluetooth.
  Future<bool> printToBluetooth(String macAddress, List<int> ticketBytes) async {
    try {
      final bool isConnected = await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
      if (!isConnected) {
        print('[PrintLayoutService] Falha ao conectar na impressora Bluetooth $macAddress.');
        return false;
      }
      await PrintBluetoothThermal.writeBytes(ticketBytes);
      return true;
    } catch (e) {
      print('[PrintLayoutService] Erro durante a impressão Bluetooth: $e');
      return false;
    }
  }

  /// Envia os bytes diretamente para uma impressora instalada no Windows.
  Future<bool> printDirectToWindows(String printerName, List<int> ticketBytes, int orderId, String customerName) async {
    try {
      final String jobTitle = 'Pedido #${orderId} (${customerName})';
      final String? result = await _directprintPlugin.print(
        printerName,
        jobTitle,
        Uint8List.fromList(ticketBytes),
      );

      if (result == 'OK') {
        print('[PrintLayoutService] Trabalho "$jobTitle" enviado com SUCESSO.');
        return true;
      } else {
        print('[PrintLayoutService] FALHA ao enviar o trabalho "$jobTitle". Motivo: $result');
        return false;
      }
    } catch (e) {
      print('[PrintLayoutService] Erro durante a impressão com directprint: $e');
      return false;
    }
  }

  // ✅ MÉTODO ADICIONADO AQUI
  Future<void> generateAndShareOrderPdf(OrderDetails order, Store store, {bool is58mm = true}) async {
    try {
      final pdfBytes = await PdfLayoutUtils.generateOrderPdf(
        order,
        store,
        'balcao', // Pode ser qualquer destino, já que o layout é o mesmo
        is58mm ? PdfPageFormat.roll57 : PdfPageFormat.roll80,
      );

      final output = await getTemporaryDirectory();
      final file = File("${output.path}/pedido_${order.sequentialId}.pdf");
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Pedido nº ${order.sequentialId} da loja ${store.core.name}',
      );
    } catch (e) {
      print('[PrintLayoutService] Erro ao gerar e compartilhar PDF: $e');
      rethrow;
    }
  }
}