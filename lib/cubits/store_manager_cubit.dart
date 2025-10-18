// Em: cubits/store_manager_cubit.dart

import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';

import 'package:totem_pro_admin/models/store/store_with_role.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';

import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

import '../core/enums/connectivity_status.dart';
import '../core/utils/variant_helper.dart';
import '../models/category.dart';
import '../models/chatbot_conversation.dart';
import '../models/chatbot_message.dart';

import '../models/customer_analytics_data.dart';
import '../models/dashboard_data.dart';
import '../models/dashboard_insight.dart';
import '../models/products/full_menu_data.dart';
import '../models/payment_method.dart';
import '../models/peak_hours.dart';

import '../models/products/product.dart';
import '../models/products/product_analytics_data.dart';

import '../models/store/store.dart';

import '../models/store/store_city.dart';

import '../models/subscription/subscription.dart';

import '../models/tables/command.dart';
import '../models/tables/saloon.dart';
import '../models/variant.dart';

import '../repositories/payment_method_repository.dart';

import '../widgets/app_toasts.dart' as AppToasts;


class StoresManagerCubit extends Cubit<StoresManagerState> {
  final StoreRepository _storeRepository;
  final RealtimeRepository _realtimeRepository;

  final PaymentMethodRepository _paymentRepository;


  StreamSubscription? _adminStoresListSubscription;
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _stuckOrderAlertSubscription;
  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _subscriptionErrorSubscription;
  StreamSubscription? _userHasNoStoresSubscription;

  StreamSubscription? _activeStoreDataSubscription;


  Completer<void>? _initialLoadCompleter;

  Map<int, StreamSubscription> _menuSubscriptions = {};
  Map<int, StreamSubscription> _detailsSubscriptions = {};
  Map<int, StreamSubscription> _dashboardSubscriptions = {};
  Map<int, StreamSubscription> _financialsSubscriptions = {};
  Map<int, StreamSubscription> _saloonsSubscriptions = {};
  Map<int, StreamSubscription> _standaloneCommandsSubscriptions = {};

// ✅ ADICIONE ESTA LINHA
  List<Command>? _pendingStandaloneCommands;



  StoresManagerCubit({
    required StoreRepository storeRepository,
    required RealtimeRepository realtimeRepository,
    required PaymentMethodRepository paymentRepository,

  })
      : _storeRepository = storeRepository,
        _realtimeRepository = realtimeRepository,
        _paymentRepository = paymentRepository,


        super(const StoresManagerInitial()) {}






  Future<void> loadInitialData() async {
    if (_initialLoadCompleter != null && !_initialLoadCompleter!.isCompleted) {
      log('[CUBIT] loadInitialData já está em andamento. Aguardando...');
      return _initialLoadCompleter!.future;
    }
    if (state is StoresManagerLoading || state is StoresManagerSynchronizing) {
      log('[CUBIT] loadInitialData chamado, mas o estado já é Loading/Synchronizing.');
      return _initialLoadCompleter?.future;
    }

    _initialLoadCompleter = Completer<void>();

    log('[CUBIT] Orchestrating initial data load...');
    emit(const StoresManagerLoading());

    try {
      await _waitForSocketConnection();

      if (_adminStoresListSubscription == null) {
        _startRealtimeListeners();
      }

      // 1. Busca os dados básicos de TODAS as lojas via HTTP
      final result = await _storeRepository.getStores();

      await result.fold(
            (failure) {
          log('❌ [CUBIT] Failed to load initial stores via HTTP: ');
          emit(const StoresManagerError(message: 'Não foi possível carregar suas lojas.'));
          if (!_initialLoadCompleter!.isCompleted) _initialLoadCompleter!.complete();
        },
            (stores) async {
          final validStores = stores.where((s) => s.store.core.id != null).toList();

          if (validStores.isEmpty) {
            log("🔵 [CUBIT] No stores found. Emitting StoresManagerEmpty.");
            emit(const StoresManagerEmpty());
            if (!_initialLoadCompleter!.isCompleted) _initialLoadCompleter!.complete();
            return;
          }

          // 2. Cria o mapa com os dados básicos (já incluem subscription!)
          final storesMap = {for (var s in validStores) s.store.core.id!: s};
          final firstStoreId = validStores.first.store.core.id!;

          log("✅ [CUBIT] HTTP load complete with ${validStores.length} stores.");
          log("📋 [CUBIT] Todas as lojas têm dados básicos (nome, endereço, subscription).");
          log("🔄 [CUBIT] Iniciando carregamento dos dados operacionais da loja $firstStoreId...");

          // 3. Emite um estado temporário com dados básicos
          emit(StoresManagerSynchronizing(
            stores: storesMap,
            activeStoreId: firstStoreId,
          ));

          // 4. Entra na sala da PRIMEIRA loja para carregar dados operacionais
          await _realtimeRepository.joinStoreRoom(firstStoreId);
          log("✅ [CUBIT] Joined WebSocket room for store ID: $firstStoreId. Aguardando dados operacionais...");

          // 5. O completer será finalizado quando _onFullMenuUpdated for chamado
          // (isso já está implementado corretamente)
        },
      );
    } catch (e, st) {
      log('❌ [CUBIT] Critical error during initial data load: $e', stackTrace: st);
      emit(const StoresManagerError(message: 'Falha na conexão com o servidor. Tente novamente.'));
      if (_initialLoadCompleter != null && !_initialLoadCompleter!.isCompleted) {
        _initialLoadCompleter!.completeError(e, st);
      }
    }

    return _initialLoadCompleter!.future;
  }





  Future<void> _waitForSocketConnection() async {
    final realtimeRepo = _realtimeRepository;
    int attempts = 0;
    const maxAttempts = 10;
    const delay = Duration(milliseconds: 500);

    while (attempts < maxAttempts) {
      // Verifica se o socket está conectado
      if (realtimeRepo.isConnected) {
        log('✅ [CUBIT] WebSocket connected after $attempts attempts');
        return;
      }

      log('⏳ [CUBIT] Waiting for WebSocket connection... attempt ${attempts + 1}');
      await Future.delayed(delay);
      attempts++;
    }

    throw TimeoutException('WebSocket connection timeout after $maxAttempts attempts');
  }




  /// Helper para atualizar a loja ativa de forma segura e imutável.
  void _updateActiveStore(
      StoreWithRole Function(StoresManagerLoaded currentState, StoreWithRole activeStore) updater,
      ) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is! StoresManagerLoaded || currentState.activeStoreWithRole == null) return;

    final updatedActiveStore = updater(currentState, currentState.activeStoreWithRole!);
    final newStoresMap = Map<int, StoreWithRole>.from(currentState.stores);
    newStoresMap[currentState.activeStoreId] = updatedActiveStore;

    emit(
      currentState.copyWith(
        stores: newStoresMap,
        lastUpdate: DateTime.now(), // Garante a atualização da UI
      ),
    );
  }




  void _startRealtimeListeners() {
    // ❌ REMOVA ESTA LINHA (ela cancela listeners que ainda não foram criados)
    // _cancelSubscriptions();

    if (isClosed) {
      log('[StoresManagerCubit] Tentativa de criar listeners em Cubit fechado. Abortando.');
      return;
    }
    log('[CUBIT] Iniciando listeners de tempo real...');

    // Listeners que não dependem de uma loja ativa
    _adminStoresListSubscription = _realtimeRepository.onAdminStoresList
        .where((_) => _canProcessEvents)
        .listen(_onAdminStoresListReceived);

    _notificationSubscription = _realtimeRepository.onStoreNotification
        .where((_) => _canProcessEvents)
        .listen(_onNotificationsReceived);

    _connectivitySubscription = _realtimeRepository.onConnectivityChanged
        .where((_) => _canProcessEvents)
        .listen(_onConnectivityChanged);

    _stuckOrderAlertSubscription = _realtimeRepository.onStuckOrderAlert
        .where((_) => _canProcessEvents)
        .listen(_onStuckOrderAlertReceived);

    _conversationsSubscription = _realtimeRepository.onConversationsListUpdated
        .where((_) => _canProcessEvents)
        .listen(_onConversationsListUpdated);

    _realtimeRepository.onNewChatMessage
        .where((_) => _canProcessEvents)
        .listen(_onNewChatMessageReceived);

    _subscriptionErrorSubscription = _realtimeRepository.onSubscriptionError
        .where((_) => _canProcessEvents)
        .listen(_onSubscriptionError);

    _userHasNoStoresSubscription = _realtimeRepository.onUserHasNoStores
        .where((_) => _canProcessEvents)
        .listen((_) {
      if (state is StoresManagerLoading || state is StoresManagerSynchronizing) {
        log("🔵 [CUBIT] 'user_has_no_stores' event received during load. Finalizing.");
        emit(const StoresManagerEmpty());
        if (_initialLoadCompleter != null && !_initialLoadCompleter!.isCompleted) {
          _initialLoadCompleter!.complete();
        }
        return;
      }

      log("🔵 [CUBIT] Event 'user_has_no_stores' received. Emitting StoresManagerEmpty.");
      if (state is! StoresManagerEmpty) {
        emit(const StoresManagerEmpty());
      }
    });

    _listenToActiveStoreData();
  }


  void _onSubscriptionError(Map<String, dynamic> errorPayload) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is! StoresManagerLoaded) return;

    try {
      final storeId = currentState.activeStoreId;
      if (storeId == null) {
        log("❌ [CUBIT] _onSubscriptionError: activeStoreId é nulo.");
        return;
      }


      final subscriptionData = errorPayload['subscription'];
      if (subscriptionData == null || subscriptionData is! Map<String, dynamic>) {
        log("❌ [CUBIT] _onSubscriptionError: Payload de assinatura inválido ou nulo recebido.");
        return; // Interrompe a execução se o payload for inválido
      }

      final newSubscription = Subscription.fromJson(subscriptionData);

      final targetStoreWithRole = currentState.stores[storeId];
      if (targetStoreWithRole == null) return;

      final updatedStore = targetStoreWithRole.store.copyWith(
        relations: targetStoreWithRole.store.relations.copyWith(
          subscription: newSubscription,
        ),
      );

      final updatedStoreWithRole = targetStoreWithRole.copyWith(store: updatedStore);

      final newStoresMap = Map<int, StoreWithRole>.from(currentState.stores);
      newStoresMap[storeId] = updatedStoreWithRole;

      emit(currentState.copyWith(
        stores: newStoresMap,
        lastUpdate: DateTime.now(),
      ));

      log("✅ [CUBIT] Estado atualizado com status de assinatura bloqueada para a loja $storeId.");

    } catch (e, st) {
      log("❌ [CUBIT] Erro ao processar _onSubscriptionError: $e", stackTrace: st);
    }
  }












  /// Zera o contador de mensagens não lidas para um chat específico no estado local.
  void clearUnreadCount(String chatId) {
    if (isClosed) return;
    final currentState = state;
    // Garante que só vamos agir se o estado estiver carregado
    if (currentState is! StoresManagerLoaded) return;

    // Pega a lista atual de conversas
    final conversations = List<ChatbotConversation>.from(currentState.conversations);

    // Encontra o índice da conversa que precisa ser atualizada
    final index = conversations.indexWhere((c) => c.chatId == chatId);

    // Se encontrou a conversa e ela tem mensagens não lidas...
    if (index != -1 && conversations[index].unreadCount > 0) {
      // 1. Cria uma cópia da conversa com o contador zerado
      final updatedConversation = conversations[index].copyWith(unreadCount: 0);
      // 2. Substitui a conversa antiga pela nova na lista
      conversations[index] = updatedConversation;
      // 3. Emite o novo estado com a lista atualizada
      emit(currentState.copyWith(conversations: conversations));
      log("✅ [CUBIT] Contador de não lidas zerado localmente para o chat: $chatId");
    }
  }




  void _onConversationsListUpdated(List<ChatbotConversation> conversations) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is StoresManagerLoaded) {
      emit(currentState.copyWith(conversations: conversations));
      log("✅ [CUBIT] Carga inicial de conversas recebida.");
    }
  }

  void _onNewChatMessageReceived(ChatbotMessage newMessage) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is StoresManagerLoaded) {
      final conversations = List<ChatbotConversation>.from(currentState.conversations);
      final index = conversations.indexWhere((c) => c.chatId == newMessage.chatId);
      // para incluí-lo. Vamos usar o nome que vem na mensagem se ele existir.
      final customerName = newMessage.customerName ?? 'Novo Contato';

      if (index != -1) {
        final existing = conversations[index];
        conversations[index] = existing.copyWith(

          customerName: customerName != 'Novo Contato' ? customerName : existing.customerName,
          lastMessagePreview: newMessage.textContent ?? '(Mídia)',
          lastMessageTimestamp: newMessage.timestamp,
          unreadCount: newMessage.isFromMe ? existing.unreadCount : existing.unreadCount + 1,
        );
        conversations.insert(0, conversations.removeAt(index));
      } else {
        // Adiciona uma nova conversa no topo
        conversations.insert(0, ChatbotConversation(
          chatId: newMessage.chatId,
          storeId: newMessage.storeId,
          customerName: newMessage.customerName, // O nome virá em um evento futuro
          lastMessagePreview: newMessage.textContent ?? '(Mídia)',
          lastMessageTimestamp: newMessage.timestamp,
          unreadCount: 1,
        ));
      }
      emit(currentState.copyWith(conversations: conversations));
    }
  }



  void _onConnectivityChanged(ConnectivityStatus status) {
    if (state is StoresManagerLoaded) {
      final currentState = state as StoresManagerLoaded;

      emit(currentState.copyWith(
        connectivityStatus: status,
        lastUpdate: DateTime.now(),
      ));
    }
  }



  void _listenToActiveStoreData() {
    _activeStoreDataSubscription?.cancel();

    _activeStoreDataSubscription = stream
        .where((state) => state is StoresManagerLoaded || state is StoresManagerSynchronizing)
        .map((state) {
      if (state is StoresManagerLoaded) return state.activeStoreId;
      if (state is StoresManagerSynchronizing) return state.activeStoreId;
      return -1;
    })
        .distinct()
        .listen((storeId) {
      if (isClosed) return;

      // ✅ CORREÇÃO: Cancela listeners ANTES de criar novos
      _cancelStoreSpecificListeners();

      if (storeId == -1) {
        log("🔄 [CUBIT] Nenhuma loja ativa. Nenhum listener de dados ativo.");
        return;
      }

      log("🔄 [CUBIT] Trocando listeners de dados para a loja ID: $storeId");

      // ✅ AGUARDA um microtask ANTES de criar os listeners
      Future.microtask(() {
        if (isClosed) return;

        log("🎧 [CUBIT] Criando listeners para loja $storeId...");

        // Cria listeners individuais para a nova loja
        _menuSubscriptions[storeId] = _realtimeRepository.listenToFullMenu(storeId).listen((data) {
          if (isClosed) return;
          log("🎯 [CUBIT] FullMenuData recebido do stream para loja $storeId! Processando...");
          _onFullMenuUpdated(data);
        }, onError: (e, st) {
          log("❌ [CUBIT] Erro no stream de menu: $e", stackTrace: st);
        });

        _detailsSubscriptions[storeId] = _realtimeRepository.onStoreDetailsUpdated.listen((data) {
          if (isClosed || data == null || data.core.id != storeId) return;
          log("➡️ [CUBIT] Evento de dados da loja ativa recebido: details");
          _onStoreDetailsUpdated(data);
        });

        _dashboardSubscriptions[storeId] = _realtimeRepository.onDashboardDataUpdated.listen((data) {
          if (isClosed || data == null) return;
          log("➡️ [CUBIT] Evento de dados da loja ativa recebido: dashboard");
          _onDashboardDataUpdated(data);
        });

        _financialsSubscriptions[storeId] = _realtimeRepository.onFinancialsUpdated.listen((data) {
          if (isClosed || data == null) return;
          log("➡️ [CUBIT] Evento de dados da loja ativa recebido: financials");
          _onFinancialsDataReceived(data);
        });

        _saloonsSubscriptions[storeId] = _realtimeRepository.listenToSaloons(storeId).listen((data) {
          if (isClosed) return;
          log("➡️ [CUBIT] Evento de dados da loja ativa recebido: saloons");
          _onSaloonsUpdated(data);
        });




        _standaloneCommandsSubscriptions[storeId] = _realtimeRepository
            .listenToStandaloneCommands(storeId)
            .listen((commands) {
          if (isClosed) return;
          print("🔥🔥🔥 [CUBIT] Listener de comandas disparado!"); // ✅ ADICIONE
          log("➡️ [CUBIT] Comandas avulsas recebidas: ${commands.length}");
          _onStandaloneCommandsUpdated(commands);
        });

        print('🔥🔥🔥 [CUBIT] Listener de comandas CRIADO para loja $storeId'); // ✅ ADICIONE


        log("🎧 [CUBIT] ✅ Todos os listeners configurados para loja $storeId");
      });
    }, onError: (e, st) {
      log("❌ [CUBIT] Erro no stream principal: $e", stackTrace: st);
    });
  }






  void _cancelStoreSpecificListeners() {
    for (var sub in _menuSubscriptions.values) {
      sub.cancel();
    }
    _menuSubscriptions.clear();

    for (var sub in _detailsSubscriptions.values) {
      sub.cancel();
    }
    _detailsSubscriptions.clear();

    for (var sub in _dashboardSubscriptions.values) {
      sub.cancel();
    }
    _dashboardSubscriptions.clear();

    for (var sub in _financialsSubscriptions.values) {
      sub.cancel();
    }
    _financialsSubscriptions.clear();

    for (var sub in _saloonsSubscriptions.values) {
      sub.cancel();
    }
    _saloonsSubscriptions.clear();

    // ✅ ADICIONE ESTE BLOCO
    for (var sub in _standaloneCommandsSubscriptions.values) {
      sub.cancel();
    }
    _standaloneCommandsSubscriptions.clear();
  }


  void _onFinancialsDataReceived(FinancialsData? financialsData) {
    if (financialsData == null) return;
    _updateActiveStore((_, activeStore) {
      final newRelations = activeStore.store.relations.copyWith(
        payables: financialsData.payables,
        suppliers: financialsData.suppliers,
        payableCategories: financialsData.payableCategories,
        receivables: financialsData.receivables,
        receivableCategories: financialsData.receivableCategories,
      );
      return activeStore.copyWith(store: activeStore.store.copyWith(relations: newRelations));
    });
    log("✅ [CUBIT] Dados financeiros atualizados via socket.");
  }

// 3. Crie o método que vai lidar com o recebimento do alerta
  void _onStuckOrderAlertReceived(Map<String, dynamic> alertData) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is! StoresManagerLoaded) return;

    final int? orderId = alertData['order_id'];
    if (orderId == null) return;

    // Adiciona o ID do pedido ao conjunto de alertas
    final newStuckOrderIds = Set<int>.from(currentState.stuckOrderIds)..add(orderId);

    emit(currentState.copyWith(stuckOrderIds: newStuckOrderIds));
    log('Cubit State atualizado com novo pedido preso: $orderId');
  }


  void clearStuckOrderAlert(int orderId) {
    if (isClosed) return;
    final currentState = state;
    if (currentState is! StoresManagerLoaded) return;

    final newStuckOrderIds = Set<int>.from(currentState.stuckOrderIds)..remove(orderId);

    emit(currentState.copyWith(stuckOrderIds: newStuckOrderIds));
    log('Alerta para o pedido $orderId foi limpo do estado.');
  }



// Em: cubits/store_manager_cubit.dart

  void _onStoreDetailsUpdated(Store? updatedStoreDetails) {
    if (updatedStoreDetails == null || isClosed) return;

    final currentState = state;

    StoreWithRole applyUpdate(StoreWithRole original, Store details) {
      final currentRelations = original.store.relations;

      // ✅ CORREÇÃO: Preserva a subscription do HTTP se o socket não enviar uma
      final newRelations = currentRelations.copyWith(
        paymentMethodGroups: details.relations.paymentMethodGroups,
        coupons: details.relations.coupons,
        scheduledPauses: details.relations.scheduledPauses,
        hours: details.relations.hours,
        cities: details.relations.cities,
        storeOperationConfig: details.relations.storeOperationConfig,
        chatbotMessages: details.relations.chatbotMessages,
        chatbotConfig: details.relations.chatbotConfig,
        // ✅ CORREÇÃO CRÍTICA: Só atualiza subscription se vier do socket
        // Se vier null/vazio, mantém a que veio do HTTP
        subscription: details.relations.subscription ?? currentRelations.subscription,
      );

      final newStore = original.store.copyWith(
        core: details.core,
        address: details.address,
        operation: details.operation,
        marketing: details.marketing,
        media: details.media,
        relations: newRelations,
      );
      return original.copyWith(store: newStore);
    }

    if (currentState is StoresManagerLoaded) {
      log("🔄 [CUBIT] Updating active store details on a loaded state.");
      final activeStore = currentState.activeStoreWithRole;
      if (activeStore == null) return;
      final updatedActiveStore = applyUpdate(activeStore, updatedStoreDetails);
      final newStoresMap = Map<int, StoreWithRole>.from(currentState.stores)
        ..[currentState.activeStoreId] = updatedActiveStore;
      emit(currentState.copyWith(stores: newStoresMap));
    }
    else if (currentState is StoresManagerSynchronizing) {
      log("🔄 [CUBIT] Updating store details during synchronization phase.");
      final activeStore = currentState.stores[currentState.activeStoreId];
      if (activeStore == null) return;
      final updatedActiveStore = applyUpdate(activeStore, updatedStoreDetails);
      final newStoresMap = Map<int, StoreWithRole>.from(currentState.stores)
        ..[currentState.activeStoreId] = updatedActiveStore;
      emit(StoresManagerSynchronizing(
        stores: newStoresMap,
        activeStoreId: currentState.activeStoreId,
      ));
    }
  }

  void _onSaloonsUpdated(List<Saloon> saloons) {
    if (isClosed) return;
    final currentState = state;

    // Função interna para aplicar a atualização dos salões
    StoreWithRole applySaloonsUpdate(StoreWithRole original, List<Saloon> newSaloons) {
      final newRelations = original.store.relations.copyWith(saloons: newSaloons);
      final updatedStore = original.store.copyWith(relations: newRelations);
      return original.copyWith(store: updatedStore);
    }

    // CASO 1: O app já está totalmente carregado.
    if (currentState is StoresManagerLoaded) {
      log("🔄 [CUBIT] Updating Saloons on a loaded state.");
      final activeStore = currentState.activeStoreWithRole;
      if (activeStore == null) return;

      final updatedActiveStore = applySaloonsUpdate(activeStore, saloons);
      final newStoresMap = Map<int, StoreWithRole>.from(currentState.stores)
        ..[currentState.activeStoreId] = updatedActiveStore;

      emit(currentState.copyWith(stores: newStoresMap));
    }
    // CASO 2: O app está na fase de sincronização.
    else if (currentState is StoresManagerSynchronizing) {
      log("🔄 [CUBIT] Updating Saloons during synchronization phase.");
      final activeStore = currentState.stores[currentState.activeStoreId];
      if (activeStore == null) return;

      final updatedActiveStore = applySaloonsUpdate(activeStore, saloons);
      final newStoresMap = Map<int, StoreWithRole>.from(currentState.stores)
        ..[currentState.activeStoreId] = updatedActiveStore;

      // Emite um novo estado de Sincronização, mas com os dados dos salões atualizados.
      emit(StoresManagerSynchronizing(
        stores: newStoresMap,
        activeStoreId: currentState.activeStoreId,
      ));
    }
  }


  void _onStandaloneCommandsUpdated(List<Command> commands) {
    if (isClosed) return;
    final currentState = state;

    print('🔥🔥🔥 [CUBIT] _onStandaloneCommandsUpdated chamado!');
    print('🔥🔥🔥 [CUBIT] Comandas recebidas: ${commands.length}');
    for (var cmd in commands) {
      print('  - Comanda ID ${cmd.id}: ${cmd.customerName}');
    }

    // ✅ CORREÇÃO: Atualiza TANTO em Synchronizing QUANTO em Loaded
    if (currentState is StoresManagerLoaded) {
      log("🔄 [CUBIT] Atualizando ${commands.length} comandas avulsas (Loaded).");
      emit(currentState.copyWith(standaloneCommands: commands));
    }
    else if (currentState is StoresManagerSynchronizing) {
      log("🔄 [CUBIT] Atualizando ${commands.length} comandas durante sincronização.");

      // ✅ NOVO: Guarda as comandas para quando transicionar para Loaded
      // Não podemos emitir agora porque vai perder na transição
      // Então guardamos temporariamente e aplicamos em _onFullMenuUpdated
      _pendingStandaloneCommands = commands;
      print('🔥🔥🔥 [CUBIT] Comandas guardadas para aplicar em Loaded');
    }
  }


  void _onDashboardDataUpdated(Map<String, dynamic>? dashboardPayload) {
    if (dashboardPayload == null) return;
    _updateActiveStore((_, activeStore) {
      final newRelations = activeStore.store.relations.copyWith(
        dashboardData: DashboardData.fromJson(dashboardPayload['dashboard']),
        productAnalytics: ProductAnalyticsResponse.fromJson(dashboardPayload['product_analytics']),
        customerAnalytics: CustomerAnalyticsResponse.fromJson(dashboardPayload['customer_analytics']),
        peakHours: PeakHours.fromJson(dashboardPayload['peak_hours']),
        insights: (dashboardPayload['insights'] as List).map((i) => DashboardInsight.fromJson(i)).toList(),
      );
      return activeStore.copyWith(store: activeStore.store.copyWith(relations: newRelations));
    });
    log("✅ [CUBIT] Dados do dashboard atualizados via socket.");
  }


  Category? getCategoryById(int categoryId) {
    final currentState = state;
    // Garante que o estado seja 'Loaded' e que haja uma loja ativa.
    if (currentState is! StoresManagerLoaded || currentState.activeStoreWithRole == null) {
      log('❌ [getCategoryById] Tentou buscar categoria, mas o estado não está carregado.');
      return null;
    }

    try {
      // Acessa a lista de categorias completas que já está no estado.
      final allCategories = currentState.activeStoreWithRole!.store.relations.categories;

      // Encontra e retorna a categoria correspondente.
      return allCategories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      // 'firstWhere' lança um erro se não encontrar, então capturamos.
      log('⚠️ [getCategoryById] Categoria com ID $categoryId não encontrada no estado atual.');
      return null;
    }
  }

// Em: cubits/store_manager_cubit.dart
  Product? getProductById(int productId) {
    final currentState = state;
    if (currentState is! StoresManagerLoaded || currentState.activeStoreWithRole == null) {
      return null;
    }
    try {
      // Acessa a lista de produtos completa que já está no estado.
      final allProducts = currentState.activeStoreWithRole!.store.relations.products;
      return allProducts.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }





  /// Busca um grupo de complemento (Variant) completo pelo seu ID
  /// dentro do estado atual da loja ativa.
  Variant? getVariantById(int variantId) {
    final currentState = state;
    if (currentState is! StoresManagerLoaded || currentState.activeStoreWithRole == null) {
      return null;
    }
    try {
      // Acessa a lista de variantes que já está no estado.
      final allVariants = currentState.activeStoreWithRole!.store.relations.variants;
      return allVariants.firstWhere((variant) => variant.id == variantId);
    } catch (e) {
      // Retorna nulo se o 'firstWhere' não encontrar o item
      return null;
    }
  }



  void _onAdminStoresListReceived(List<StoreWithRole> stores) {
    if (isClosed) return;

    final currentState = state;
    final validStores = stores.where((s) => s.store.core.id != null).toList();


    if (currentState is StoresManagerLoading || currentState is StoresManagerSynchronizing) {
      log("🟡 [CUBIT] 'admin_stores_list' received during initial load. Ignoring to prevent race condition.");
      return;
    }



    if (currentState is! StoresManagerLoaded) {

      if (validStores.isEmpty && currentState is StoresManagerLoading) {
        log("🟡 [CUBIT] Ignorando lista de lojas vazia recebida durante o carregamento inicial. Aguardando dados definitivos.");
        return; // Não faz nada e continua esperando.
      }

      if (validStores.isEmpty) {
        log("🔵 [CUBIT] Initial socket data: No stores. Emitting StoresManagerEmpty.");
        if (currentState is! StoresManagerEmpty) emit(const StoresManagerEmpty());
      } else {
        log("🚀 [CUBIT] First valid store list from socket. Emitting StoresManagerLoaded with ${validStores.length} stores.");
        final firstStoreId = validStores.first.store.core.id!;

        emit(
          StoresManagerLoaded(
            stores: {for (var s in validStores) s.store.core.id!: s},
            activeStoreId: firstStoreId,
            connectivityStatus: ConnectivityStatus.synchronizing,
            consolidatedStores: const [],
            lastUpdate: DateTime.now(),
            notificationCounts: const {},
            stuckOrderIds: const {},
            conversations: const [],
          ),
        );
      }


      if (_initialLoadCompleter != null && !_initialLoadCompleter!.isCompleted) {
        _initialLoadCompleter!.complete();
      }
    }
    // Cenário 2: App já carregado, isto é uma atualização da lista de lojas.
    else {
      // Esta lógica existente já ignora listas vazias se já tivermos dados, o que está correto.
      if (validStores.isEmpty && currentState.stores.isNotEmpty) {
        log("🔵 [CUBIT] Ignoring empty store list from socket because we already have data.");
        return;
      }
      log("🔄 [CUBIT] Socket update received. Refreshing store list with ${validStores.length} items.");
      emit(
        currentState.copyWith(
          stores: {for (var s in validStores) s.store.core.id!: s},
          lastUpdate: DateTime.now(),
        ),
      );
    }
  }

  void addNewStore(StoreWithRole newStore) {
    if (isClosed) return;

    final currentState = state;
    Map<int, StoreWithRole> currentStores = {};

    // Se já tínhamos lojas, pegamos o mapa atual
    if (currentState is StoresManagerLoaded) {
      currentStores = Map.from(currentState.stores);
    }

    // Adiciona a nova loja ao mapa
    currentStores[newStore.store.core.id!] = newStore;

    log("✅ [CUBIT] Adicionando nova loja (ID: ${newStore.store.core.id}) ao estado. Transicionando para StoresManagerLoaded.");

    // Emite o estado `Loaded` com a nova loja, definindo-a como ativa.
    // Isso funciona tanto se o estado anterior era `Empty` quanto `Loaded`.
    emit(
      StoresManagerLoaded(
        stores: currentStores,
        activeStoreId: newStore.store.core.id!,
        consolidatedStores: const [],
        notificationCounts: const {},
        lastUpdate: DateTime.now(),
        conversations: const [],
        stuckOrderIds: const {},
        connectivityStatus: ConnectivityStatus.connected,
      ),
    );

    // Conecta-se à sala da nova loja
    _realtimeRepository.joinStoreRoom(newStore.store.core.id!);
  }


  void _onNotificationsReceived(Map<int, int> incomingNotificationCounts) {
    if (isClosed) return;
    final currentState = state;

    if (currentState is StoresManagerLoaded) {
      // Cria uma cópia do mapa de notificações que acabamos de receber
      final filteredCounts = Map<int, int>.from(incomingNotificationCounts);


      filteredCounts.remove(currentState.activeStoreId);


      emit(currentState.copyWith(notificationCounts: filteredCounts));
    }
  }





  Future<void> changeActiveStore(int newStoreId) async {
    if (isClosed) return;
    final currentState = state;

    if (currentState is StoresManagerLoaded) {
      if (currentState.activeStoreId == newStoreId) {
        log('[CUBIT] Store $newStoreId já é a ativa. Ignorando troca.');
        return;
      }

      final previousStoreId = currentState.activeStoreId;
      log('[CUBIT] 🔄 Trocando loja ativa: $previousStoreId → $newStoreId');

      try {
        // ✅ PASSO 1: Sair da sala antiga
        log('[CUBIT] Saindo da sala da loja $previousStoreId...');
        await _realtimeRepository.leaveStoreRoom(previousStoreId);

        // ✅ PASSO 2: Limpar notificações
        _realtimeRepository.clearNotificationsForStore(newStoreId);

        // ✅ PASSO 3: Limpar dados antigos dos BehaviorSubjects
        log('[CUBIT] Limpando dados antigos dos streams...');
        _realtimeRepository.clearStoreData(newStoreId);

        // ✅ PASSO 4: Emitir estado (isso dispara _listenToActiveStoreData que cria os listeners)
        final newNotificationCounts = Map<int, int>.from(currentState.notificationCounts);
        newNotificationCounts.remove(newStoreId);

        emit(
          currentState.copyWith(
            activeStoreId: newStoreId,
            notificationCounts: newNotificationCounts,
          ),
        );

        // ✅ PASSO 5: Aguardar listeners serem criados
        await Future.delayed(const Duration(milliseconds: 100));

        // ✅ PASSO 6: Entrar na nova sala (agora COM listeners prontos)
        log('[CUBIT] Entrando na sala da loja $newStoreId...');
        await _realtimeRepository.joinStoreRoom(newStoreId);

        log('[CUBIT] ✅ Troca de loja concluída para ID: $newStoreId');
      } catch (e, st) {
        log('[CUBIT] ❌ Erro ao trocar de loja', error: e, stackTrace: st);
      }
    }
  }



  Future<bool> addPause({
    required int storeId,
    required String? reason,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    // O Cubit delega a chamada para o repositório
    final result = await _storeRepository.createScheduledPause(
      storeId: storeId,
      reason: reason,
      startTime: startTime,
      endTime: endTime,
    );

    // Retorna true para sucesso e false para falha
    return result.fold(
          (error) {
        print("Erro no Cubit ao criar pausa: $error");
        // O repositório já deve ter mostrado um AppToast de erro
        return false;
      },
          (newPause) {
        // Sucesso!
        print("Pausa criada com sucesso no Cubit. ID: ${newPause.id}");
        // Não precisa atualizar o estado aqui, pois o backend enviará um
        // evento de socket que atualizará a UI automaticamente.
        return true;
      },
    );
  }

  // ✅ 2. MÉTODO PARA DELETAR UMA PAUSA EXISTENTE
  Future<bool> deletePause({required int pauseId}) async {
    final result = await _storeRepository.deleteScheduledPause(
      pauseId: pauseId,
    );

    return result.fold(
          (error) {
        print("Erro no Cubit ao deletar pausa: $error");
        return false;
      },
          (_) {
        // Sucesso! O backend também deve enviar um evento de socket aqui.
        print("Pausa $pauseId deletada com sucesso no Cubit.");
        return true;
      },
    );
  }

  Future<void> fetchHolidays() async {
    // Use 'state' directly for the most current state information
    if (state is! StoresManagerLoaded) return;
    if ((state as StoresManagerLoaded).holidays != null &&
        (state as StoresManagerLoaded).holidays!.isNotEmpty) {
      return; // If holidays are already loaded, do nothing.
    }

    final result = await _storeRepository.getHolidays(DateTime.now().year);

    result.fold((error) => print("Cubit Error fetching holidays: $error"), (
        holidays,
        ) {
      if (state is StoresManagerLoaded) {
        emit((state as StoresManagerLoaded).copyWith(holidays: holidays));
      }
    });
  }

  Future<bool> updatePaymentMethodActivation({
    required int storeId,
    required int platformMethodId,
    required StorePaymentMethodActivation activation,
  }) async {
    final result = await _paymentRepository.updateActivation(
      storeId: storeId,
      platformMethodId: platformMethodId,
      activation: activation,
    );

    // ✅ 2. RETORNE TRUE PARA SUCESSO E FALSE PARA ERRO
    return result.fold(
          (error) {
        print('Erro ao atualizar forma de pagamento: $error');
        return false; // Falha
      },
          (_) {
        print(
          'Ativação de pagamento enviada com sucesso. Aguardando atualização do estado.',
        );
        return true; // Sucesso
      },
    );
  }




  void _onFullMenuUpdated(FullMenuData menuData) {
    if (isClosed) {
      log('🔴 [CUBIT] _onFullMenuUpdated chamado, mas o cubit está fechado. Abortando.');
      return;
    }
    final currentState = state;

// CASO 1: Transição de Synchronizing para Loaded.
    if (currentState is StoresManagerSynchronizing) {
      log("🎉 [CUBIT] First full menu received. Transitioning to StoresManagerLoaded.");

      final stores = currentState.stores;
      final activeStoreId = currentState.activeStoreId;
      final activeStore = stores[activeStoreId];

      if (activeStore == null) {
        log('❌ [CUBIT] Erro crítico: Estado é Synchronizing, mas a loja ativa ($activeStoreId) não foi encontrada no mapa.');
        if (_initialLoadCompleter != null && !_initialLoadCompleter!.isCompleted) {
          _initialLoadCompleter!.completeError("Active store not found during sync.");
        }
        return;
      }

      final newRelations = activeStore.store.relations.copyWith(
        products: menuData.products,
        categories: menuData.categories,
        variants: menuData.variants,
      );
      final updatedStore = activeStore.store.copyWith(relations: newRelations);
      final updatedStoresMap = Map<int, StoreWithRole>.from(stores)
        ..[activeStoreId] = activeStore.copyWith(store: updatedStore);

      log('➡️ [CUBIT] Emitindo estado StoresManagerLoaded...');

      // ✅ CORREÇÃO: Aplica as comandas pendentes
      final commandsToApply = _pendingStandaloneCommands ?? [];
      print('🔥🔥🔥 [CUBIT] Aplicando ${commandsToApply.length} comandas pendentes');

      emit(StoresManagerLoaded(
        stores: updatedStoresMap,
        activeStoreId: activeStoreId,
        connectivityStatus: ConnectivityStatus.connected,
        consolidatedStores: const [],
        lastUpdate: DateTime.now(),
        notificationCounts: const {},
        stuckOrderIds: const {},
        conversations: const [],
        standaloneCommands: commandsToApply,  // ✅ ADICIONE ESTA LINHA
      ));

      // ✅ Limpa as comandas pendentes
      _pendingStandaloneCommands = null;

      log('✅ [CUBIT] Estado StoresManagerLoaded emitido.');

      if (_initialLoadCompleter != null && !_initialLoadCompleter!.isCompleted) {
        log("➡️ [CUBIT] Finalizando o completer de carga inicial...");
        _initialLoadCompleter!.complete();
        log("✅ [CUBIT] Completer de carga inicial finalizado com sucesso.");
      }

      return;
    }

    // CASO 2: Atualização normal em um estado já carregado.
    if (currentState is StoresManagerLoaded) {
      log("🔄 [CUBIT] Full menu updated on an already loaded state.");
      _updateActiveStore((_, activeStore) {
        final newRelations = activeStore.store.relations.copyWith(
          products: menuData.products,
          categories: menuData.categories,
          variants: menuData.variants,
        );
        return activeStore.copyWith(
          store: activeStore.store.copyWith(relations: newRelations),
        );
      });
    }
  }



  String? getStoreNameById(int storeId) {
    final currentState = state;
    if (currentState is StoresManagerLoaded) {
      return currentState.stores[storeId]?.store.core.name;
    }
    return null;
  }


  // O método que criamos antes agora também fica mais simples
  String getPreviewForVariant(Variant variant) {
    final currentState = state;
    if (currentState is! StoresManagerLoaded) {
      return 'Carregando...';
    }

    final allProducts = currentState.activeStore?.relations.products ?? [];

    return getVariantLinkedProductsPreview(
      variant: variant,
      allProducts: allProducts, // Usa a lista de produtos do estado
    );
  }



  // ✅ MÉTODO CORRIGIDO E ALINHADO COM A ARQUITETURA DO CUBIT
  Future<bool> saveCityWithNeighborhoods(int storeId, StoreCity city) async {
    final result = await _storeRepository.saveCityWithNeighborhoods(storeId, city);

    return result.fold(
          (failure) {
        // Em caso de falha, apenas mostramos o erro. O estado não é alterado.
        AppToasts.showError(failure.message);
        log('❌ [CUBIT] Falha ao salvar cidade e bairros: ${failure.message}');
        return false;
      },
          (savedCity) {
        // Em caso de sucesso, mostramos a confirmação.
        // O estado será atualizado automaticamente pelo evento de socket 'store_updated'.
        AppToasts.showSuccess('Locais de entrega salvos com sucesso!');
        log('✅ [CUBIT] Cidade e bairros salvos. ID: ${savedCity.id}. Aguardando atualização via socket.');
        return true;
      },
    );
  }



  // ✅ NOVO MÉTODO SÍNCRONO PARA BUSCAR A CIDADE NO ESTADO ATUAL
  // Este método não faz chamadas de rede.
  StoreCity? getCityFromState(int cityId) {
    final currentState = state;
    if (currentState is! StoresManagerLoaded) {
      log('⚠️ [CUBIT] Tentativa de buscar cidade do estado, mas o estado não está carregado.');
      return null;
    }

    try {
      // Busca a cidade na lista de cidades da loja ativa que já está em memória.
      return currentState.activeStore?.relations.cities?.firstWhere((c) => c.id == cityId);
    } catch (e) {
      // Ocorre se 'firstWhere' não encontrar a cidade na lista.
      log('❌ [CUBIT] Erro: Cidade com ID $cityId não foi encontrada no estado atual.');
      return null;
    }
  }





  // ♻️ MÉTODO DE LIMPEZA PARA LOGOUT
  Future<void> resetState() async {
    log('[StoresManagerCubit] Iniciando reset completo do estado...');
    // 1. Cancela todos os listeners.
    await _cancelSubscriptions();
    // 2. Limpa os dados no repositório de tempo real (mas mantém a conexão de socket).
    _realtimeRepository.reset();
    // 3. Reseta o estado do Cubit para o inicial.
    emit(const StoresManagerInitial());
    log('[StoresManagerCubit] Reset completo finalizado.');
  }

// ✅ Atualize o método _cancelSubscriptions para incluir a nova lógica
  Future<void> _cancelSubscriptions() async {
    log('[StoresManagerCubit] Cancelando todas as subscriptions...');

    // Cancela listeners específicos de loja
    _cancelStoreSpecificListeners();

    // Cancela outros listeners (código existente)
    await _adminStoresListSubscription?.cancel();
    _adminStoresListSubscription = null;
    await _notificationSubscription?.cancel();
    _notificationSubscription = null;
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    await _stuckOrderAlertSubscription?.cancel();
    _stuckOrderAlertSubscription = null;
    await _conversationsSubscription?.cancel();
    _conversationsSubscription = null;
    await _subscriptionErrorSubscription?.cancel();
    _subscriptionErrorSubscription = null;
    await _userHasNoStoresSubscription?.cancel();
    _userHasNoStoresSubscription = null;

    await _activeStoreDataSubscription?.cancel();
    _activeStoreDataSubscription = null;

    log('[StoresManagerCubit] Todas as subscriptions canceladas.');
  }

  @override
  Future<void> close() {
    log('[StoresManagerCubit] Fechando o Cubit permanentemente...');

    _cancelSubscriptions();

    if (_initialLoadCompleter != null && !_initialLoadCompleter!.isCompleted) {
      // Sugestão: Usar completeError para indicar um fechamento inesperado.
      _initialLoadCompleter!.completeError('Cubit closed before completion');
    }

    _realtimeRepository.dispose();

    return super.close();
  }



  bool get _canProcessEvents => !isClosed;

}