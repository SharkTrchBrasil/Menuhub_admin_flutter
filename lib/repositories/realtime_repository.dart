import 'dart:async';
import 'dart:developer';

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

import '../models/order_notification.dart';
import '../models/store.dart';
import '../models/totem_auth.dart';
import '../models/totem_auth_and_stores.dart'; // Para ter acesso ao TotemAuth

class RealtimeRepository {
  // A variável do socket agora pode ser nula e será inicializada corretamente.
  IO.Socket? _socket;


  int? _lastJoinedStoreId;

  // Streams de estado e notificações
  final _connectionStatusController = BehaviorSubject<bool>.seeded(false);
  final _storeNotificationController = BehaviorSubject<Map<int, int>>.seeded({});
  final _orderNotificationController = StreamController<OrderNotification>.broadcast();

  // Stream para a loja ativa (usado pelo ActiveStoreCubit)
  final _activeStoreController = BehaviorSubject<Store?>.seeded(null);

  // Streams de dados específicos (se ainda usados em outras partes)
  final _productsStreams = <int, BehaviorSubject<List<Product>>>{};
  final _ordersStreams = <int, BehaviorSubject<List<OrderDetails>>>{};
  final _tablesStreams = <int, BehaviorSubject<List<Table>>>{};
  final _commandsStreams = <int, BehaviorSubject<List<Command>>>{};
  final _adminStoresListController = BehaviorSubject<List<StoreWithRole>>.seeded([]);

  // Getters públicos
  Stream<bool> get isConnectedStream => _connectionStatusController.stream;
  Stream<Map<int, int>> get onStoreNotification => _storeNotificationController.stream;
  Stream<OrderNotification> get onOrderNotification => _orderNotificationController.stream;
  Stream<Store?> get onActiveStoreUpdated => _activeStoreController.stream;
  Stream<List<StoreWithRole>> get onAdminStoresList => _adminStoresListController.stream;
  Map<int, int> get currentNotificationCounts => _storeNotificationController.value;


  // --- Métodos Públicos ---

  Stream<List<Product>> listenToProducts(int storeId) => _productsStreams.putIfAbsent(storeId, () => BehaviorSubject()).stream;
  Stream<List<OrderDetails>> listenToOrders(int storeId) => _ordersStreams.putIfAbsent(storeId, () => BehaviorSubject()).stream;
  Stream<List<Table>> listenToTables(int storeId) => _tablesStreams.putIfAbsent(storeId, () => BehaviorSubject()).stream;
  Stream<List<Command>> listenToCommands(int storeId) => _commandsStreams.putIfAbsent(storeId, () => BehaviorSubject()).stream;













  // Conjuntos para controle de salas
  final _joinedStores = <int>{};
  final _joiningInProgress = <int>{};

  RealtimeRepository() {
    log('[RealtimeRepository] Instância criada, aguardando inicialização...');
  }

  /// **CORREÇÃO PRINCIPAL:** O método 'initialize' agora recebe o objeto 'TotemAuth'.
  /// Ele contém o 'sid' e o 'access_token' necessários para uma autenticação segura.
  Future<void> initialize(TotemAuth totemAuth) async {
    // Se já existe um socket, desconecte antes de criar um novo para garantir uma conexão limpa.
    if (_socket != null && _socket!.connected) {
      _socket!.disconnect();
    }

    log('[RealtimeRepository] Inicializando conexão com o socket...');
    log('[RealtimeRepository] Usando SID: ${totemAuth.sid}');



    final options = IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setReconnectionAttempts(9999)
        .setReconnectionDelay(1000)
    // **CORREÇÃO APLICADA:** Usa .setQuery() para enviar o token na URL
        .setQuery({'admin_token':  totemAuth.token,})
        .build();




    // A URL do seu backend de socket
    _socket = IO.io('https://api-pdvix-production.up.railway.app/admin', options);

    // Registra os listeners ANTES de conectar
    _registerSocketListeners();

    // Agora, conecta manualmente
    _socket!.connect();
  }

  void _registerSocketListeners() {
    if (_socket == null) return;

    // Limpa listeners antigos para evitar duplicação em reconexões
    _socket!.clearListeners();
    //
    // _socket!.on('connect', (_) {
    //   Future.microtask(() {
    //     log('[Socket] ✅ Conectado com sucesso! ID: ${_socket!.id}');
    //     _connectionStatusController.add(true);
    //     _joinedStores.clear();
    //     _joiningInProgress.clear();
    //   });
    // });

    _socket!.on('connect', (_) {

      Future.microtask(() {
      log('[Socket] ✅ Conectado com sucesso! ID: ${_socket!.id}');
      _connectionStatusController.add(true);
      _joinedStores.clear();
      _joiningInProgress.clear();

      if (_lastJoinedStoreId != null) {
        log('[Socket] Reconectado. Tentando reentrar automaticamente na sala da loja $_lastJoinedStoreId...');
       joinStoreRoom(_lastJoinedStoreId!);
      }

      });
    });





    _socket!.on('disconnect', (reason) {
      log('[Socket] 🔌 Desconectado: $reason');
      _connectionStatusController.add(false);
    });

    _socket!.on('connect_error', (data) {
      log('[Socket] ❌ Erro de conexão: $data');
      _connectionStatusController.add(false);
    });

    // Listeners de Dados
    _socket!.on('new_order_notification', _handleNewOrderNotification);




    _socket!.on('admin_stores_list', (data) {
      if (data is Map && data['stores'] is List) {
        final stores = (data['stores'] as List).map((s) => StoreWithRole.fromJson(s)).toList();
        _adminStoresListController.add(stores);
      }
    });
    _socket!.on('store_full_updated', _handleStoreUpdated);
    _socket!.on('products_updated', _handleProductsUpdated);
    _socket!.on('orders_initial', _handleOrdersInitial);
    _socket!.on('order_updated', _handleOrderUpdated);
    _socket!.on('tables_and_commands', _handleTablesAndCommands);
    // NOVO: Registra o listener para o evento de aviso de assinatura

  }


  void _handleNewOrderNotification(dynamic data) {
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













  void _handleStoreUpdated(dynamic data) {
    try {
      final Map<String, dynamic> payload;

      print(data);
      if (data is List && data.length > 1 && data[1] is Map<String, dynamic>) {
        payload = data[1] as Map<String, dynamic>;
      } else if (data is Map<String, dynamic>) {
        payload = data;
      } else {
        log('[Socket] ❌ Erro em store_full_updated: Formato de dados inesperado.');
        return;
      }

      final storeData = payload['store'] as Map<String, dynamic>;
     // final subscriptionData = payload['subscription'] as Map<String, dynamic>?;

      // if (subscriptionData != null) {
      //   storeData['subscription'] = subscriptionData;
      // }

      final store = Store.fromJson(storeData);
      _activeStoreController.add(store);
    } catch (e, st) {
      log('[Socket] ❌ Erro em store_full_updated', error: e, stackTrace: st);
      _activeStoreController.addError('Falha ao carregar dados da loja.');
    }
  }

  void _handleProductsUpdated(dynamic data) {
    try {
      if (data is! Map || !data.containsKey('store_id')) return;
      final storeId = data['store_id'] as int;
      final products = (data['products'] as List? ?? []).map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
      _productsStreams.putIfAbsent(storeId, () => BehaviorSubject()).add(products);
    } catch (e, st) {
      log('[Socket] ❌ Erro em products_updated', error: e, stackTrace: st);
    }
  }

  void _handleOrdersInitial(dynamic data) {
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
      }
      ordersSubject.add(currentOrders);
    } catch (e, st) {
      log('[Socket] ❌ Erro em order_updated', error: e, stackTrace: st);
    }
  }

  void _handleTablesAndCommands(dynamic data) {
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








  Future<void> joinStoreRoom(int storeId) async {
    if (!_connectionStatusController.value) {
      log('[Socket] Aguardando conexão para entrar na sala $storeId...');
      try {
        await isConnectedStream.firstWhere((isConnected) => isConnected).timeout(const Duration(seconds: 10));
      } on TimeoutException {
        log('[Socket] ❌ Timeout esperando a conexão para entrar na sala $storeId.');
        throw Exception('Timeout: Socket não conectou a tempo.');
      }
    }

    if (_socket == null) {
      throw Exception('Instância do Socket é nula. Não é possível entrar na sala.');
    }

    if (_joinedStores.contains(storeId) || _joiningInProgress.contains(storeId)) {
      return;
    }
    _joiningInProgress.add(storeId);
    try {
      _clearNotificationForStore(storeId);
    //  _initializeStoreStreams(storeId);
      final completer = Completer<void>();
      _socket!.emitWithAck('join_store_room', {'store_id': storeId}, ack: ([dynamic args]) {
        final data = (args is List && args.isNotEmpty) ? args[0] : null;
        if (data is Map && data['error'] != null) {
          completer.completeError(Exception(data['error']));
        } else if (!completer.isCompleted) {
          completer.complete();
        }
      });
      await completer.future.timeout(const Duration(seconds: 10));
      _joinedStores.add(storeId);

      // ✨ PASSO 2.1: Memorize o ID da loja ao entrar com sucesso
      _lastJoinedStoreId = storeId;

      log('[Socket] ✅ Entrou na sala da loja $storeId');
    } catch (e, st) {
      log('[Socket] ❌ Falha ao entrar na sala $storeId', error: e, stackTrace: st);
      rethrow;
    } finally {
      _joiningInProgress.remove(storeId);
    }
  }




  Future<void> leaveStoreRoom(int storeId) async {
    if (_socket == null || !_socket!.connected || !_joinedStores.contains(storeId)) return;
    try {
      _joinedStores.remove(storeId);
      final completer = Completer<void>();
      _socket!.emitWithAck('leave_store_room', {'store_id': storeId}, ack: ([_]) {
        if (!completer.isCompleted) completer.complete();
      });
      await completer.future.timeout(const Duration(seconds: 5));
      _closeStoreStreams(storeId);

      // ✨ PASSO 2.2: Limpe a memória ao sair da sala
      if (_lastJoinedStoreId == storeId) {
        _lastJoinedStoreId = null;
      }

      log('[Socket] Saiu da sala da loja $storeId');
    } catch (e, st) {
      log('[Socket] ❌ Falha ao sair da sala $storeId', error: e, stackTrace: st);
    }
  }

  Future<Either<String, Map<String, dynamic>>> setConsolidatedStores(List<int> storeIds) async {
    return _emitWithAck('set_consolidated_stores', {'store_ids': storeIds});
  }

  Future<Either<String, void>> updateOrderStatus(int orderId, String newStatus) async {
    final result = await _emitWithAck('update_order_status', {'order_id': orderId, 'new_status': newStatus});
    return result.isRight ? const Right(null) : Left(result.left);
  }

  Future<Either<String, Map<String, dynamic>>> updateStoreSettings({
    required int storeId,
    bool? isDeliveryActive,
    bool? isTakeoutActive,
    bool? isTableServiceActive,
    bool? isStoreOpen,
    bool? autoAcceptOrders,
    bool? autoPrintOrders,
  }) {
    final data = <String, dynamic>{
      'store_id': storeId,
      if (isDeliveryActive != null) 'is_delivery_active': isDeliveryActive,
      if (isTakeoutActive != null) 'is_takeout_active': isTakeoutActive,
      if (isTableServiceActive != null) 'is_table_service_active': isTableServiceActive,
      if (isStoreOpen != null) 'is_store_open': isStoreOpen,
      if (autoAcceptOrders != null) 'auto_accept_orders': autoAcceptOrders,
      if (autoPrintOrders != null) 'auto_print_orders': autoPrintOrders,
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
        final data = (args is List && args.isNotEmpty) ? args[0] : null;
        if (data is Map && data['error'] != null) {
          completer.complete(Left(data['error'] as String));
        } else {
          completer.complete(Right(data as Map<String, dynamic>? ?? {}));
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








  void _initializeStoreStreams(int storeId) {

    _productsStreams.putIfAbsent(storeId, () => BehaviorSubject());
    _ordersStreams.putIfAbsent(storeId, () => BehaviorSubject());
    _tablesStreams.putIfAbsent(storeId, () => BehaviorSubject());
    _commandsStreams.putIfAbsent(storeId, () => BehaviorSubject());
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
    _ordersStreams.values.forEach((s) => s.close());
    _tablesStreams.values.forEach((s) => s.close());
    _commandsStreams.values.forEach((s) => s.close());

    _activeStoreController.close();
    _productsStreams.clear();
    _ordersStreams.clear();
    _tablesStreams.clear();
    _commandsStreams.clear();

    _adminStoresListController.close();
    _storeNotificationController.close();
    _connectionStatusController.close();

    _orderNotificationController.close();
    _socket?.dispose();
    log('[RealtimeRepository] Todos os streams e o socket foram fechados');
  }
}
