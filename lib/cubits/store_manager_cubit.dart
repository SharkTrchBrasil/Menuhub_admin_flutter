// ✅ StoresManagerCubit (Gerencia múltiplas lojas com sockets simultâneos)
import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';

import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';

import '../core/di.dart';
import '../models/order_details.dart';

class StoresManagerCubit extends Cubit<StoresManagerState> {
  final StoreRepository _storeRepository;
  final RealtimeRepository _realtimeRepository; // Não é mais nullable e é final
  final int _maxSimultaneousConnections = 5;


  final Map<int, List<OrderDetails>> _ordersCache = {}; // Novo campo para cache de pedidos

  final Map<int, StoreWithRole> _storesCache = {};
  final Map<int, StreamSubscription> _storeSubscriptions = {};
  final List<int> _pendingSubscriptions = [];
  Timer? _debounceTimer;
  int? _activeStoreId;



  StoresManagerCubit({
    required StoreRepository storeRepository,
    required RealtimeRepository realtimeRepository, // Injeta RealtimeRepository
  })  : _storeRepository = storeRepository,
        _realtimeRepository = realtimeRepository, // Atribui
        super(const StoresManagerLoading()) {
  //  _initialize();
  }






  Future<void> _initialize() async {
    emit(const StoresManagerLoading());

    try {
      // 1. Inicialize 'stores' com uma lista vazia para garantir que não seja nula
      List<StoreWithRole> stores = []; // <-- MUDANÇA AQUI: inicializa como lista vazia

      final storesResult = await _storeRepository.getStores();

      await storesResult.fold(
            (failure) {
          print('Erro ao carregar lojas: "mostra failure aqui');
          emit(StoresManagerError(message: 'Falha ao carregar lojas.'));
          // IMPORTANTE: Se você der um 'return;' aqui, a lógica subsequente pode não fazer sentido
          // se 'stores' for uma lista vazia e você continuar.
          // Para este caso, faz sentido porque 'stores.isEmpty' será verdadeiro.
        },
            (data) {
          stores = data; // Atribui a lista de lojas em caso de sucesso
        },
      );

      // Agora, 'stores' nunca será nula aqui.
      // Ela será a lista carregada ou uma lista vazia se a chamada falhar ou retornar vazio.
      if (stores.isEmpty) { // A verificação continua válida
        emit(const StoresManagerEmpty());
        return;
      }

      // 4. Atualização do cache e conexão
      _updateStoresCache(stores);
      _activeStoreId ??= stores.first.store.id;

      // 5. Conexão prioritária para a loja ativa
      if (_activeStoreId != null) {
        _realtimeRepository.joinStoreRoom(_activeStoreId!);
        _subscribeToStore(_activeStoreId!, priority: true);
      }

      // 6. Conexão para outras lojas em batches
      _connectToStoresInBatches(
        stores
            .map((s) => s.store.id!)
            .where((id) => id != _activeStoreId)
            .toList(),
      );

      // 7. Emitir estado atualizado
      emit(
        StoresManagerLoaded(
          stores: Map<int, StoreWithRole>.from(_storesCache),
          activeStoreId: _activeStoreId,
          lastUpdate: DateTime.now(),
        ),
      );
    } catch (e, stackTrace) {
      print('Erro na inicialização: $e\n$stackTrace');
      emit(
        StoresManagerError(
          message:
          'Falha ao inicializar: ${e is SocketException ? 'Problema de conexão' : e.toString()}',
        ),
      );

      if (e is SocketException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 3));
        if (!isClosed) _initialize();
      }
    }
  }





  // Novo método para adicionar/atualizar pedidos iniciais de uma loja
  void _handleOrdersInitial(int storeId, List<OrderDetails> orders) {
    _ordersCache[storeId] = orders;
    _emitUpdatedState(); // Reemita o estado para atualizar a UI
  }

  // Novo método para lidar com atualizações de pedidos (novo pedido, status, etc.)
  void _handleOrderUpdate(int storeId, OrderDetails updatedOrder) {
    // Encontra a lista de pedidos da loja
    final currentOrders = _ordersCache[storeId] ?? [];

    // Tenta encontrar o pedido existente para atualizar
    final index = currentOrders.indexWhere((order) => order.id == updatedOrder.id);

    if (index != -1) {
      // Atualiza o pedido existente
      currentOrders[index] = updatedOrder;
    } else {
      // Adiciona o novo pedido (se não existir)
      currentOrders.add(updatedOrder);
    }
    _ordersCache[storeId] = currentOrders; // Atualiza o cache
    _emitUpdatedState(); // Reemita o estado para atualizar a UI
  }







  // Método auxiliar para atualizar o cache
  void _updateStoresCache(List<StoreWithRole> stores) {
    _storesCache.clear();
    _storesCache.addAll({for (var s in stores) s.store.id!: s});
  }

  void _connectToStoresInBatches(List<int> storeIds) {
    if (_activeStoreId != null) {
      try {
        _subscribeToStore(_activeStoreId!, priority: true);
      } catch (e, s) {
        print('Erro ao conectar loja ativa ($_activeStoreId): $e');
        print(s);
      }
    }

    for (var id in storeIds.where((id) => id != _activeStoreId)) {
      try {
        _subscribeToStore(id);
      } catch (e, s) {
        print('Erro ao conectar loja $id: $e');
        print(s);
      }
    }
  }



  void _subscribeToStore(int storeId, {bool priority = false}) {
    // Verificação inicial
    if (_storeSubscriptions.containsKey(storeId)) return;

    // Verificação de limite de conexões simultâneas
    if (_storeSubscriptions.length >= _maxSimultaneousConnections) {
      if (priority) {
        final nonPriorityId = _storeSubscriptions.keys.firstWhere(
              (id) => id != _activeStoreId,
          orElse: () => storeId,
        );
        _storeSubscriptions[nonPriorityId]?.cancel();
        _storeSubscriptions.remove(nonPriorityId);
      } else {
        if (!_pendingSubscriptions.contains(storeId)) {
          _pendingSubscriptions.add(storeId);
        }
        return;
      }
    }

    print('[StoreManagerCubit] Iniciando conexão com loja $storeId');

    // try {
    //
    //   _realtimeRepository.joinStoreRoom(storeId); // Não é mais nullable, use direto
    //
    //
    //   final sub = _realtimeRepository
    //       .listenToStore(storeId)
    //       .listen(
    //         (store) => _handleStoreUpdate(storeId, store),
    //     onError: (e) => _handleStoreError(storeId, e),
    //     onDone: () {
    //       _storeSubscriptions.remove(storeId);
    //       _processPendingSubscriptions();
    //     },
    //   );
    //
    //   _storeSubscriptions[storeId] = sub;
    // } catch (e, s) {
    //   print('[StoreManagerCubit] Erro ao tentar assinar loja $storeId: $e');
    //   print(s);
    // }
    //
    //















  }













  Future<void> initialize() async {
    await _initialize(); // Apenas renomeie ou exponha o método atual
  }

  void _handleStoreUpdate(int id, StoreWithRole store) {
    _storesCache[id] = store;
    if (id == _activeStoreId) {
      _emitUpdatedState();
    } else {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(
        const Duration(milliseconds: 500),
        _emitUpdatedState,
      );
    }
  }

  void _handleStoreError(int id, dynamic e) {
    print('[Socket] Erro na loja $id: $e');
    _storeSubscriptions[id]?.cancel();
    _storeSubscriptions.remove(id);
    _scheduleReconnect(id);
  }

  void _scheduleReconnect([int? id]) {
    Future.delayed(const Duration(seconds: 5), () {
      if (!isClosed && id != null) _subscribeToStore(id);
    });
  }

  void _processPendingSubscriptions() {
    while (_pendingSubscriptions.isNotEmpty &&
        _storeSubscriptions.length < _maxSimultaneousConnections) {
      final id = _pendingSubscriptions.removeAt(0);
      _subscribeToStore(id);
    }
  }

  void _emitUpdatedState() {
    if (state is StoresManagerLoaded) {
      emit(
        StoresManagerLoaded(
          stores: Map<int, StoreWithRole>.from(_storesCache),
          activeStoreId: _activeStoreId,
          lastUpdate: DateTime.now(),
        ),
      );
    }
  }

  StoreWithRole? getActiveStore() => _storesCache[_activeStoreId ?? -1];

  void setActiveStore(int storeId) {
    print('[DEBUG] Tentando ativar loja: $storeId');

    if (!_storesCache.containsKey(storeId) || _activeStoreId == storeId) {
      return; // Evita processamento desnecessário
    }

    // Sai da sala antiga
    if (_activeStoreId != null) {
      _realtimeRepository?.leaveStoreRoom(_activeStoreId!);
      _storeSubscriptions[_activeStoreId!]?.pause(); // Pausa em vez de cancelar
    }

    _activeStoreId = storeId;

    // Entra na nova sala
    _realtimeRepository?.joinStoreRoom(storeId);

    // Resume ou cria a subscription
    if (_storeSubscriptions.containsKey(storeId)) {
      _storeSubscriptions[storeId]?.resume();
    } else {
      _subscribeToStore(storeId, priority: true);
    }

    _emitUpdatedState();

    print('[DEBUG] Loja ativada com sucesso: $storeId');
  }

  void addStore(StoreWithRole newStore) {
    final id = newStore.store.id!;
    if (_storesCache.containsKey(id)) return;

    _storesCache[id] = newStore;
    _subscribeToStore(id);

    _emitUpdatedState();
  }

  Future<void> updateStoreSettings(
      int storeId, {
        bool? isDeliveryActive,
        bool? isTakeoutActive,
        bool? isTableServiceActive,
        bool? isStoreOpen,
        bool? autoAcceptOrders,
        bool? autoPrintOrders,
      }) async {
    try {
      final result = await _realtimeRepository!.updateStoreSettings(
        isDeliveryActive: isDeliveryActive,
        isTakeoutActive: isTakeoutActive,
        isTableServiceActive: isTableServiceActive,
        isStoreOpen: isStoreOpen,
        autoAcceptOrders: autoAcceptOrders,
        autoPrintOrders: autoPrintOrders,
      );

      result.fold(
            (error) {
          print('[Store] Erro ao atualizar configurações: $error');
          emit(StoresManagerError(message: 'Falha na atualização: $error'));
        },
            (success) {
          print('[Store] Configurações atualizadas com sucesso');
          _emitUpdatedState(); // Força atualização do estado
        },
      );
    } catch (e) {
      print('[Store] Erro inesperado ao atualizar configurações: $e');
    }
  }

  void refreshStores() async {
    try {
      emit(const StoresManagerLoading());
      await _initialize(); // Reutiliza a lógica de inicialização
    } catch (e) {
      emit(StoresManagerError(message: 'Falha ao atualizar: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() async {
    _debounceTimer?.cancel();
    await Future.wait(_storeSubscriptions.values.map((s) => s.cancel()));
    _storeSubscriptions.clear();
    return super.close();
  }
}
