// ✅ StoresManagerCubit (Gerencia múltiplas lojas com sockets simultâneos)
import 'dart:async';
import 'dart:io'; // Para SocketException
import 'package:bloc/bloc.dart';

import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';

class StoresManagerCubit extends Cubit<StoresManagerState> {
  final StoreRepository _storeRepository;
  final RealtimeRepository _realtimeRepository;

  final int _maxSimultaneousConnections = 5; // Limite de assinaturas ativas

  // Armazenamento em cache de todas as lojas que o admin tem acesso
  final Map<int, StoreWithRole> _storesCache = {};
  // Assinaturas ativas para as lojas que estamos ouvindo (limitadas por _maxSimultaneousConnections)
  final Map<int, StreamSubscription> _storeSubscriptions = {};
  // IDs de lojas aguardando para serem assinadas quando houver slot disponível
  final List<int> _pendingSubscriptions = [];

  // ID da loja que está atualmente "ativa" na UI (e.g., no painel principal de pedidos)
  int? _activeStoreId;

  // Timer para debounce na emissão de estado para lojas não ativas
  Timer? _debounceTimer;

  // Subscrições para streams gerais do RealtimeRepository
  StreamSubscription? _adminStoresListSubscription;
  StreamSubscription? _consolidatedStoresUpdatedSubscription;

  StoresManagerCubit({
    required StoreRepository storeRepository,
    required RealtimeRepository realtimeRepository,
  })  : _storeRepository = storeRepository,
        _realtimeRepository = realtimeRepository,
        super(const StoresManagerLoading()) {

    _startRealtimeListeners();
    _fetchAndInitializeStores(); // Inicia o processo de carregamento/conexão
  }

  // --- Métodos de Inicialização e Carregamento ---

  // Inicia os listeners de streams gerais do RealtimeRepository
  void _startRealtimeListeners() {
    // Escuta a lista completa de lojas do admin que vem do backend na conexão
    _adminStoresListSubscription = _realtimeRepository.onAdminStoresList.listen(
          (stores) {
        print('[StoresManagerCubit] Lista completa de lojas do admin recebida via Socket.');
        // Atualiza o cache e o estado consolidado com os dados mais recentes do socket
        _updateStoresCacheAndConsolidatedStatus(stores);
        _emitUpdatedState(); // Notifica os listeners
      },
      onError: (e) => print('[StoresManagerCubit] ERRO no stream onAdminStoresList: $e'),
      onDone: () => print('[StoresManagerCubit] Stream onAdminStoresList encerrado.'),
    );

    // Escuta atualizações da seleção consolidada de lojas
    _consolidatedStoresUpdatedSubscription = _realtimeRepository.onConsolidatedStoresUpdated.listen(
          (storeIds) {
        print('[StoresManagerCubit] Seleção consolidada atualizada via Socket: $storeIds');
        // Atualiza o flag isConsolidated no _storesCache
        _storesCache.forEach((id, storeWithRole) {
          storeWithRole.isConsolidated = storeIds.contains(id);
        });
        _emitUpdatedState(); // Notifica os listeners
      },
      onError: (e) => print('[StoresManagerCubit] ERRO no stream onConsolidatedStoresUpdated: $e'),
      onDone: () => print('[StoresManagerCubit] Stream onConsolidatedStoresUpdated encerrado.'),
    );
  }

  // Busca as lojas inicialmente (via REST) e configura o estado inicial
  Future<void> _fetchAndInitializeStores() async {
    emit(const StoresManagerLoading());
    try {
      final storesResult = await _storeRepository.getStores();

      await storesResult.fold(
            (failure) {
          print('Erro ao carregar lojas via REST: ');
          emit(StoresManagerError(message: 'Falha ao carregar lojas: '));
          return Future.value(); // Retorna um Future.value para continuar
        },
            (data) async {
          // Preenche o cache inicial com dados do REST.
          // O `isConsolidated` e outros dados em tempo real virão do socket.
          _updateStoresCache(data);

          // Tenta definir uma loja ativa inicial se não houver uma.
          // Prioridade: loja da sessão anterior > primeira loja da lista
          _activeStoreId ??= _storesCache.isNotEmpty ? _storesCache.keys.first : null;

          if (_activeStoreId != null) {
            // Se já temos uma loja ativa, junte-se à sala e assine.
            _realtimeRepository.joinStoreRoom(_activeStoreId!);
            _subscribeToStore(_activeStoreId!, priority: true);
          } else {
            // Se não há lojas, ou nenhuma ativa, emite estado de vazio.
            if (_storesCache.isEmpty) {
              emit(const StoresManagerEmpty());
            } else {
              // Se há lojas mas nenhuma ativa, emite Loaded sem activeStoreId
              _emitUpdatedState();
            }
          }
        },
      );
    } catch (e, stackTrace) {
      print('Erro na inicialização _fetchAndInitializeStores: $e\n$stackTrace');
      emit(
        StoresManagerError(
          message: 'Falha ao inicializar: ${e is SocketException ? 'Problema de conexão' : e.toString()}',
        ),
      );
      // Tentativa de reconexão em caso de erro de rede
      if (e is SocketException || e is TimeoutException) {
        await Future.delayed(const Duration(seconds: 5));
        if (!isClosed) _fetchAndInitializeStores();
      }
    }
  }

  // Atualiza o cache de lojas com dados do REST. Não afeta isConsolidated.
  void _updateStoresCache(List<StoreWithRole> stores) {
    _storesCache.clear();
    for (var s in stores) {
      _storesCache[s.store.id!] = s;
    }
  }

  // Atualiza o cache e o status de consolidação com dados do socket (que já vêm completos)
  void _updateStoresCacheAndConsolidatedStatus(List<StoreWithRole> stores) {
    _storesCache.clear();
    for (var s in stores) {
      _storesCache[s.store.id!] = s;
      // Não é necessário _currentConsolidatedStoreIds separado se isConsolidated
      // já vem no StoreWithRole do backend.
    }
  }

  // --- Métodos de Gerenciamento de Assinaturas (Sockets) ---

  // Assina (ou prioriza) o stream de uma loja específica
  void _subscribeToStore(int storeId, {bool priority = false}) {
    if (_storeSubscriptions.containsKey(storeId)) {
      if (priority && _storeSubscriptions[storeId]?.isPaused == true) {
        _storeSubscriptions[storeId]?.resume();
        print('[StoresManagerCubit] Assinatura da loja $storeId retomada.');
      }
      return; // Já assinado ou já em processo
    }

    // Gerenciamento de limite de conexões
    if (_storeSubscriptions.length >= _maxSimultaneousConnections) {
      if (priority) {
        // Encontra uma assinatura para cancelar (a não ser que seja a loja ativa atual)
        final nonPriorityId = _storeSubscriptions.keys.firstWhere(
              (id) => id != _activeStoreId && id != storeId, // Não cancele a ativa nem a que está sendo inscrita
          orElse: () => -1, // Retorna -1 se não encontrar outra
        );
        if (nonPriorityId != -1) {
          print('[StoresManagerCubit] Cancelando assinatura da loja $nonPriorityId para abrir vaga.');
          _storeSubscriptions[nonPriorityId]?.cancel();
          _storeSubscriptions.remove(nonPriorityId);
        } else {
          // Se não há outra para cancelar e o limite foi atingido, adicione aos pendentes
          if (!_pendingSubscriptions.contains(storeId)) {
            _pendingSubscriptions.add(storeId);
            print('[StoresManagerCubit] Loja $storeId adicionada aos pendentes (limite atingido).');
          }
          return;
        }
      } else {
        if (!_pendingSubscriptions.contains(storeId)) {
          _pendingSubscriptions.add(storeId);
          print('[StoresManagerCubit] Loja $storeId adicionada aos pendentes (limite atingido).');
        }
        return;
      }
    }

    print('[StoresManagerCubit] Assinando loja $storeId...');

    // Certifique-se de que estamos na sala antes de tentar escutar
    _realtimeRepository.joinStoreRoom(storeId);

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
        print('[StoresManagerCubit] Assinatura da loja $storeId concluída (onDone).');
        _storeSubscriptions.remove(storeId);
        _processPendingSubscriptions(); // Tenta processar pendentes se uma vaga abrir
      },
    );

    _storeSubscriptions[storeId] = subscription;
    print('[StoresManagerCubit] Assinatura para loja $storeId adicionada ao cache de subscriptions.');

    // Se esta é a loja ativa ou se o estado ainda não foi carregado, emita imediatamente.
    if (storeId == _activeStoreId || state is StoresManagerLoading) {
      _emitUpdatedState();
    }
  }

  // Adicione este método dentro da classe StoresManagerCubit

  void _emitUpdatedState() {
    // Verifica se o Cubit não foi fechado antes de emitir um novo estado
    if (isClosed) {
      print('[StoresManagerCubit] Cubit fechado, não pode emitir estado.');
      return;
    }

    // Certifica-se de que há lojas para emitir, caso contrário, emite StoresManagerEmpty
    if (_storesCache.isEmpty) {
      emit(const StoresManagerEmpty());
      return;
    }

    // Emite o estado StoresManagerLoaded com os dados atuais
    emit(
      StoresManagerLoaded(
        stores: Map<int, StoreWithRole>.from(_storesCache), // Cria uma cópia do mapa para imutabilidade
        activeStoreId: _activeStoreId,
        lastUpdate: DateTime.now(), // Atualiza o timestamp da última atualização
      ),
    );
    print('[StoresManagerCubit] Estado StoresManagerLoaded emitido.');
  }

  // Processa a próxima loja pendente se houver espaço
  void _processPendingSubscriptions() {
    while (_pendingSubscriptions.isNotEmpty &&
        _storeSubscriptions.length < _maxSimultaneousConnections) {
      final nextStoreId = _pendingSubscriptions.removeAt(0);
      _subscribeToStore(nextStoreId); // Tenta assinar o próximo
    }
  }

  // Lida com atualizações de dados de uma loja específica
  void _handleStoreUpdate(int id, StoreWithRole updatedStore) {
    final existing = _storesCache[id];

    // Só atualiza e emite se os dados realmente mudaram
    if (existing != null && updatedStore == existing) {
      return; // Nada mudou, não faz nada
    }

    _storesCache[id] = updatedStore; // Atualiza o cache

    // Emite o estado para a UI
    if (id == _activeStoreId) {
      // Para a loja ativa, emite imediatamente
      _emitUpdatedState();
    } else {
      // Para outras lojas, usa debounce para evitar reconstruções excessivas
      _debounceTimer?.cancel();
      _debounceTimer = Timer(
        const Duration(milliseconds: 500),
        _emitUpdatedState,
      );
    }
  }

  // Lida com erros na assinatura de uma loja
  void _handleStoreError(int id, dynamic e) {
    print('[StoresManagerCubit] Erro na assinatura da loja $id: $e');
    _storeSubscriptions[id]?.cancel(); // Cancela a assinatura com erro
    _storeSubscriptions.remove(id); // Remove do mapa de assinaturas
    _scheduleReconnect(id); // Agenda uma tentativa de reconexão
  }

  // Agenda uma reconexão para uma loja específica
  void _scheduleReconnect([int? storeId]) {
    Future.delayed(const Duration(seconds: 5), () {
      if (!isClosed && storeId != null) {
        print('[StoresManagerCubit] Tentando reconectar à loja $storeId...');
        _subscribeToStore(storeId);
      }
    });
  }

  // --- Métodos Públicos para Interação da UI/Negócio ---

  // Define a loja ativa que será exibida no painel principal
  void setActiveStore(int storeId) {
    print('[StoresManagerCubit] setActiveStore chamado para ID: $storeId');

    if (!_storesCache.containsKey(storeId)) {
      print('[StoresManagerCubit] Erro: Loja $storeId não encontrada no cache de lojas disponíveis.');
      return;
    }

    if (_activeStoreId == storeId) {
      print('[StoresManagerCubit] Loja $storeId já é a loja ativa. Nenhuma mudança necessária.');
      _emitUpdatedState(); // Garante que o estado atual seja emitido
      return;
    }

    print('[StoresManagerCubit] Mudando loja ativa de $_activeStoreId para $storeId');

    // 1. Pause/deixe a sala da loja antiga, se houver
    if (_activeStoreId != null && _storeSubscriptions.containsKey(_activeStoreId!)) {
      print('[StoresManagerCubit] Pausando assinatura e saindo da sala da loja antiga: $_activeStoreId');
      _realtimeRepository.leaveStoreRoom(_activeStoreId!);
      _storeSubscriptions[_activeStoreId!]?.pause(); // Apenas pause se não for a loja ativa
    }

    // 2. Atualiza o ID da loja ativa
    _activeStoreId = storeId;

    // 3. Junte-se à sala da nova loja (se já não estiver) e retome/crie assinatura
    _realtimeRepository.joinStoreRoom(_activeStoreId!);
    _subscribeToStore(_activeStoreId!, priority: true);

    // 4. Emite o novo estado para notificar OrderCubit e UI
    _emitUpdatedState();
    print('[StoresManagerCubit] Loja ativada com sucesso: $storeId');
  }

  // Define as lojas que serão consolidadas (enviando para o backend)
  Future<void> setConsolidatedStores(List<int> storeIds) async {
    // Não precisa emitir Loading aqui, o onConsolidatedStoresUpdated cuidará da atualização de estado
    print('[StoresManagerCubit] Solicitando consolidação das lojas: $storeIds');
    final result = await _realtimeRepository.setConsolidatedStores(storeIds);
    result.fold(
          (error) {
        print('[StoresManagerCubit] Erro ao definir lojas consolidadas: $error');
        // Você pode emitir um erro específico ou uma mensagem de snackbar aqui
      },
          (successData) {
        print('[StoresManagerCubit] Lojas consolidadas definidas com sucesso no backend.');
        // O `_consolidatedStoresUpdatedSubscription` será acionado e atualizará o estado
      },
    );
  }

  // Atualiza as configurações de uma loja (e.g., auto-aceite, auto-impressão)
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
      final result = await _realtimeRepository.updateStoreSettings(
        storeId: storeId,
        isDeliveryActive: isDeliveryActive,
        isTakeoutActive: isTakeoutActive,
        isTableServiceActive: isTableServiceActive,
        isStoreOpen: isStoreOpen,
        autoAcceptOrders: autoAcceptOrders,
        autoPrintOrders: autoPrintOrders,
      );

      result.fold(
            (error) {
          print('[StoresManagerCubit] Erro ao atualizar configurações da loja $storeId: $error');
          emit(StoresManagerError(message: 'Falha na atualização das configurações: $error'));
        },
            (success) {
          print('[StoresManagerCubit] Configurações da loja $storeId atualizadas com sucesso.');
          // O backend deve emitir uma atualização da loja via socket, que _handleStoreUpdate capturará.
          // Se não houver, você pode forçar uma atualização aqui se necessário, mas idealmente vem do socket.
          // _emitUpdatedState(); // Descomente se o backend não enviar atualização após settings
        },
      );
    } catch (e) {
      print('[StoresManagerCubit] Erro inesperado ao atualizar configurações: $e');
      emit(StoresManagerError(message: 'Erro inesperado: $e'));
    }
  }

  // Retorna a StoreWithRole para um dado ID
  StoreWithRole? getStoreById(int storeId) {
    return _storesCache[storeId];
  }

  // Retorna a StoreWithRole da loja ativa
  StoreWithRole? getActiveStore() => _storesCache[_activeStoreId];

  // Getter para os IDs das lojas consolidadas (baseado no cache interno)
  List<int> get currentConsolidatedStoreIds {
    return _storesCache.values
        .where((s) => s.isConsolidated == true)
        .map((s) => s.store.id!)
        .toList();
  }

  // --- Limpeza ---

  @override
  Future<void> close() async {
    _adminStoresListSubscription?.cancel();
    _consolidatedStoresUpdatedSubscription?.cancel();
    _debounceTimer?.cancel();
    // Cancela todas as assinaturas de loja ativas
    await Future.wait(_storeSubscriptions.values.map((s) => s.cancel()));
    _storeSubscriptions.clear();
    print('[StoresManagerCubit] Todos os subscriptions e timers foram cancelados.');
    return super.close();
  }
}