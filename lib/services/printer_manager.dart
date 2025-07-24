import 'dart:async';
import 'package:either_dart/either.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/services/print.dart';

// Imports necessários
import '../models/print_job.dart';
import '../repositories/realtime_repository.dart';
import 'device_settings_service.dart'; // Importe o novo serviço

class PrintManager {
  final RealtimeRepository _realtimeRepository;
  final PrinterService _printerService;
  final DeviceSettingsService _deviceSettingsService; // ✅ Nova dependência
  bool _isPrinting = false;

  PrintManager._({
    required PrinterService printerService,
    required RealtimeRepository realtimeRepository,
    required DeviceSettingsService deviceSettingsService, // ✅ Nova dependência
  })  : _printerService = printerService,
        _realtimeRepository = realtimeRepository,
        _deviceSettingsService = deviceSettingsService;

  static Future<PrintManager> create({
    required PrinterService printerService,
    required RealtimeRepository realtimeRepository,
    required DeviceSettingsService deviceSettingsService, // ✅ Nova dependência
  }) async {
    return PrintManager._(
      printerService: printerService,
      realtimeRepository: realtimeRepository,
      deviceSettingsService: deviceSettingsService,
    );
  }

  /// Este é o método principal para a impressão automática backend-driven.
  Future<void> processPrintJobs(PrintJobPayload payload, OrderDetails order, Store store) async {
    print('[PrintManager] Processando ${payload.jobs.length} trabalho(s) de impressão para o pedido ${order.id}');

    // 1. Descobre qual é a identidade deste dispositivo.
    final myDestination = _deviceSettingsService.getPrinterDestination();
    if (myDestination == null || myDestination.isEmpty) {
      print('[PrintManager] Este dispositivo não está configurado como uma estação de impressão.');
      return;
    }

    print('[PrintManager] Este dispositivo é responsável pelo destino: "$myDestination"');

    // 2. Itera sobre os trabalhos enviados pelo backend.
    for (final job in payload.jobs) {
      // 3. Verifica se o trabalho é para este dispositivo.
      if (job.destination == myDestination) {
        print('[PrintManager] Encontrado trabalho #${job.id} para meu destino. Tentando reivindicar...');

        // 4. Tenta reivindicar o trabalho específico no backend.
        final result = await _realtimeRepository.claimSpecificPrintJob(job.id);

        result.fold(
              (error) => print('[PrintManager] Falha ao reivindicar trabalho #${job.id}: $error'),
              (response) {
            if (response['status'] == 'claim_successful') {
              // 5. Venceu a corrida! Executa a impressão local.
              print('[PrintManager] Reivindicação para o trabalho #${job.id} BEM-SUCEDIDA. Imprimindo...');
              _executeLocalPrint(order, store, destination: job.destination);
            } else {
              // Outro dispositivo configurado para a MESMA impressora foi mais rápido.
              print('[PrintManager] Reivindicação para o trabalho #${job.id} FALHOU (provavelmente já reivindicado).');
            }
          },
        );
      }
    }
  }

  /// Método privado que executa a impressão física.
  Future<void> _executeLocalPrint(OrderDetails order, Store store, {required String destination}) async {
    if (_isPrinting) {
      print('[PrintManager] Impressora ocupada, aguardando para imprimir em "$destination"...');
      await Future.delayed(const Duration(seconds: 2));
    }
    if (_isPrinting) return; // Checa de novo após a espera

    _isPrinting = true;
    try {
      await _printerService.printOrder(order, store, destination: destination);
      // Opcional: Após imprimir, você pode notificar o backend que o job foi 'completed'.
      // _realtimeRepository.updatePrintJobStatus(job.id, 'completed');
    } catch (e) {
      print('[PrintManager] Erro na impressão local para o destino "$destination": $e');
      // Opcional: Notificar o backend que o job 'failed'.
      // _realtimeRepository.updatePrintJobStatus(job.id, 'failed');
    } finally {
      _isPrinting = false;
    }
  }

// O método 'processOrder' foi removido para evitar confusão. A lógica de impressão
// manual agora deve ser feita por um método separado, como 'manualPrint'.
}