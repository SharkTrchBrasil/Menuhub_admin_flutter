import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:either_dart/either.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

// Adapte os imports para os caminhos corretos do seu projeto
import 'package:totem_pro_admin/models/command.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';
import 'package:totem_pro_admin/models/table.dart';
import 'package:totem_pro_admin/services/auth_service.dart';

import '../core/enums/connectivity_status.dart';
import '../models/category.dart';
import '../models/full_menu_data.dart';
import '../models/order_notification.dart';
import '../models/payable_category.dart';
import '../models/payables_dashboard.dart';
import '../models/print_job.dart';
import '../models/prodcut_category_links.dart';
import '../models/receivable_category.dart';
import '../models/store.dart';
import '../models/store_chatbot_config.dart';
import '../models/store_payable.dart';
import '../models/store_receivable.dart';
import '../models/supplier.dart';
import '../models/totem_auth.dart';
import '../models/totem_auth_and_stores.dart';
import '../models/variant.dart';
import '../services/connectivity_service.dart';
import 'auth_repository.dart'; // Para ter acesso ao TotemAuth

import 'dart:convert'; // Para usar o JsonEncoder



// ✅ ALTERAÇÃO: A classe helper agora contém todas as listas financeiras
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
  // ✅ Variáveis de controle de estado
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



  final _variantsStreams = <int, BehaviorSubject<List<Variant>>>{};
  final _categoriesStreams = <int, BehaviorSubject<List<Category>>>{};

  final _financialsController = BehaviorSubject<FinancialsData?>();

  final _connectivityStatusController = BehaviorSubject<ConnectivityStatus>();

  final ConnectivityService _connectivityService = GetIt.I<ConnectivityService>();

  final _fullMenuStreams = <int, BehaviorSubject<FullMenuData>>{};

  final _chatbotConfigController = BehaviorSubject<StoreChatbotConfig?>();





















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

  final _stuckOrderAlertController = StreamController<Map<String, dynamic>>.broadcast();

// 2. Crie um getter público para o stream
  Stream<Map<String, dynamic>> get onStuckOrderAlert => _stuckOrderAlertController.stream;

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


    // ✅ 3. ADICIONE O LISTENER PARA O NOVO EVENTO DEDICADO
    _socket!.on('chatbot_config_updated', _handleChatbotConfigUpdated);


    _socket!.on('admin_stores_list', (data) {
      // ✅ LOG ADICIONADO
      log('✅ Evento recebido: admin_stores_list');
      if (data is Map && data['stores'] is List) {
        final stores = (data['stores'] as List).map((s) => StoreWithRole.fromJson(s)).toList();
        _adminStoresListController.add(stores);
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




  Future<Either<String, Map<String, dynamic>>> updateStoreSettings({
    required int storeId,
    bool? isDeliveryActive,
    bool? isTakeoutActive,
    bool? isTableServiceActive,
    bool? isStoreOpen,
    bool? autoAcceptOrders,
    bool? autoPrintOrders,
    String? mainPrinterDestination,
    String? kitchenPrinterDestination,
    String? barPrinterDestination,
  }) {
    final data = <String, dynamic>{
      'store_id': storeId,
      if (isDeliveryActive != null) 'is_delivery_active': isDeliveryActive,
      if (isTakeoutActive != null) 'is_takeout_active': isTakeoutActive,
      if (isTableServiceActive != null) 'is_table_service_active': isTableServiceActive,
      if (isStoreOpen != null) 'is_store_open': isStoreOpen,
      if (autoAcceptOrders != null) 'auto_accept_orders': autoAcceptOrders,
      if (autoPrintOrders != null) 'auto_print_orders': autoPrintOrders,
      'main_printer_destination': mainPrinterDestination,
      'kitchen_printer_destination': kitchenPrinterDestination,
      'bar_printer_destination': barPrinterDestination,
    };

    return _emitWithAck('update_store_settings', data);
  }


  // --- Métodos Auxiliares e de Limpeza ---

  void _clearNotificationForStore(int storeId) {
    final currentNotifications = Map<int, int>.from(_storeNotificationController.value);
    if (currentNotifications.containsKey(storeId)) {
      currentNotifications.remove(storeId);
      _storeNotificationController.add(currentNotifications);
      log('✨ Notificações para a loja $storeId foram limpas.');
    }
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



  void _closeStoreStreams(int storeId) {
    log('[Socket] Fechando streams e limpando cache para loja $storeId');

    _productsStreams.remove(storeId)?.close();
    _ordersStreams.remove(storeId)?.close();
    _tablesStreams.remove(storeId)?.close();
    _commandsStreams.remove(storeId)?.close();
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
    _socket?.dispose();
    log('[RealtimeRepository] Todos os streams e o socket foram fechados');
  }
}