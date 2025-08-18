import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/print_job.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/services/print/printer_mapping_service.dart';
import 'package:totem_pro_admin/services/print/print_layout_service.dart';

import '../../models/printer_config.dart';

class PrintManager {
  final PrinterMappingService _mappingService;
  final PrintLayoutService _layoutService;

  PrintManager(this._mappingService, this._layoutService);

  Future<void> processPrintJobs(PrintJobPayload payload, OrderDetails order, Store store) async {
    print('🖨️ PrintManager: Processando ${payload.jobs.length} trabalho(s) para o pedido #${order.id}');

    for (final job in payload.jobs) {
      final destination = job.destination;
      final config = await _mappingService.getConfigForDestination(destination);

      if (config == null) {
        print('[PrintManager] Nenhuma impressora configurada para o destino "$destination". Pulando.');
        continue;
      }

      print('[PrintManager] Imprimindo para "$destination" com impressora tipo: ${config.type.name}');

      switch (config.type) {
        case PrinterType.dialog:
          await _layoutService.printWithDialog(order, store, destination);
          break;
        case PrinterType.bluetooth:
          final bytes = await _layoutService.generateEscPosBytes(order, store, destination);
          await _layoutService.printToBluetooth(config.identifier, bytes);
          break;
        case PrinterType.desktop:
          final bytes = await _layoutService.generateEscPosBytes(order, store, destination);
          final customerName = order.customerName ?? 'Cliente';
          await _layoutService.printDirectToWindows(config.identifier, bytes, order.id, customerName);
          break;
      }
    }
  }

  /// ✅ NOVO: Inicia uma impressão MANUAL para um destino específico.
  /// Retorna 'true' em caso de sucesso na impressão direta.
  Future<bool> manualPrint({required OrderDetails order, required Store store, required String destination}) async {
    final config = await _mappingService.getConfigForDestination(destination);
    if (config == null) {
      print('[PrintManager] Nenhuma impressora configurada para o destino "$destination".');
      // Se não houver impressora direta, abre o diálogo do sistema como fallback
      await printWithDialog(order: order, store: store, destination: destination);
      return false; // Indica que não foi uma impressão direta bem-sucedida
    }

    print('[PrintManager] Imprimindo para "$destination" com impressora tipo: ${config.type.name}');

    switch (config.type) {
      case PrinterType.dialog:
        await printWithDialog(order: order, store: store, destination: destination);
        return false;
      case PrinterType.bluetooth:
        final bytes = await _layoutService.generateEscPosBytes(order, store, destination);
        return await _layoutService.printToBluetooth(config.identifier, bytes);
      case PrinterType.desktop:
        final bytes = await _layoutService.generateEscPosBytes(order, store, destination);
        final customerName = order.customerName ?? 'Cliente';
        return await _layoutService.printDirectToWindows(config.identifier, bytes, order.id, customerName);
    }
  }

  /// ✅ NOVO: Exclusivo para impressão via diálogo do sistema.
  Future<void> printWithDialog({required OrderDetails order, required Store store, required String destination}) async {
    await _layoutService.printWithDialog(order, store, destination);
  }

  /// ✅ NOVO: Exclusivo para gerar e compartilhar PDF.
  Future<void> shareOrderAsPdf(OrderDetails order, Store store) async {
    await _layoutService.generateAndShareOrderPdf(order, store);
  }




}