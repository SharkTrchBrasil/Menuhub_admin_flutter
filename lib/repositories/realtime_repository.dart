import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:either_dart/either.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


import 'package:totem_pro_admin/models/command.dart';
import 'package:totem_pro_admin/models/order_details.dart';

import 'package:totem_pro_admin/models/store/store_with_role.dart';
import 'package:totem_pro_admin/models/table.dart';


import '../core/enums/connectivity_status.dart';
import '../models/category.dart';
import '../models/chatbot_conversation.dart';
import '../models/chatbot_message.dart';
import '../models/products/full_menu_data.dart';
import '../models/order_notification.dart';
import '../models/payable_category.dart';
import '../models/payables_dashboard.dart';
import '../models/print_job.dart';
import '../models/products/prodcut_category_links.dart';
import '../models/products/product.dart';
import '../models/receivable_category.dart';
import '../models/store/store.dart';
import '../models/store/store_chatbot_config.dart';
import '../models/store/store_payable.dart';
import '../models/store/store_receivable.dart';

import '../models/supplier.dart';

import '../models/variant.dart';
import '../services/connectivity_service.dart';
import 'auth_repository.dart'; // Para ter acesso ao TotemAuth

import 'dart:convert'; // Para usar o JsonEncoder



class FinancialsData {
  final List<StorePayable> payables;
  final List<Supplier> suppliers;
  final List<PayableCategory> payableCategories;
  final List<StoreReceivable> receivables;
  final List<ReceivableCategory> receivableCategories;

  FinancialsData({
    required this.payables,
    required this.suppliers,
    required this.payableCategories,
    required this.receivables,
    required this.receivableCategories,
  });
}



class RealtimeRepository {

  IO.Socket? _socket;
  final AuthRepository _authRepository = GetIt.I<AuthRepository>();
  bool _isReconnecting = false; // Flag para evitar múltiplas tentativas
  int? _lastJoinedStoreId;
  bool _isDisposed = false;

  String? _lastUsedAdminToken;

  final _connectionStatusController = BehaviorSubject<bool>.seeded(false);
  final _storeNotificationController = BehaviorSubject<Map<int, int>>.seeded({});
  final _orderNotificationController = StreamController<OrderNotification>.broadcast();
  final _activeStoreController = BehaviorSubject<Store?>.seeded(null);
  final _productsStreams = <int, BehaviorSubject<List<Product>>>{};
  final _ordersStreams = <int, BehaviorSubject<List<OrderDetails>>>{};
  final _tablesStreams = <int, BehaviorSubject<List<Table>>>{};
  final _commandsStreams = <int, BehaviorSubject<List<Command>>>{};
  final _adminStoresListController = BehaviorSubject<List<StoreWithRole>>.seeded([]);
  final _newPrintJobsController = StreamController<PrintJobPayload>.broadcast();
  final _storeDetailsController = BehaviorSubject<Store?>();
  final _dashboardDataController = BehaviorSubject<Map<String, dynamic>?>();
  final _payablesDashboardController = BehaviorSubject<PayablesDashboardMetrics?>();
  final _newChatMessageController = StreamController<ChatbotMessage>.broadcast();


  final _variantsStreams = <int, BehaviorSubject<List<Variant>>>{};
  final _categoriesStreams = <int, BehaviorSubject<List<Category>>>{};

  final _financialsController = BehaviorSubject<FinancialsData?>();

  final _connectivityStatusController = BehaviorSubject<ConnectivityStatus>();

  final ConnectivityService _connectivityService = GetIt.I<ConnectivityService>();

  final _fullMenuStreams = <int, BehaviorSubject<FullMenuData>>{};

  final _chatbotConfigController = BehaviorSubject<StoreChatbotConfig?>();


  final _stuckOrderAlertController = StreamController<Map<String, dynamic>>.broadcast();

  final _conversationsListController = BehaviorSubject<List<ChatbotConversation>>.seeded([]);

  final _subscriptionErrorController = StreamController<Map<String, dynamic>>.broadcast();

  final _userHasNoStoresController = StreamController<void>.broadcast();
















  Stream<FullMenuData> listenToFullMenu(int storeId) =>
      _fullMenuStreams.putIfAbsent(storeId, () => BehaviorSubject()).stream;
  Stream<StoreChatbotConfig?> get onChatbotConfigUpdated => _chatbotConfigController.stream;
  StreamSubscription? _deviceConnectivitySubscription;
  Stream<bool> get isConnectedStream => _connectionStatusController.stream;
  Stream<Map<int, int>> get onStoreNotification => _storeNotificationController.stream;
  Stream<OrderNotification> get onOrderNotification => _orderNotificationController.stream;
  Stream<Store?> get onActiveStoreUpdated => _activeStoreController.stream;
  Stream<List<StoreWithRole>> get onAdminStoresList => _adminStoresListController.stream;
  Map<int, int> get currentNotificationCounts => _storeNotificationController.value;
  Stream<Store?> get onStoreDetailsUpdated => _storeDetailsController.stream;
  Stream<Map<String, dynamic>?> get onDashboardDataUpdated => _dashboardDataController.stream;
  Stream<PrintJobPayload> get onNewPrintJobsAvailable => _newPrintJobsController.stream;
  Stream<List<Product>> listenToProducts(int storeId) => _productsStreams.putIfAbsent(storeId, () => BehaviorSubject()).stream;
  Stream<List<OrderDetails>> listenToOrders(int storeId) => _ordersStreams.putIfAbsent(storeId, () => BehaviorSubject()).stream;
  Stream<List<Table>> listenToTables(int storeId) => _tablesStreams.putIfAbsent(storeId, () => BehaviorSubject()).stream;
  Stream<List<Command>> listenToCommands(int storeId) => _commandsStreams.putIfAbsent(storeId, () => BehaviorSubject()).stream;
  Stream<PayablesDashboardMetrics?> get onPayablesDashboardUpdated => _payablesDashboardController.stream;
  Stream<FinancialsData?> get onFinancialsUpdated => _financialsController.stream;
  Stream<ConnectivityStatus> get onConnectivityChanged => _connectivityStatusController.stream;
  Stream<List<Category>> listenToCategories(int storeId) =>
      _categoriesStreams.putIfAbsent(storeId, () => BehaviorSubject.seeded([])).stream;
  Stream<List<Variant>> listenToVariants(int storeId) =>
      _variantsStreams.putIfAbsent(storeId, () => BehaviorSubject.seeded([])).stream;
  Stream<Map<String, dynamic>> get onStuckOrderAlert => _stuckOrderAlertController.stream;
  Stream<ChatbotMessage> get onNewChatMessage => _newChatMessageController.stream;

  Stream<List<ChatbotConversation>> get onConversationsListUpdated => _conversationsListController.stream;
  Stream<Map<String, dynamic>> get onSubscriptionError => _subscriptionErrorController.stream;
  Stream<void> get onUserHasNoStores => _userHasNoStoresController.stream;







  /// Reivindica um trabalho de impressão específico pelo seu ID.
  Future<Either<String, Map<String, dynamic>>> claimSpecificPrintJob(int jobId) {
    print('[RealtimeRepository] Enviando reivindicação para o trabalho de impressão #$jobId');
    return _emitWithAck('claim_specific_print_job', {'job_id': jobId});
  }




  // Conjuntos para controle de salas
  final _joinedStores = <int>{};
  final _joiningInProgress = <int>{};

  RealtimeRepository() {
    log('[RealtimeRepository] Instância criada, aguardando inicialização...');
    _listenToDeviceConnectivity();
  }




  void _listenToDeviceConnectivity() {
    _deviceConnectivitySubscription = _connectivityService.onConnectivityChanged.listen((result) {
      log('[Connectivity] Status da rede do dispositivo mudou para: $result');

      if (result != ConnectivityResult.none) {
        // Lógica para quando a internet VOLTA (já existente e correta)
        if (_socket != null && !_socket!.connected) {
          log('[Connectivity] A rede do dispositivo está ativa, mas o socket está desconectado. Forçando tentativa de reconexão...');
          _socket!.connect();
        }
      } else {
        // ✅ LÓGICA ADICIONADA: O que fazer quando a internet CAI
        log('[Connectivity] A rede do dispositivo foi perdida. Atualizando status para desconectado.');
        // Forçamos nosso status interno para 'desconectado' imediatamente.
        _connectivityStatusController.add(ConnectivityStatus.disconnected);
      }
    });
  }


  Future<void> initialize(String adminToken) async {
    _lastUsedAdminToken = adminToken; // Armazena o token para reconexão
    if (_socket != null) {
      log('[Socket] Conexão existente encontrada. Desconectando para reiniciar...');
      _socket!.dispose(); // Usa dispose para limpar tudo
    }

    log('[Socket] Inicializando conexão com o socket...');
    final options = IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setReconnectionAttempts(10) // Limita as tentativas para evitar loops infinitos
        .setReconnectionDelay(2000)
        .setReconnectionDelayMax(10000)
        .setQuery({'admin_token': adminToken})
        .build();

    _socket = IO.io('https://api-pdvix-production.up.railway.app/admin', options);

    _registerSocketListeners();
    _socket!.connect();
  }

  void _registerSocketListeners() {

    if (_socket == null) return;

    _socket!.clearListeners(); // Garante que não haja listeners duplicados

    _socket!.onConnect((_) {
      if (_isDisposed) return;
      log('[Socket] ✅ Conectado com sucesso! ID: ${_socket!.id}');
      // ✅ ALTERAÇÃO: Ao conectar, entramos no modo de SINCRONIZAÇÃO
      _connectivityStatusController.add(ConnectivityStatus.synchronizing);

      if (_lastJoinedStoreId != null) {
        log('[Socket] Reconectado. Reentrando automaticamente na sala da loja $_lastJoinedStoreId...');
        // Adiciona um .catchError para lidar com falhas na reconexão
        joinStoreRoom(_lastJoinedStoreId!).catchError((e) {
          log('❌ Falha ao reentrar na sala $_lastJoinedStoreId após reconexão: $e');
          // Você pode tentar novamente após um tempo ou notificar o usuário
        });
      }
    });


    _socket!.onDisconnect((reason) {
      if (_isDisposed) return;
      log('[Socket] 🔌 Desconectado: $reason');
      _connectivityStatusController.add(ConnectivityStatus.disconnected);

      // ✅ CORREÇÃO PRINCIPAL: Limpe o controle de salas ao desconectar
      _joinedStores.clear();
      _joiningInProgress.clear();
      log('[Socket] Controle de salas limpo devido à desconexão.');
    });



    _socket!.on('reconnect_attempt', (_) {
      if (_isDisposed) return;
      log('[Socket] ⏳ Tentando reconectar...');
      _connectivityStatusController.add(ConnectivityStatus.reconnecting);
    });

    _socket!.on('connect_error', (data) {
      if (_isDisposed) return;
      log('[Socket] ❌ Erro de conexão: $data');
      _handleConnectionAuthError();
    });

    _socket!.on('error', (data) {
      if (_isDisposed) return;
      log('[Socket] ❌ Erro geral do socket: $data');
      if (data.toString().contains('Authentication error')) {
        _handleConnectionAuthError();
      }
    });



    // Listeners de Dados
    _socket!.on('new_order_notification', _handleNewOrderNotification);


    _socket!.on('chatbot_config_updated', _handleChatbotConfigUpdated);


    _socket!.on('admin_stores_list', (data) {
      log('✅ Evento recebido: admin_stores_list');
      try {
        // Validação robusta do payload
        if (data is Map<String, dynamic> && data['stores'] is List) {
          final storesData = data['stores'] as List;

          // Se a lista estiver vazia, emita uma lista vazia.
          if (storesData.isEmpty) {
            log('🔵 [RealtimeRepository] Payload de "admin_stores_list" continha uma lista de lojas vazia.');
            _adminStoresListController.add([]);
            return;
          }

          // Mapeia os dados para a lista de objetos, com tratamento de erro individual.
          final storesList = storesData.map<StoreWithRole?>((json) {
            try {
              return StoreWithRole.fromJson(json as Map<String, dynamic>);
            } catch (e) {
              log('❌ Erro ao fazer parse de um item da loja em "admin_stores_list": $e');
              return null; // Retorna nulo se um item específico falhar
            }
          }).whereType<StoreWithRole>().toList(); // Filtra quaisquer nulos que possam ter ocorrido

          log('✅ [RealtimeRepository] Lista de lojas processada com ${storesList.length} item(ns). Emitindo para o stream.');
          _adminStoresListController.add(storesList);

        } else {
          // Se o payload não tiver o formato esperado, loga o erro mas não quebra o app.
          log('⚠️ [RealtimeRepository] Payload de "admin_stores_list" com formato inesperado: $data');
          // Opcional: emitir uma lista vazia se preferir
          // _adminStoresListController.add([]);
        }
      } catch (e, st) {
        log('❌ Erro geral ao processar o evento "admin_stores_list"', error: e, stackTrace: st);
      }
    });


    // ADICIONE ESTE NOVO LISTENER
    _socket!.on('stuck_order_alert', (data) {
      log('🚨 Evento recebido: stuck_order_alert com dados: $data');
      if (data is Map<String, dynamic>) {
        _stuckOrderAlertController.add(data);
      }
    });

    _socket!.on('store_details_updated', _handleStoreDetailsUpdated);
    _socket!.on('dashboard_data_updated', _handleDashboardDataUpdated);

    _socket!.on('products_updated', _handleProductsUpdated);
    _socket!.on('orders_initial', _handleOrdersInitial);
    _socket!.on('order_updated', _handleOrderUpdated);
    _socket!.on('tables_and_commands', _handleTablesAndCommands);
     _socket!.on('payables_data_updated', _handlePayablesDataUpdated);
     _socket!.on('new_print_jobs_available', _handleNewPrintJobsAvailable);

    _socket!.on('financials_updated', _handleFinancialsUpdated);

    _socket!.on('new_chat_message', _handleNewChatMessage);
    _socket!.on('conversations_initial', _handleConversationsInitial);

    _socket!.on('subscription_error', _handleSubscriptionError);

    _socket!.on('user_has_no_stores', (data) {
      log('🔵 Evento recebido: user_has_no_stores - Usuário não possui lojas');
      _userHasNoStoresController.add(null);
    });



  }

  // ✅ 4. CRIE O MÉTODO HANDLER
  void _handleSubscriptionError(dynamic data) {
    log('❌ Evento recebido: subscription_error');
    try {
      if (data is Map<String, dynamic>) {
        _subscriptionErrorController.add(data);
      }
    } catch (e, st) {
      log('[Socket] ❌ Erro em _handleSubscriptionError', error: e, stackTrace: st);
    }
  }


  void _handleNewChatMessage(dynamic data) {
    log('✅ Evento recebido: new_chat_message');
    try {
      final message = ChatbotMessage.fromJson(data as Map<String, dynamic>);
      _newChatMessageController.add(message);
    } catch (e, st) {
      log('[Socket] ❌ Erro em _handleNewChatMessage', error: e, stackTrace: st);
    }
  }

  // 4. Adicione a nova função handler
  void _handleConversationsInitial(dynamic data) {
    log('✅ Evento recebido: conversations_initial');
    try {
      final conversations = (data as List)
          .map((c) => ChatbotConversation.fromJson(c as Map<String, dynamic>))
          .toList();
      _conversationsListController.add(conversations);
    } catch (e, st) {
      log('[Socket] ❌ Erro em _handleConversationsInitial', error: e, stackTrace: st);
    }
  }



  void _handleChatbotConfigUpdated(dynamic data) {
    // ✅ PONTO DE PROVA A
    log("🕵️‍♂️ PONTO A: DADO BRUTO RECEBIDO DO SOCKET:\n$data");
    try {
      final config = StoreChatbotConfig.fromJson(data as Map<String, dynamic>);
      _chatbotConfigController.add(config);
    } catch (e, st) {
      log('[Socket] ❌ Erro em chatbot_config_updated', error: e, stackTrace: st);
    }
  }


  Future<void> _handleConnectionAuthError() async {
    // Se já estamos tratando uma reconexão, não faz nada.
    if (_authRepository.isRefreshingToken) return;

    log('[Socket] Erro de autenticação detectado. Tentando renovar token...');
    final refreshResult = await _authRepository.refreshAccessToken();

    if (refreshResult.isRight) {
      final newAccessToken = _authRepository.accessToken;
      if (newAccessToken != null) {
        log('[Socket] Token renovado. Reinicializando conexão do socket...');
        await initialize(newAccessToken); // Reinicia com o novo token
      }
    } else {
      log('[Socket] ❌ Falha ao renovar o token durante a reconexão.');
      // O AuthCubit deve ouvir as mudanças no AuthRepository e deslogar o usuário.
    }
  }

  void _handleNewOrderNotification(dynamic data) {
    // ✅ LOG ADICIONADO
    log('✅ Evento recebido: new_order_notification');
    try {


      log('🔔 Notificação de novo pedido recebida: $data');
      // Extrai o payload, lidando com os formatos [evento, dados] ou apenas {dados}
      final payload = (data is List && data.length > 1 && data[1] is Map)
          ? data[1] as Map<String, dynamic>
          : data as Map<String, dynamic>;

      // --- Lógica ANTIGA (para o contador de sininho) - MANTIDA ---
      final storeId = payload['store_id'] as int;
      final currentNotifications = Map<int, int>.from(_storeNotificationController.value);
      currentNotifications.update(storeId, (value) => value + 1, ifAbsent: () => 1);
      _storeNotificationController.add(currentNotifications);

      // --- Lógica NOVA (para o SnackBar) - ADICIONADA ---
      final notification = OrderNotification.fromJson(payload);
      _orderNotificationController.add(notification);

    } catch (e, st) {
      log('[Socket] ❌ Erro ao processar notificação de pedido', error: e, stackTrace: st);
    }
  }




  void _handleStoreDetailsUpdated(dynamic data) {
    // ✅ PASSO 1: IMPRIMIR OS DADOS BRUTOS QUE CHEGAM DO BACKEND
    print('--- 🕵️ PONTO DE DEBUG A: DADOS BRUTOS DO SOCKET (store_details_updated) ---');
    var jsonEncoder = const JsonEncoder.withIndent('  '); // Formata o JSON
    print(jsonEncoder.convert(data));
    print('-------------------------------------------------------------------------');

    try {
      // O resto do seu código continua aqui...
      final Map<String, dynamic> storeData = Map.from(data['store']);
      if (data['subscription'] != null) {
        storeData['subscription'] = data['subscription'];
      }

      final store = Store.fromJson(storeData);

      // ✅ PASSO 2: IMPRIMIR OS DADOS APÓS SEREM CONVERTIDOS PELOS MODELS DO DART
      print('--- 🕵️ PONTO DE DEBUG B: DADOS APÓS PARSE NO DART ---');
      if (store.relations.coupons.isNotEmpty) {
        print('✅ Sucesso! Encontrados ${store.relations.coupons.length} cupons no objeto Store.');
        // Vamos inspecionar as regras do primeiro cupom da lista
        final firstCoupon = store.relations.coupons.first;
        print('🔎 O primeiro cupom (código: "${firstCoupon.code}") tem ${firstCoupon.rules.length} regras.');
        if (firstCoupon.rules.isNotEmpty) {
          print('  -> Detalhe da primeira regra: tipo=${firstCoupon.rules.first.ruleType}, valor=${firstCoupon.rules.first.value}');
        }
      } else {
        print('❌ Problema? Nenhum cupom encontrado no objeto Store após o parse.');
      }
      print('-----------------------------------------------------------');

      _storeDetailsController.add(store);

    } catch (e, st) {
      log('[Socket] ❌ Erro em store_details_updated', error: e, stackTrace: st);
    }
  }

  void _handleDashboardDataUpdated(dynamic data) {
    log('✅ Evento recebido: dashboard_data_updated');

   // print(data);
    try {
      // Simplesmente repassamos o mapa de dados
      _dashboardDataController.add(data as Map<String, dynamic>);
    } catch (e, st) {
      log('[Socket] ❌ Erro em dashboard_data_updated', error: e, stackTrace: st);
    }
  }


  // ✅ 2. SUBSTITUA SEU MÉTODO _handleProductsUpdated INTEIRO POR ESTE
  void _handleProductsUpdated(dynamic data) {
    log('✅ Evento recebido: products_updated (payload completo)');
    try {
      if (data is! Map || !data.containsKey('store_id')) return;
      final storeId = data['store_id'] as int;

      // Parse das listas principais
      final allProducts = (data['products'] as List? ?? []).map((p) => Product.fromJson(p)).toList();
      final allCategories = (data['categories'] as List? ?? []).map((c) => Category.fromJson(c)).toList();
      final allVariants = (data['variants'] as List? ?? []).map((v) => Variant.fromJson(v)).toList();
//print(data);
      // A RECONCILIAÇÃO QUE JÁ CONHECEMOS
      final productMap = {for (var p in allProducts) p.id: p};
      final reconciledCategories = <Category>[];
      for (final category in allCategories) {
        final newProductLinks = <ProductCategoryLink>[];
        for (final link in category.productLinks) {
          final fullProduct = productMap[link.productId];
          if (fullProduct != null) {
            newProductLinks.add(link.copyWith(product: fullProduct));
          } else {
            newProductLinks.add(link);
          }
        }
        reconciledCategories.add(category.copyWith(productLinks: newProductLinks));
      }

      // ✅ 3. EMITE UM ÚNICO PACOTE DE DADOS CONSISTENTE
      _fullMenuStreams.putIfAbsent(storeId, () => BehaviorSubject()).add(
        FullMenuData(
          products: allProducts,
          categories: reconciledCategories, // A lista já corrigida!
          variants: allVariants,
        ),
      );


      _connectivityStatusController.add(ConnectivityStatus.connected);
      log('[Socket] Sincronização de dados completa. Status: Conectado.');

    } catch (e, st) {
      log('[Socket] ❌ Erro CRÍTICO em _handleProductsUpdated.', error: e, stackTrace: st);
    }
  }




  void _handleOrdersInitial(dynamic data) {
    // ✅ LOG ADICIONADO
    log('✅ Evento recebido: orders_initial');
    try {
      if (data is! Map || !data.containsKey('store_id')) return;
      final storeId = data['store_id'] as int;
      final orders = (data['orders'] as List? ?? []).map((e) => OrderDetails.fromJson(e as Map<String, dynamic>)).toList();
      _ordersStreams.putIfAbsent(storeId, () => BehaviorSubject()).add(orders);
    } catch (e, st) {
      log('[Socket] ❌ Erro em orders_initial', error: e, stackTrace: st);
    }
  }

  void _handleOrderUpdated(dynamic data) {
    // ✅ LOG ADICIONADO
    log('✅ Evento recebido: order_updated');
    try {
      final Map<String, dynamic> orderDataPayload = (data is List && data.isNotEmpty) ? data[0] : data;
      final updatedOrder = OrderDetails.fromJson(orderDataPayload);
      final storeId = updatedOrder.storeId;

      final ordersSubject = _ordersStreams.putIfAbsent(storeId, () => BehaviorSubject.seeded([]));
      if (ordersSubject.isClosed) return;

      final currentOrders = List<OrderDetails>.from(ordersSubject.value);
      final index = currentOrders.indexWhere((o) => o.id == updatedOrder.id);

      if (index != -1) {
        currentOrders[index] = updatedOrder;
      } else {
        currentOrders.insert(0, updatedOrder);

        // ✅ NOVA LÓGICA: Apenas notifica o app sobre o novo pedido.
        print('[RealtimeRepository] Notificando sobre novo pedido para impressão: #${updatedOrder.id}');

      }
      ordersSubject.add(currentOrders);
    } catch (e, st) {
      log('[Socket] ❌ Erro em order_updated', error: e, stackTrace: st);
    }
  }

  void _handleTablesAndCommands(dynamic data) {
    // ✅ LOG ADICIONADO
    log('✅ Evento recebido: tables_and_commands');
    try {
      if (data is! Map || !data.containsKey('store_id')) return;
      final storeId = data['store_id'] as int;
      final tables = (data['tables'] as List? ?? []).map((e) => Table.fromJson(e)).toList();
      final commands = (data['commands'] as List? ?? []).map((e) => Command.fromJson(e)).toList();

      _tablesStreams.putIfAbsent(storeId, () => BehaviorSubject()).add(tables);
      _commandsStreams.putIfAbsent(storeId, () => BehaviorSubject()).add(commands);
    } catch (e, st) {
      log('[Socket] ❌ Erro em tables_and_commands', error: e, stackTrace: st);
    }
  }

  void _handleNewPrintJobsAvailable(dynamic data) {
    // ✅ LOG ADICIONADO E AJUSTADO
    log('✅ Evento recebido: new_print_jobs_available');
    try {
      final payload = data is List ? data[1] : data; // Lida com o formato do seu socket

      final jobsList = (payload['jobs'] as List)
          .map((job) => PrintJob(id: job['id'], destination: job['destination']))
          .toList();

      final printPayload = PrintJobPayload(
        orderId: payload['order_id'],
        jobs: jobsList,
      );

      _newPrintJobsController.add(printPayload);
    } catch (e, st) {
      log('[Socket] ❌ Erro em new_print_jobs_available', error: e, stackTrace: st);
    }
  }

  void _handlePayablesDataUpdated(dynamic data) {
    log('✅ Evento recebido: payables_data_updated');
    try {
      // Usamos o nosso modelo Dart para converter o JSON em um objeto tipado
      final metrics = PayablesDashboardMetrics.fromJson(data as Map<String, dynamic>);
      _payablesDashboardController.add(metrics);
    } catch (e, st) {
      log('[Socket] ❌ Erro em payables_data_updated', error: e, stackTrace: st);
    }
  }


  void _handleFinancialsUpdated(dynamic data) {
    log('✅ Evento recebido: financials_updated');
    try {
      final payload = data as Map<String, dynamic>;

      // Processa as listas de Contas a Pagar
      final payables = (payload['payables'] as List? ?? []).map((p) => StorePayable.fromJson(p)).toList();
      final suppliers = (payload['suppliers'] as List? ?? []).map((s) => Supplier.fromJson(s)).toList();
      final payableCategories = (payload['payable_categories'] as List? ?? []).map((c) => PayableCategory.fromJson(c)).toList();

      // ✅ ADIÇÃO: Processa as novas listas de Contas a Receber
      final receivables = (payload['receivables'] as List? ?? []).map((r) => StoreReceivable.fromJson(r)).toList();
      final receivableCategories = (payload['receivable_categories'] as List? ?? []).map((c) => ReceivableCategory.fromJson(c)).toList();

      _financialsController.add(FinancialsData(
        payables: payables,
        suppliers: suppliers,
        payableCategories: payableCategories,
        receivables: receivables,
        receivableCategories: receivableCategories,
      ));
    } catch (e, st) {
      log('[Socket] ❌ Erro em financials_updated', error: e, stackTrace: st);
    }
  }


// Em: repositories/realtime_repository.dart

  Future<void> joinStoreRoom(int storeId) async {
    _lastJoinedStoreId = storeId;

    if (_socket == null || !_socket!.connected) {
      log('[Socket] Conexão indisponível. A tentativa de entrar na sala $storeId ocorrerá na reconexão.');
      return;
    }

    // Controle para não entrar na sala múltiplas vezes
    if (_joinedStores.contains(storeId) || _joiningInProgress.contains(storeId)) {
      log('[Socket] Já está na sala $storeId ou a entrada está em andamento. Ignorando.');
      return;
    }

    _joiningInProgress.add(storeId);
    log('[Socket] Tentando entrar na sala da loja $storeId...');

    try {
      // Limpa as notificações da loja antes de entrar
      clearNotificationsForStore(storeId);

      final completer = Completer<void>();

      // ⚠️ ATENÇÃO: Verifique se o nome do evento no seu backend é 'join_admin_store_room'
      _socket!.emitWithAck('join_store_room', {'store_id': storeId},
          ack: ([response]) {
            if (response is Map && response['error'] != null) {
              final error = Exception('Erro do servidor ao entrar na sala: ${response['error']}');
              if (!completer.isCompleted) completer.completeError(error);
            } else {
              if (!completer.isCompleted) completer.complete();
            }
          });

      // Espera pela confirmação do servidor por até 10 segundos
      await completer.future.timeout(const Duration(seconds: 10));

      // Se chegou até aqui, a entrada foi bem-sucedida
      _joinedStores.add(storeId);
      log('[Socket] ✅ Entrada na sala da loja $storeId confirmada.');

    } catch (e) {
      log('[Socket] ❌ Falha ao entrar na sala $storeId: $e');
      // Se falhar, re-lança o erro para que a camada superior possa tratar se necessário
      rethrow;
    } finally {
      // Garante que a flag de "entrando" seja removida, mesmo se der erro
      _joiningInProgress.remove(storeId);
    }
  }



  Future<void> leaveStoreRoom(int storeId) async {
    if (_socket == null || !_socket!.connected) return;

    // Limpa a memória da última sala se estivermos saindo dela
    if (_lastJoinedStoreId == storeId) {
      _lastJoinedStoreId = null;
    }
    _socket!.emit('leave_store_room', {'store_id': storeId});
    log('[Socket] Saiu da sala da loja $storeId');
  }


  Future<Either<String, Map<String, dynamic>>> setConsolidatedStores(List<int> storeIds) async {
    return _emitWithAck('set_consolidated_stores', {'store_ids': storeIds});
  }

  Future<Either<String, void>> updateOrderStatus(int orderId, String newStatus) async {
    final result = await _emitWithAck('update_order_status', {'order_id': orderId, 'new_status': newStatus});
    return result.isRight ? const Right(null) : Left(result.left);
  }


  Future<Either<String, void>> updatePrintJobStatus(int jobId, String status) {
    print('[RealtimeRepository] Atualizando status do trabalho de impressão #$jobId para "$status"');

    // Usa o helper _emitWithAck que já trata erros e timeouts.
    final result = _emitWithAck('update_print_job_status', {
      'job_id': jobId,
      'status': status,
    });

    // Converte o resultado para o tipo esperado (Either<String, void>)
    return result.then((either) => either.isRight ? const Right(null) : Left(either.left));
  }




// Assumindo que este código está no seu RealtimeRepository

  Future<Either<String, Map<String, dynamic>>> updateStoreSettings({
    required int storeId,
    // Para consistência, vamos usar os mesmos nomes que definimos no Cubit
    bool? deliveryEnabled,      // <-- Parâmetro renomeado
    bool? pickupEnabled,        // <-- Parâmetro renomeado
    bool? tableEnabled,         // <-- Parâmetro renomeado
    bool? isStoreOpen,
    bool? autoAcceptOrders,
    bool? autoPrintOrders,
    String? mainPrinterDestination,
    String? kitchenPrinterDestination,
    String? barPrinterDestination,
  }) {
    final data = <String, dynamic>{
      'store_id': storeId,
      // Agora, usamos os nomes de campo que o backend Python espera
      if (deliveryEnabled != null) 'delivery_enabled': deliveryEnabled, // <-- Chave corrigida
      if (pickupEnabled != null) 'pickup_enabled': pickupEnabled,       // <-- Chave corrigida
      if (tableEnabled != null) 'table_enabled': tableEnabled,         // <-- Chave corrigida
      if (isStoreOpen != null) 'is_store_open': isStoreOpen,
      if (autoAcceptOrders != null) 'auto_accept_orders': autoAcceptOrders,
      if (autoPrintOrders != null) 'auto_print_orders': autoPrintOrders,

      // Para campos de texto, é melhor enviar nulo se eles forem nulos,
      // para que o backend possa limpá-los se necessário.
      'main_printer_destination': mainPrinterDestination,
      'kitchen_printer_destination': kitchenPrinterDestination,
      'bar_printer_destination': barPrinterDestination,
    };

    // Remove chaves com valores nulos, exceto para os destinos de impressora que queremos poder limpar.
    data.removeWhere((key, value) {
      // Mantém as chaves da impressora mesmo que o valor seja nulo.
      if (key.contains('_printer_destination')) return false;
      // Remove outras chaves se o valor for nulo.
      return value == null;
    });


    return _emitWithAck('update_operation_config', data); // <-- O nome do evento também deve ser verificado
  }



  /// Wrapper genérico para emitir eventos com ACK e tratar erros.
  Future<Either<String, Map<String, dynamic>>> _emitWithAck(String event, dynamic payload) async {
    if (_socket == null || !_socket!.connected) {
      return Left('Socket não conectado.');
    }
    try {
      final completer = Completer<Either<String, Map<String, dynamic>>>();
      _socket!.emitWithAck(event, payload, ack: ([dynamic args]) {
        dynamic data;
        // Tenta extrair os dados, seja de uma lista ou diretamente.
        if (args is List && args.isNotEmpty) {
          data = args[0];
        } else if (args is Map) {
          data = args;
        }

        if (data is Map && data['error'] != null) {
          completer.complete(Left(data['error'] as String));
        } else if (data is Map<String, dynamic>) {
          completer.complete(Right(data));
        } else {
          // Se não for um mapa válido, retorna um mapa vazio para evitar erros de null.
          completer.complete(const Right({}));
        }
      });
      return await completer.future.timeout(const Duration(seconds: 10));
    } catch (e) {
      return Left('Falha na comunicação: ${e.toString()}');
    }
  }




  /// ✨ NOVO: Limpa as notificações para uma loja específica.
  void clearNotificationsForStore(int storeId) {
    // Pega o mapa atual de notificações
    final currentNotifications = Map<int, int>.from(_storeNotificationController.value);

    // Se a loja tiver notificações, remove a entrada dela do mapa
    if (currentNotifications.containsKey(storeId)) {
      currentNotifications.remove(storeId);
      // Emite o novo mapa sem as notificações da loja limpa
      _storeNotificationController.add(currentNotifications);
    }
  }




  Future<Either<String, Map<String, dynamic>>> claimPrintJob(int orderId) {
    print('[RealtimeRepository] Enviando evento claim_print_job para o pedido $orderId');
    return _emitWithAck('claim_print_job', {'order_id': orderId});
  }








  void dispose() {
    log('[RealtimeRepository] Disposando recursos...');

    _productsStreams.values.forEach((s) => s.close());
    _variantsStreams.values.forEach((s) => s.close());
    _categoriesStreams.values.forEach((s) => s.close());
    _ordersStreams.values.forEach((s) => s.close());
    _tablesStreams.values.forEach((s) => s.close());
    _commandsStreams.values.forEach((s) => s.close());
    _chatbotConfigController.close();
    _payablesDashboardController.close();
    _activeStoreController.close();
    _productsStreams.clear();
    _ordersStreams.clear();
    _tablesStreams.clear();
    _commandsStreams.clear();
    _financialsController.close();
    _adminStoresListController.close();
    _storeNotificationController.close();
    _connectionStatusController.close();
    _stuckOrderAlertController.close();
    _orderNotificationController.close();
    _newPrintJobsController.close();
    _deviceConnectivitySubscription?.cancel();
    _userHasNoStoresController.close();
    _adminStoresListController.close();
    _socket?.dispose();
    log('[RealtimeRepository] Todos os streams e o socket foram fechados');
  }
}