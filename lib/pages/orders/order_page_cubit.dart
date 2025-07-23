// Em: cubits/order_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/pages/orders/service/printer_manager.dart';
import 'package:totem_pro_admin/pages/orders/utils/order_helpers.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/utils/sounds/sound_util.dart';
import 'package:totem_pro_admin/pages/orders/order_page_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final RealtimeRepository _realtimeRepository;
  final StoresManagerCubit _storesManagerCubit;
  final PrintManager _printManager;
// NOVO: Uma variável para guardar a nossa "inscrição" no stream
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

  Future<void> _onOrdersReceived(List<OrderDetails> newOrders, int storeId) async {
    final storeState = _storesManagerCubit.state;
    Store? activeStore;
    if (storeState is StoresManagerLoaded) {
      activeStore = storeState.stores[storeId]?.store;
    }

    // LÓGICA MELHORADA: Identifica pedidos que são genuinamente novos (status 'pending' e não estavam no cache antes).
    final oldOrderIds = _ordersCache.map((o) => o.id).toSet();
    for (final order in newOrders) {
      if (order.orderStatus == 'pending' && !oldOrderIds.contains(order.id)) {
        _lastNotifiedOrderId = order.id.toString();
        SoundAlertUtil.playNewOrderSound();
        print('[SOM] Pedido novo: #${order.id}');

        // Lógica de impressão automática para o novo pedido
        if (activeStore != null) {
          await _printManager.processOrder(order, activeStore);
        }
      }
    }

    _ordersCache = newOrders; // Atualiza o cache com a lista mais recente
    _emitFilteredOrders(storeId);
  }

  void _emitFilteredOrders(int activeStoreId) {
    // A ordenação agora é opcional aqui, pois a UI (MobileOrderLayout) pode cuidar disso.
    // Mas manter aqui garante que o estado sempre tenha uma lista ordenada.
    final sortedOrders = sortOrdersByStatusAndDate(_ordersCache);
    final filteredOrders = filterOrders(sortedOrders, _currentFilter);

    // CORRIGIDO: Passa o `_currentFilter` para o estado.
    emit(OrdersLoaded(
      orders: filteredOrders,
      activeStoreId: activeStoreId,
      lastNotifiedOrderId: _lastNotifiedOrderId,
      filter: _currentFilter,
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

  bool isOrderPrinted(int orderId) => _printManager.isOrderPrinted(orderId);

  Future<void> reprintOrder(OrderDetails order, Store store) async {
    await _printManager.reprintOrder(order, store);
    final currentState = state;
    if (currentState is OrdersLoaded) {
      // Re-emite o estado para a UI reconstruir (caso mostre um ícone de "impresso")
      _emitFilteredOrders(currentState.activeStoreId!);
    }
  }

  @override
  Future<void> close() {
    _storesManagerSubscription?.cancel();
    _ordersSubscription?.cancel();
    _connectionSubscription?.cancel();
    return super.close();
  }
}