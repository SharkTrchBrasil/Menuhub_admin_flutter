import 'package:rxdart/rxdart.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/print_job.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/services/print/print_manager.dart';

// ✅ CORREÇÃO: Nome da classe ajustado de 'PrinterService' para 'PrintingService'
class PrintingService {
  final RealtimeRepository _realtimeRepo;
  final PrintManager _printManager;
  final StoresManagerCubit _storesManagerCubit;

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
    _realtimeRepo.onNewPrintJobsAvailable.listen((PrintJobPayload payload) {
      print('👨‍💼 Supervisor: Novos trabalhos de impressão recebidos para o pedido #${payload.orderId}');

      final currentState = _storesManagerCubit.state;
      if (currentState is StoresManagerLoaded) {
        final activeStore = currentState.activeStore;
        // O '.id' pode ser nulo, então ajustamos
        final order = _findOrderInState(_realtimeRepo, activeStore?.core.id, payload.orderId);

        if (activeStore != null && order != null && order.storeId == activeStore.core.id) {
          _printManager.processPrintJobs(payload, order, activeStore);
        }
      }
    });
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
}