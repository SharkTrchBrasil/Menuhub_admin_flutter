// =======================================================================
// ARQUIVO: services/print/print_manager.dart (Lógica de Comparação Corrigida)

import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/models/print_job.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/services/print/device_settings_service.dart';
import 'package:totem_pro_admin/services/print/print.dart';


class PrintManager {
  final RealtimeRepository _realtimeRepository;
  final PrinterService _printerService;
  final DeviceSettingsService _deviceSettingsService;
  bool _isPrinting = false;

  PrintManager._({
    required PrinterService printerService,
    required RealtimeRepository realtimeRepository,
    required DeviceSettingsService deviceSettingsService,
  })  : _printerService = printerService,
        _realtimeRepository = realtimeRepository,
        _deviceSettingsService = deviceSettingsService;

  static Future<PrintManager> create({
    required PrinterService printerService,
    required RealtimeRepository realtimeRepository,
    required DeviceSettingsService deviceSettingsService,
  }) async {
    return PrintManager._(
      printerService: printerService,
      realtimeRepository: realtimeRepository,
      deviceSettingsService: deviceSettingsService,
    );
  }

  Future<void> processPrintJobs(PrintJobPayload payload, OrderDetails order, Store store) async {
    print('[PrintManager] Processando ${payload.jobs.length} trabalho(s) de impressão para o pedido ${order.id}');

    final myDestinations = (await _deviceSettingsService.getPrinterDestinations())
        .map((e) => e.trim().toLowerCase())
        .toSet();

    if (myDestinations.isEmpty) {
      print('[PrintManager] Este dispositivo não está configurado com nenhum destino de impressão.');
      return;
    }

    print('[PrintManager] Destinos deste dispositivo: ${myDestinations.join(', ')}');

    for (final job in payload.jobs) {
      final jobDest = job.destination.trim().toLowerCase();

      bool isMatch = myDestinations.contains(jobDest);

      if (!isMatch &&
          (jobDest == 'balcao' || jobDest == 'caixa') &&
          (myDestinations.contains('balcao') || myDestinations.contains('caixa'))) {
        isMatch = true;
      }

      print('[PrintManager] Verificando Job #${job.id}: Destino do Job="$jobDest" -> Combina com algum dos meus? $isMatch');

      if (isMatch) {
        print('[PrintManager] Encontrado trabalho #${job.id} para meu destino. Tentando reivindicar...');
        final result = await _realtimeRepository.claimSpecificPrintJob(job.id);

        result.fold(
              (error) => print('[PrintManager] Falha ao reivindicar trabalho #${job.id}: $error'),
              (response) {
            // ✅ CORREÇÃO: Adicionado log para inspecionar a resposta do backend.
            print('[PrintManager DEBUG] Resposta recebida do backend: $response');

            if (response['status'] == 'claim_successful') {
              print('[PrintManager] Reivindicação para o trabalho #${job.id} BEM-SUCEDIDA. Imprimindo...');
              _executeLocalPrint(order, store, job);
            } else {
              print('[PrintManager] Reivindicação para o trabalho #${job.id} FALHOU (provavelmente já reivindicado).');
            }
          },
        );
      }
    }
  }

// Em: services/print/print_manager.dart

  Future<void> _executeLocalPrint(OrderDetails order, Store store, PrintJob job) async {
    if (_isPrinting) {
      print('[PrintManager] Impressora ocupada, aguardando para imprimir o trabalho #${job.id}...');
      await Future.delayed(const Duration(seconds: 2));
    }
    if (_isPrinting) return;

    _isPrinting = true;
    try {
      // ✅ MUDANÇA 1: Atualiza o status ANTES de tentar imprimir.
      // Isso informa a outros dispositivos que estamos tentando imprimir este job AGORA.
      await _realtimeRepository.updatePrintJobStatus(job.id, 'sent_to_printer');
      print('[PrintManager] Job #${job.id} status atualizado para SENT_TO_PRINTER.');

      // ✅ MUDANÇA 2: A função de impressão agora deve retornar um booleano de sucesso.
      final bool printSuccessful = await _printerService.printOrder(order, store, destination: job.destination);

      // ✅ MUDANÇA 3: A decisão final é baseada no retorno do serviço de impressão.
      if (printSuccessful) {
        print('[PrintManager] Impressão do Job #${job.id} BEM-SUCEDIDA. Atualizando para COMPLETED.');
        await _realtimeRepository.updatePrintJobStatus(job.id, 'completed');
      } else {
        // O serviço de impressão indicou uma falha (ex: impressora offline, sem papel).
        print('[PrintManager] FALHA na impressão do Job #${job.id} (retorno do serviço). Atualizando para FAILED.');
        await _realtimeRepository.updatePrintJobStatus(job.id, 'failed');
      }
    } catch (e) {
      // Erro de conexão ou exceção inesperada.
      print('[PrintManager] Erro na impressão do trabalho #${job.id}: $e');
      await _realtimeRepository.updatePrintJobStatus(job.id, 'failed');
    } finally {
      _isPrinting = false;
    }
  }
}
