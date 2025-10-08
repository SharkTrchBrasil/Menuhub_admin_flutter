import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/print_job.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/services/print/print_manager.dart';

class PrintingService {
  final RealtimeRepository _realtimeRepo;
  final PrintManager _printManager;
  final StoresManagerCubit _storesManagerCubit;


  StreamSubscription<PrintJobPayload>? _printJobsSubscription;

  PrintingService({
    required RealtimeRepository realtimeRepo,
    required PrintManager printManager,
    required StoresManagerCubit storesManagerCubit,
  })  : _realtimeRepo = realtimeRepo,
        _printManager = printManager,
        _storesManagerCubit = storesManagerCubit;

  void initialize() {
    print('🚀 Iniciando o serviço de ouvinte de impressão...');
    _setupPrintingListener();
  }

  void _setupPrintingListener() {
    _printJobsSubscription = _realtimeRepo.onNewPrintJobsAvailable.listen((PrintJobPayload payload) {
      print('👨‍💼 Supervisor: Novos trabalhos de impressão recebidos para o pedido #${payload.orderId}');

      final currentState = _storesManagerCubit.state;
      if (currentState is StoresManagerLoaded) {
        final activeStore = currentState.activeStore;
        final order = _findOrderInState(_realtimeRepo, activeStore?.core.id, payload.orderId);

        if (activeStore != null && order != null && order.storeId == activeStore.core.id) {
          _printManager.processPrintJobs(payload, order, activeStore);
        }
      }
    });

    print('✅ Listener de impressão configurado e ativo');
  }

  OrderDetails? _findOrderInState(RealtimeRepository repo, int? storeId, int orderId) {
    if (storeId == null) return null;
    final ordersStream = repo.listenToOrders(storeId);
    if (ordersStream is BehaviorSubject<List<OrderDetails>>) {
      final currentOrders = ordersStream.value;
      try {
        return currentOrders.firstWhere((o) => o.id == orderId);
      } catch (e) {
        return null; // Pedido não encontrado
      }
    }
    return null;
  }

  // ♻️ CORREÇÃO: Método agora é assíncrono e retorna um Future.
  Future<void> stopPolling() async {
    print('🛑 Parando serviço de impressão...');

    // 🔑 O cancelamento de subscription retorna um Future, então usamos await.
    await _printJobsSubscription?.cancel();
    _printJobsSubscription = null;

    print('✅ Serviço de impressão parado com sucesso');
  }

  // ♻️ CORREÇÃO: Método agora é assíncrono.
  Future<void> restartPolling() async {
    print('🔄 Reiniciando serviço de impressão...');

    await stopPolling();
    initialize();

    print('✅ Serviço de impressão reiniciado com sucesso');
  }

  // ♻️ CORREÇÃO: Método agora é assíncrono.
  Future<void> dispose() async {
    print('🧹 Disposando PrintingService...');
    await stopPolling(); //
    print('✅ PrintingService disposado');
  }

  bool get isActive => _printJobsSubscription != null && !_printJobsSubscription!.isPaused;
}