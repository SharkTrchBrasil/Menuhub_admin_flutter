// Em: cubits/order_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store/store.dart';

import 'package:totem_pro_admin/pages/orders/utils/order_helpers.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

import 'package:totem_pro_admin/pages/orders/cubit/order_page_state.dart';

import '../../../core/utils/platform_utils.dart';
import '../../../core/utils/sounds/sound_util.dart';
import '../../../models/print_job.dart';
import '../../../services/notification_service.dart';
import '../../../services/print/print_manager.dart';

class OrderCubit extends Cubit<OrderState> {
  final RealtimeRepository _realtimeRepository;
  final StoresManagerCubit _storesManagerCubit;
  final PrintManager _printManager;

  // ✅ Novo campo para rastrear impressões manuais pendentes
  int _pendingManualPrintsCount = 0;

  StreamSubscription? _connectionSubscription;

  StreamSubscription? _storesManagerSubscription;
  StreamSubscription<List<OrderDetails>>? _ordersSubscription;

  List<OrderDetails> _ordersCache = [];
  OrderFilter _currentFilter = OrderFilter.all;
  String? _lastNotifiedOrderId;

  OrderCubit({
    required RealtimeRepository realtimeRepository,
    required StoresManagerCubit storesManagerCubit,
    required PrintManager printManager,
  })  : _realtimeRepository = realtimeRepository,
        _storesManagerCubit = storesManagerCubit,
        _printManager = printManager,
        super(const OrdersInitial()) {
    // NOVO: Assim que o Cubit é criado, ele começa a ouvir o status da conexão.
    _listenToConnectionStatus();
    _subscribeToStoresManager();
  }


  void _listenToConnectionStatus() {
    _connectionSubscription = _realtimeRepository.isConnectedStream.listen((isConnected) {
      final currentState = state;
      if (currentState is OrdersLoaded) {
        // Se já temos pedidos na tela, apenas atualizamos o status da conexão.
        emit(currentState.copyWith(isConnected: isConnected));
        print('[OrdersCubit] Status da conexão alterado para: $isConnected');
      } else if (isConnected) {
        // Se não tínhamos pedidos E a conexão foi estabelecida, buscamos os pedidos.
        print('[OrdersCubit] Conexão estabelecida. Buscando pedidos...');
        fetchOrders();
      }
    });
  }






  Future<void> fetchOrders() async {
    emit(OrdersLoading());
    try {
      // Sua lógica para buscar os pedidos aqui...
      // Ex: final orders = await _ordersRepository.getOrders();
      // emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError('Falha ao buscar pedidos.'));
    }
  }

  void _subscribeToStoresManager() {
    _storesManagerSubscription = _storesManagerCubit.stream.listen((state) {
      if (state is StoresManagerLoaded) {
        _subscribeToOrdersForStore(state.activeStoreId);
      } else if (state is StoresManagerEmpty) {
        emit(const OrdersEmpty(message: "Nenhuma loja disponível."));
        _ordersSubscription?.cancel();
        _ordersCache = [];
      } else if (state is! StoresManagerLoaded) {
        emit(const OrdersLoading());
      }
    });

    final initialState = _storesManagerCubit.state;
    if (initialState is StoresManagerLoaded) {
      _subscribeToOrdersForStore(initialState.activeStoreId);
    }
  }

  void _subscribeToOrdersForStore(int storeId) {
    final currentState = state;
    if (currentState is OrdersLoaded && currentState.activeStoreId == storeId) {
      return; // Já está ouvindo a loja correta.
    }

    emit(const OrdersLoading());
    _ordersSubscription?.cancel();
    _ordersCache = []; // Limpa o cache ao trocar de loja

    _ordersSubscription = _realtimeRepository.listenToOrders(storeId).listen(
          (orders) => _onOrdersReceived(orders, storeId),
      onError: (error) => emit(OrdersError("Erro ao carregar pedidos: $error")),
    );
  }
// Sua função no Cubit
  Future<void> _onOrdersReceived(List<OrderDetails> newOrders, int storeId) async {

    await _checkForPendingPrints(newOrders);

    final hasPendingOrders = newOrders.any((order) => order.orderStatus == 'pending');

    if (hasPendingOrders) {
      // Esta chamada agora funcionará, ativando o som contínuo.
      SoundAlertUtil.startLoopingSound();
    } else {
      // Esta chamada interromperá o som contínuo quando não houver mais pendentes.
      SoundAlertUtil.stopLoopingSound();
    }

    final oldOrderIds = _ordersCache.map((o) => o.id).toSet();
    for (final order in newOrders) {
      if (order.orderStatus == 'pending' && !oldOrderIds.contains(order.id)) {
        _lastNotifiedOrderId = order.id.toString();

        // Esta chamada tocará o som de notificação uma vez para o novo pedido.
        SoundAlertUtil.playNewOrderSound();

        print('[SOM] Pedido novo: #${order.id}');

        if (isMobileDevice) {
          NotificationService().showNewOrderNotification(order.publicId, order.customerName ?? 'Cliente');
        }
      }
    }

    _ordersCache = newOrders;
    _emitFilteredOrders(storeId);
  }




  Future<void> _checkForPendingPrints(List<OrderDetails> orders) async {
    print('[OrderCubit] Verificando ${orders.length} pedidos por impressões pendentes...');

    int manualPrintCounter = 0;

    // Usamos um loop 'for...in' com 'await' para processar um pedido de cada vez.
    for (final order in orders) {
      final pendingJobs =
      order.printLogs.where((log) => log.status == 'pending').toList();

      if (pendingJobs.isNotEmpty) {
        final storeState = _storesManagerCubit.state;
        Store? store;
        if (storeState is StoresManagerLoaded) {
          store = storeState.stores[order.storeId]?.store;
        }

        if (store != null && store.relations.storeOperationConfig!.autoPrintOrders) {
          print('[OrderCubit] Encontrados ${pendingJobs.length} trabalhos de impressão pendentes para o pedido #${order.id}. Impressão automática ATIVADA.');

          final printPayload = PrintJobPayload(
            jobs: pendingJobs
                .map((job) => PrintJob(
              id: job.id,
              destination: job.printerDestination,
            ))
                .toList(),
            orderId: order.id,
          );

          // 'await' garante que o processamento de um pedido termine antes de começar o próximo.
          await _printManager.processPrintJobs(printPayload, order, store);

        } else if (store == null) {
          print('[OrderCubit] ERRO: Não foi possível encontrar a loja ${order.storeId} para imprimir o pedido #${order.id}');
        } else {
          print('[OrderCubit] Encontrados ${pendingJobs.length} trabalhos pendentes para o pedido #${order.id}, mas a impressão automática está DESATIVADA.');
          manualPrintCounter++;
        }
      }
    }
    _pendingManualPrintsCount = manualPrintCounter;
  }


  Future<void> reprintOrder(OrderDetails order) async {
    print('[OrderCubit] Iniciando reimpressão para o pedido #${order.id}');

    // Filtra apenas os trabalhos que precisam de atenção (pendentes ou falhados)
    final jobsToReprint = order.printLogs
        .where((log) => log.status == 'pending' || log.status == 'failed')
        .toList();

    if (jobsToReprint.isEmpty) {
      print('[OrderCubit] Nenhum trabalho de impressão pendente ou com falha para o pedido #${order.id}.');
      // Opcional: Mostrar um SnackBar informando que não há nada a reimprimir.
      return;
    }

    final storeState = _storesManagerCubit.state;
    Store? store;
    if (storeState is StoresManagerLoaded) {
      store = storeState.stores[order.storeId]?.store;
    }

    if (store != null) {
      final printPayload = PrintJobPayload(
        jobs: jobsToReprint
            .map((job) => PrintJob(
          id: job.id,
          destination: job.printerDestination,
        ))
            .toList(),
        orderId: order.id,
      );

      // Envia os trabalhos para o PrintManager processar novamente.
      await _printManager.processPrintJobs(printPayload, order, store);
      // Opcional: Mostrar um SnackBar de "Enviado para reimpressão".
    } else {
      print('[OrderCubit] ERRO: Não foi possível encontrar a loja para reimprimir o pedido #${order.id}');
    }
  }

  void _emitFilteredOrders(int activeStoreId) {
    final sortedOrders = sortOrdersByStatusAndDate(_ordersCache);
    final filteredOrders = filterOrders(sortedOrders, _currentFilter);

    // ✅ NOTA: Seu `OrdersLoaded` state precisa ser atualizado para aceitar
    // o novo parâmetro `pendingManualPrintsCount`.
    emit(OrdersLoaded(
      orders: filteredOrders,
      activeStoreId: activeStoreId,
      lastNotifiedOrderId: _lastNotifiedOrderId,
      filter: _currentFilter,
      // Passa a contagem de impressões manuais para o estado da UI
      pendingManualPrintsCount: _pendingManualPrintsCount,
    ));
  }



  void applyFilter(OrderFilter filter) {
    if (_currentFilter == filter) return;
    _currentFilter = filter;

    final currentState = state;
    if (currentState is OrdersLoaded) {
      _emitFilteredOrders(currentState.activeStoreId!);
    }
  }

  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    await _realtimeRepository.updateOrderStatus(orderId, newStatus);
  }


  // Future<void> reprintOrder(OrderDetails order, Store store) async {
  //   await _printManager.reprintOrder(order, store);
  //   final currentState = state;
  //   if (currentState is OrdersLoaded) {
  //     // Re-emite o estado para a UI reconstruir (caso mostre um ícone de "impresso")
  //     _emitFilteredOrders(currentState.activeStoreId!);
  //   }
  // }

  @override
  Future<void> close() {
    _storesManagerSubscription?.cancel();
    SoundAlertUtil.stopLoopingSound();
    _ordersSubscription?.cancel();
    _connectionSubscription?.cancel();
    return super.close();
  }
}