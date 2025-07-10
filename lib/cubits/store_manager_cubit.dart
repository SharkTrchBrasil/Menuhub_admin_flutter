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
      List<StoreWithRole> stores = []; // Inicializa como lista vazia

      final storesResult = await _storeRepository.getStores();

      await storesResult.fold(
            (failure) {
          print('Erro ao carregar lojas: ');
          emit(StoresManagerError(message: 'Falha ao carregar lojas.'));
          return; // Interrompe a execução para não continuar com lista vazia
        },
            (data) {
          stores = data;
        },
      );

      if (stores.isEmpty) {
        emit(const StoresManagerEmpty());
        return;
      }

      // Atualiza cache e define loja ativa
      _updateStoresCache(stores);
      _activeStoreId ??= stores.first.store.id;

      if (_activeStoreId != null) {
        _realtimeRepository.joinStoreRoom(_activeStoreId!);
        _subscribeToStore(_activeStoreId!, priority: true);
      }

      // Conecta outras lojas, se existirem
      final otherStoreIds = stores
          .map((s) => s.store.id!)
          .where((id) => id != _activeStoreId)
          .toList();

      if (otherStoreIds.isNotEmpty) {
        _connectToStoresInBatches(otherStoreIds);
      }

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
          message: 'Falha ao inicializar: '
              '${e is SocketException ? 'Problema de conexão' : e.toString()}',
        ),
      );

      if (e is SocketException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 3));
        if (!isClosed) _initialize();
      }
    }
  }




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



// No seu StoresManagerCubit

  void _subscribeToStore(int storeId, {bool priority = false}) {
    // 1. Verificação de existência e limites (mantida a mesma)
    if (_storeSubscriptions.containsKey(storeId)) return;

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

    // **** NOVA ORDEM: Primeiro, entre na sala para garantir que o stream exista ****
    // Esta chamada irá garantir que os BehaviorSubjects para esta storeId sejam criados
    // dentro do RealtimeRepository (graças ao putIfAbsent).
    _realtimeRepository.joinStoreRoom(storeId);

    // **** AGORA SIM, você pode se inscrever ao stream com segurança ****
    final subscription = _realtimeRepository.listenToStore(storeId).listen(
          (storeWithRole) {
        print('[StoresManagerCubit] Recebeu atualização para loja $storeId: ${storeWithRole.store.name}');
        _handleStoreUpdate(storeId, storeWithRole);
      },
      onError: (error) {
        print('[StoresManagerCubit] ERRO na assinatura da loja $storeId: $error');
        _handleStoreError(storeId, error);
      },
      onDone: () {
        print('[StoresManagerCubit] Assinatura da loja $storeId concluída.');
        _storeSubscriptions.remove(storeId);
        _processPendingSubscriptions();
      },
    );

    _storeSubscriptions[storeId] = subscription;

    // Se a loja que está sendo inscrita é a loja ativa, emita o estado atualizado imediatamente.
    if (storeId == _activeStoreId) {
      _emitUpdatedState();
    }
  }



  void _handleStoreUpdate(int id, StoreWithRole store) {
    _storesCache[id] = store;
    if (id == _activeStoreId) {
      _emitUpdatedState();
    } else {
      // Use debounce para lojas não ativas para evitar muitas reconstruções
      _debounceTimer?.cancel();
      _debounceTimer = Timer(
        const Duration(milliseconds: 500),
        _emitUpdatedState,
      );
    }
  }






  StoreWithRole? getStore(int storeId) {
    if (state is StoresManagerLoaded) {
      final loadedState = state as StoresManagerLoaded;
      return loadedState.stores[storeId];
    }
    return null;
  }




  Future<void> initialize() async {
    await _initialize(); // Apenas renomeie ou exponha o método atual
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

  // No seu StoresManagerCubit
  void setActiveStore(int storeId) {
    print('[StoresManagerCubit] setActiveStore chamado para ID: $storeId');

    if (!_storesCache.containsKey(storeId)) {
      print('[StoresManagerCubit] Erro: Loja $storeId não encontrada no cache.');
      return; // Loja não existe no cache, não faz sentido ativá-la
    }

    if (_activeStoreId == storeId) {
      print('[StoresManagerCubit] Loja $storeId já é a loja ativa. Nenhuma mudança necessária.');
      return; // Já é a loja ativa, evite processamento desnecessário
    }

    // Se chegamos aqui, a loja existe e é diferente da ativa atual
    print('[StoresManagerCubit] Mudando de loja ativa de $_activeStoreId para $storeId');

    // 1. Sair da sala da loja antiga
    if (_activeStoreId != null) {
      print('[StoresManagerCubit] Saindo da sala da loja antiga: $_activeStoreId');
      _realtimeRepository.leaveStoreRoom(_activeStoreId!); // Use .leaveStoreRoom
      _storeSubscriptions[_activeStoreId!]?.pause(); // Pausa a assinatura, não cancela
    }

    // 2. Atualizar o ID da loja ativa
    _activeStoreId = storeId;
    print('[StoresManagerCubit] Novo _activeStoreId interno: $_activeStoreId');


    // 3. Entrar na sala da nova loja e retomar/criar assinatura
    print('[StoresManagerCubit] Entrando na sala da nova loja: $_activeStoreId');
    _realtimeRepository.joinStoreRoom(_activeStoreId!); // Use .joinStoreRoom

    if (_storeSubscriptions.containsKey(storeId)) {
      print('[StoresManagerCubit] Retomando assinatura para loja: $storeId');
      _storeSubscriptions[storeId]?.resume();
    } else {
      print('[StoresManagerCubit] Criando nova assinatura para loja: $storeId (prioridade: true)');
      _subscribeToStore(storeId, priority: true);
    }

    // 4. Emitir o novo estado para notificar os listeners (OrderCubit, UI)
    _emitUpdatedState();
    print('[StoresManagerCubit] _emitUpdatedState() chamado após setActiveStore.');

    print('[StoresManagerCubit] Loja ativada com sucesso: $storeId');
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





  StoreWithRole? getStoreById(int storeId) {
    return _storesCache[storeId];
  }

















  @override
  Future<void> close() async {
    _debounceTimer?.cancel();
    await Future.wait(_storeSubscriptions.values.map((s) => s.cancel()));
    _storeSubscriptions.clear();
    return super.close();
  }
}
