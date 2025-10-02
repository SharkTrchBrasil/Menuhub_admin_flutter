// Em: cubits/store_manager_cubit.dart

import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:totem_pro_admin/models/store/store_with_role.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

import '../core/enums/connectivity_status.dart';
import '../core/utils/variant_helper.dart';
import '../models/category.dart';
import '../models/chatbot_conversation.dart';
import '../models/chatbot_message.dart';
import '../models/command.dart';
import '../models/customer_analytics_data.dart';
import '../models/dashboard_data.dart';
import '../models/dashboard_insight.dart';
import '../models/products/full_menu_data.dart';
import '../models/payment_method.dart';
import '../models/peak_hours.dart';

import '../models/products/product.dart';
import '../models/products/product_analytics_data.dart';
import '../models/store/store.dart';

import '../models/subscription.dart';
import '../models/table.dart';
import '../models/variant.dart';
import '../repositories/payment_method_repository.dart';
import '../repositories/product_repository.dart';
import 'auth_cubit.dart';

class StoresManagerCubit extends Cubit<StoresManagerState> {
  final StoreRepository _storeRepository;
  final RealtimeRepository _realtimeRepository;

  final PaymentMethodRepository _paymentRepository;
  final ProductRepository _productRepository; //

  StreamSubscription? _adminStoresListSubscription;
  StreamSubscription? _notificationSubscription;


  StreamSubscription? _storeDetailsSubscription;
  StreamSubscription? _dashboardDataSubscription;
  StreamSubscription? _financialsSubscription;
  StreamSubscription? _connectivitySubscription;
  StreamSubscription? _fullMenuSubscription;


  StreamSubscription? _tablesSubscription;
  StreamSubscription? _commandsSubscription;
// 1. Adicione uma nova StreamSubscription no topo da classe
  StreamSubscription? _stuckOrderAlertSubscription;
  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _subscriptionErrorSubscription; // ✅ 1. Adicione a nova subscription
  StreamSubscription? _userHasNoStoresSubscription;


  Completer<void>? _initialLoadCompleter;


  StoresManagerCubit({
    required StoreRepository storeRepository,
    required RealtimeRepository realtimeRepository,
    required PaymentMethodRepository paymentRepository,
    required ProductRepository productRepository,
  }) : _storeRepository = storeRepository,
        _realtimeRepository = realtimeRepository,
        _paymentRepository = paymentRepository,
        _productRepository = productRepository,

        super(const StoresManagerInitial()) {}




// =========================================================================
  // ✅ [REATORAÇÃO COMPLETA] LÓGICA DE CARREGAMENTO INICIAL
  // =========================================================================
  Future<void> loadInitialData() async {
    if (state is StoresManagerLoading) return;

    log('[CUBIT]  Orchestrating initial data load...');
    emit(const StoresManagerLoading());

    // 1. Inicia um novo Completer para esta sessão de carregamento.
    _initialLoadCompleter = Completer<void>();

    // 2. Inicia os listeners de tempo real IMEDIATAMENTE.
    // Isso é crucial para não perder os primeiros eventos do socket.
    if (_adminStoresListSubscription == null) {
      log("[CUBIT] Starting real-time listeners before any network call.");
      _startRealtimeListeners();
    }

    // 3. Busca as lojas via HTTP. O objetivo é apenas saber se o usuário tem lojas
    // e qual era a última ativa, não para popular a UI.
    final result = await _storeRepository.getStores();

    await result.fold(
          (failure) async {
        log('❌ [CUBIT] Failed to load initial stores via HTTP: failure');
        emit(const StoresManagerError(message: 'Não foi possível carregar suas lojas.'));
        if (!_initialLoadCompleter!.isCompleted) _initialLoadCompleter!.complete();
      },
          (stores) async {
        final validStores = stores.where((s) => s.store.core.id != null).toList();

        if (validStores.isEmpty) {
          log("🔵 [CUBIT] HTTP load complete: No stores found. Emitting StoresManagerEmpty.");
          emit(const StoresManagerEmpty());
          if (!_initialLoadCompleter!.isCompleted) _initialLoadCompleter!.complete();
          return;
        }

        final firstStoreId = validStores.first.store.core.id!;
        log("✅ [CUBIT] HTTP load complete. Active store will be ID: $firstStoreId.");
        log("⏳ [CUBIT] Now waiting for the essential WebSocket data to arrive...");

        // 4. Entra na sala da loja para começar a receber dados detalhados.
        await _realtimeRepository.joinStoreRoom(firstStoreId);

        // 5. AGUARDA O SINAL do Completer. Ele será completado por _onAdminStoresListReceived.
        try {
          await _initialLoadCompleter!.future.timeout(const Duration(seconds: 20));
          log("✅ [CUBIT] Initial load signal received. The app can now proceed.");
        } catch (e) {
          log("⚠️ [CUBIT] Timeout! Essential WebSocket data did not arrive in time.");
          if (state is! StoresManagerLoaded) {
            emit(const StoresManagerError(message: 'Falha ao sincronizar com o servidor.'));
          }
        }
      },
    );
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
    // Cancel any previous subscriptions to avoid duplicates
    _cancelSubscriptions();

    // Listeners que não dependem de uma loja ativa
    _adminStoresListSubscription = _realtimeRepository.onAdminStoresList.listen(_onAdminStoresListReceived);
    _notificationSubscription = _realtimeRepository.onStoreNotification.listen(_onNotificationsReceived);
    _connectivitySubscription = _realtimeRepository.onConnectivityChanged.listen(_onConnectivityChanged);
    _stuckOrderAlertSubscription = _realtimeRepository.onStuckOrderAlert.listen(_onStuckOrderAlertReceived);
    _conversationsSubscription = _realtimeRepository.onConversationsListUpdated.listen(_onConversationsListUpdated);
    _realtimeRepository.onNewChatMessage.listen(_onNewChatMessageReceived);
    _subscriptionErrorSubscription = _realtimeRepository.onSubscriptionError.listen(_onSubscriptionError);



    // ✅ BLINDANDO O LISTENER
    _userHasNoStoresSubscription = _realtimeRepository.onUserHasNoStores.listen((_) {
      if (isClosed) return;

      // Se o app ainda está carregando, ignore este evento.
      // O fluxo principal (loadInitialData) decidirá se há lojas ou não.
      if (state is StoresManagerLoading) {
        log("🔵 [CUBIT] 'user_has_no_stores' event received during initial load. Ignoring.");
        return;
      }

      log("🔵 [CUBIT] Event 'user_has_no_stores' received. Emitting StoresManagerEmpty.");
      // Só emite Empty se o app já estava carregado (ex: o usuário deletou sua última loja)
      if (state is! StoresManagerEmpty) {
        emit(const StoresManagerEmpty());
      }
    });

    _listenToActiveStoreData();







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

  /// Este método agora centraliza a lógica de ouvir os dados da loja ativa.
  void _listenToActiveStoreData() {
    // Cancela todas as inscrições antigas
    _storeDetailsSubscription?.cancel();
    _dashboardDataSubscription?.cancel();
    _financialsSubscription?.cancel();
    _fullMenuSubscription?.cancel();

    _tablesSubscription?.cancel();
    _commandsSubscription?.cancel();





    // Cria um stream que emite o ID da loja ativa sempre que ele muda
    final activeStoreIdStream =
    stream
        .whereType<StoresManagerLoaded>()
        .map((state) => state.activeStoreId)
        .distinct();

    // Usa o stream do ID da loja para ligar/desligar os listeners de dados
    _storeDetailsSubscription = activeStoreIdStream
        .switchMap((_) => _realtimeRepository.onStoreDetailsUpdated)
        .listen(_onStoreDetailsUpdated);

    _dashboardDataSubscription = activeStoreIdStream
        .switchMap((_) => _realtimeRepository.onDashboardDataUpdated)
        .listen(_onDashboardDataUpdated);

    _financialsSubscription = activeStoreIdStream
        .switchMap((_) => _realtimeRepository.onFinancialsUpdated)
        .listen(_onFinancialsDataReceived);




    _fullMenuSubscription = activeStoreIdStream
        .switchMap((storeId) {
      log("🔄 [CUBIT] Trocando inscrição do MENU COMPLETO para a loja ID: $storeId");
      return _realtimeRepository.listenToFullMenu(storeId);
    })
        .listen(_onFullMenuUpdated);




    _tablesSubscription = activeStoreIdStream
        .switchMap((storeId) => _realtimeRepository.listenToTables(storeId))
        .listen(_onTablesUpdated);

    _commandsSubscription = activeStoreIdStream
        .switchMap((storeId) => _realtimeRepository.listenToCommands(storeId))
        .listen(_onCommandsUpdated);



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



  /// ✅ Atualiza os detalhes da loja ATIVA. Nunca cria o estado `Loaded`.
  void _onStoreDetailsUpdated(Store? updatedStoreDetails) {
    if (updatedStoreDetails == null || state is! StoresManagerLoaded) return;

    log("✅ [CUBIT] Updating active store details from socket.");
    _updateActiveStore((_, activeStore) {
      final currentStore = activeStore.store;
      // Usamos o `copyWith` de forma segura, garantindo que não sobrescrevemos
      // dados que ainda não chegaram com nulo.
      final newRelations = currentStore.relations.copyWith(
        paymentMethodGroups: updatedStoreDetails.relations.paymentMethodGroups,
        coupons: updatedStoreDetails.relations.coupons,
        scheduledPauses: updatedStoreDetails.relations.scheduledPauses,
        hours: updatedStoreDetails.relations.hours,
        cities: updatedStoreDetails.relations.cities,
        storeOperationConfig: updatedStoreDetails.relations.storeOperationConfig,
        chatbotMessages: updatedStoreDetails.relations.chatbotMessages,
        chatbotConfig: updatedStoreDetails.relations.chatbotConfig,
        subscription: updatedStoreDetails.relations.subscription,
      );

      final newStore = currentStore.copyWith(
        core: updatedStoreDetails.core,
        address: updatedStoreDetails.address,
        operation: updatedStoreDetails.operation,
        marketing: updatedStoreDetails.marketing,
        media: updatedStoreDetails.media,
        relations: newRelations,
      );
      return activeStore.copyWith(store: newStore);
    });
  }


  void _onTablesUpdated(List<Table> tables) {
    _updateActiveStore((_, activeStore) {
      final newRelations = activeStore.store.relations.copyWith(tables: tables);
      return activeStore.copyWith(store: activeStore.store.copyWith(relations: newRelations));
    });
    log("✅ [CUBIT] Estado das mesas atualizado via socket.");
  }

  void _onCommandsUpdated(List<Command> commands) {
    _updateActiveStore((_, activeStore) {
      final newRelations = activeStore.store.relations.copyWith(commands: commands);
      return activeStore.copyWith(store: activeStore.store.copyWith(relations: newRelations));
    });
    log("✅ [CUBIT] Estado das comandas atualizado via socket.");
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

    // Cenário 1: Primeira carga do app (estado é Initial ou Loading)
    if (currentState is! StoresManagerLoaded) {
      // ✅ NOVA GUARDA DE SEGURANÇA:
      // Se estamos no meio do carregamento inicial e recebemos uma lista vazia,
      // é provável que seja um evento prematuro do socket. IGNORAMOS.
      // Só vamos considerar a lista vazia como definitiva se o fluxo principal
      // (loadInitialData) já tiver falhado ou completado.
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

      // Sinaliza que os dados essenciais chegaram (ou a falta deles foi confirmada).
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
      if (currentState.activeStoreId == newStoreId) return;

      final previousStoreId = currentState.activeStoreId;

      await _realtimeRepository.leaveStoreRoom(previousStoreId);
      await _realtimeRepository.joinStoreRoom(newStoreId);

      _realtimeRepository.clearNotificationsForStore(newStoreId);

      final newNotificationCounts = Map<int, int>.from(
        currentState.notificationCounts,
      );
      newNotificationCounts.remove(newStoreId);

      emit(
        currentState.copyWith(
          activeStoreId: newStoreId,
          notificationCounts: newNotificationCounts,
        ),
      );
    }
  }

  Future<void> updateStoreSettings(
      int storeId, {
        bool? deliveryEnabled,
        bool? pickupEnabled,
        bool? tableEnabled,
        bool? isStoreOpen,
        bool? autoAcceptOrders,
        bool? autoPrintOrders,
        String? mainPrinterDestination,
        String? kitchenPrinterDestination,
        String? barPrinterDestination,
      }) async {
    try {
      final result = await _realtimeRepository.updateStoreSettings(
        storeId: storeId,

        deliveryEnabled:    deliveryEnabled,  // <-- Parâmetro renomeado
        pickupEnabled:  pickupEnabled,     // <-- Parâmetro renomeado
        tableEnabled:tableEnabled,
        isStoreOpen: isStoreOpen,
        autoAcceptOrders: autoAcceptOrders,
        autoPrintOrders: autoPrintOrders,
        mainPrinterDestination: mainPrinterDestination,
        kitchenPrinterDestination: kitchenPrinterDestination,
        barPrinterDestination: barPrinterDestination,
      );

      result.fold(
            (error) {
          print(
            '[StoresManagerCubit] Erro ao atualizar configurações da loja $storeId: $error',
          );
        },
            (success) {
          print(
            '[StoresManagerCubit] Configurações da loja $storeId atualizadas com sucesso.',
          );
        },
      );
    } catch (e) {
      print(
        '[StoresManagerCubit] Erro inesperado ao atualizar configurações: $e',
      );
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






  /// ✅ Atualiza o menu completo (produtos, categorias, variantes) da loja ATIVA.
  void _onFullMenuUpdated(FullMenuData menuData) {
    if (state is! StoresManagerLoaded) return;

    log("✅ [CUBIT] Atomic full menu update from socket.");
    _updateActiveStore((_, activeStore) {
      final newRelations = activeStore.store.relations.copyWith(
        products: menuData.products,
        categories: menuData.categories,
        variants: menuData.variants,
      );
      return activeStore.copyWith(store: activeStore.store.copyWith(relations: newRelations));
    });

    // Após a primeira carga do menu, consideramos a sincronização completa.
    final currentState = state as StoresManagerLoaded;
    if (currentState.connectivityStatus == ConnectivityStatus.synchronizing) {
      log("🎉 [CUBIT] Full menu received. Store is now fully synchronized.");
      emit(currentState.copyWith(connectivityStatus: ConnectivityStatus.connected));
    }
  }






  String? getStoreNameById(int storeId) {
    final currentState = state;
    if (currentState is StoresManagerLoaded) {
      return currentState.stores[storeId]?.store.core.name;
    }
    return null;
  }

  Future<void> pauseProducts(List<int> productIds) async {
    if (state is! StoresManagerLoaded) return;
    final storeId = (state as StoresManagerLoaded).activeStoreId;
    // TODO: Adicionar tratamento de erro (try-catch)
    await _productRepository.updateProductsAvailability(
      storeId: storeId,
      productIds: productIds,
      isAvailable: false,
    );
    // Não precisa emitir estado, o evento de socket vai atualizar a UI
  }

  Future<void> activateProducts(List<int> productIds) async {
    if (state is! StoresManagerLoaded) return;
    final storeId = (state as StoresManagerLoaded).activeStoreId;
    await _productRepository.updateProductsAvailability(
      storeId: storeId,
      productIds: productIds,
      isAvailable: true,
    );
  }


  Future<void> archiveProducts(List<int> productIds) async {
    if (state is! StoresManagerLoaded) return;
    final storeId = (state as StoresManagerLoaded).activeStoreId;

    // Chama a nova função do repositório
    await _productRepository.archiveProducts(
      storeId: storeId,
      productIds: productIds,
    );

    // Aqui você pode adicionar lógica para atualizar a UI, se necessário
    // Por exemplo, recarregar a lista de produtos.
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







  void _cancelSubscriptions() {
    _adminStoresListSubscription?.cancel();
    _notificationSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _storeDetailsSubscription?.cancel();
    _dashboardDataSubscription?.cancel();
    _financialsSubscription?.cancel();
    _tablesSubscription?.cancel();
    _commandsSubscription?.cancel();
    _stuckOrderAlertSubscription?.cancel();
    _adminStoresListSubscription = null;
    _subscriptionErrorSubscription?.cancel();
    _userHasNoStoresSubscription?.cancel();
    _userHasNoStoresSubscription = null;

  }


  // ✅ NOVO: Atualiza os dados de uma loja específica no estado
  void updateStoreInState(int storeId, Store updatedStore) {
    final currentState = state;
    if (currentState is StoresManagerLoaded) {
      final storeWithRole = currentState.stores[storeId];
      if (storeWithRole != null) {
        // Usar copyWith para manter role e isConsolidated, apenas atualizar store
        final updatedStoreWithRole = storeWithRole.copyWith(store: updatedStore);
        
        // Criar um novo mapa de stores com a loja atualizada
        final updatedStores = Map<int, StoreWithRole>.from(currentState.stores);
        updatedStores[storeId] = updatedStoreWithRole;
        
        // Emitir novo estado com as lojas atualizadas
        emit(currentState.copyWith(stores: updatedStores));
        log('[StoresManagerCubit] Store $storeId atualizada no estado com dados completos.');
      }
    }
  }

  void resetState() {
    log('[StoresManagerCubit] Resetando estado e cancelando listeners...');
    _cancelSubscriptions();
    // Ao fazer logout, volte para o estado inicial, não para o vazio.
    emit(const StoresManagerInitial());
  }


  @override
  Future<void> close() {
    log('[StoresManagerCubit] Fechando o Cubit e todos os listeners.');
    _cancelSubscriptions();
    return super.close();
  }
}