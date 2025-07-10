import 'dart:async';
import 'package:either_dart/either.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:totem_pro_admin/models/order_details.dart';

import '../cubits/store_manager_cubit.dart'; // Importe seu StoresManagerCubit
import '../cubits/store_manager_state.dart'; // Importe seu StoresManagerState (se StoreManagerCubit usa estados)

import '../models/product.dart';
import '../models/store_with_role.dart';

class RealtimeRepository {
  late Socket _socket;


  late final StoresManagerCubit _storesManagerCubit; // Usamos late final para atribuir depois

  // NOVO: Stream para pedidos iniciais (lista completa de pedidos)
  final Map<int, BehaviorSubject<List<OrderDetails>>> _ordersInitialStreams = {};
  // NOVO: Stream para atualizações de pedidos (um único pedido atualizado)
  final Map<int, BehaviorSubject<OrderDetails>> _orderUpdateStreams = {};


  final Map<int, BehaviorSubject<StoreWithRole>> _storeStreams = {};
  final Map<int, BehaviorSubject<List<Product>>> _productsStreams = {};
  final Map<int, BehaviorSubject<List<OrderDetails>>> _ordersStreams = {};


  RealtimeRepository();

  void initialize(String adminToken) {
    _socket = io(
      '${dotenv.env['API_URL']}/admin',
      OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection() // ✅ reconexão ativada
          .setReconnectionAttempts(9999) // ✅ número máximo de tentativas
          .setReconnectionDelay(1000) // ✅ tempo entre tentativas em ms
          .setQuery({'admin_token': adminToken})
          .build(),
    );

    // Debug: Log todos os eventos recebidos
    _socket.onAny((event, data) {
      print('[SOCKET] Evento recebido: $event');
      // Evite imprimir ping/pong para não poluir o log
      if (event != 'ping' && event != 'pong') {
        print('[SOCKET] Dados: $data');
      }
    });

    // ✅ O seu bloco de código atualizado para 'store_full_updated'
    _socket.on('store_full_updated', (data) {
      try {
        print('[DEBUG] store_full_updated data: $data');
        if (data == null) {
          throw Exception('Dados nulos recebidos para store_full_updated');
        }

        final Map<String, dynamic> payload = data as Map<String, dynamic>;

        final int storeId = payload['store_id'];

        // Garante que o stream existe
        if (!_storeStreams.containsKey(storeId)) {
          _storeStreams[storeId] = BehaviorSubject<StoreWithRole>();
        }



        final Map<String, dynamic> storeDetailsData = payload['store'] as Map<
            String,
            dynamic>;

        // ** AQUI ESTÁ A LÓGICA PARA OBTER O ROLE CORRETO **
        StoreAccessRole? currentRole;
        // Verificamos o estado atual do StoresManagerCubit para encontrar o role
        if (_storesManagerCubit.state is StoresManagerLoaded) {
          final loadedState = _storesManagerCubit.state as StoresManagerLoaded;
          currentRole = loadedState.stores[storeId]?.role;
        }

        // Se o role não for encontrado (o que pode acontecer se a loja ainda não foi carregada no Cubit),
        // use um role padrão ou trate o erro. É crucial que StoreWithRole sempre tenha um role.
        if (currentRole == null) {
          print(
              '[WARN] Role não encontrado no StoresManagerCubit para loja $storeId. Usando role padrão "admin".');
          currentRole = StoreAccessRole.admin; // Valor padrão de segurança
        }

        // Criamos o mapa no formato que StoreWithRole.fromJson espera
        final Map<String, dynamic> dataForStoreWithRole = {
          'store': storeDetailsData,
          // Passa o nome do enum para a key 'machine_name' que o fromJson espera
          'role': {'machine_name': currentRole.name},
        };

        // Agora, StoreWithRole.fromJson pode processar os dados corretamente
        final storeWithRole = StoreWithRole.fromJson(dataForStoreWithRole);

        _storeStreams[storeId]?.add(storeWithRole);
      } catch (e, stack) {
        print('[ERRO] store_full_updated: $e\n$stack');
      }
    });

    _socket.on('products_updated', (data) {
      try {
        print('[DEBUG] products_updated data: $data');
        final productsRaw = (data is List) ? data : [];
        final products = productsRaw
            .whereType<Map<String, dynamic>>()
            .map((e) => Product.fromJson(e))
            .toList();

        if (products.isNotEmpty) {
          final storeId = products.first.id; // Supondo que Product tem storeId
          _productsStreams[storeId]?.add(products);
        } else
        if (data is Map<String, dynamic> && data.containsKey('store_id')) {
          final storeId = data['store_id'] as int;
          _productsStreams[storeId]?.add([]);
        } else {
          print(
              '[DEBUG] products_updated: Lista vazia ou sem storeId explícito para adicionar ao stream.');
        }
      } catch (e, stack) {
        print('[ERRO] products_updated: $e\n$stack');
      }
    });

    _socket.on('orders_initial', (data) {
      try {
        print('[DEBUG] orders_initial data: $data');
        if (data is Map<String, dynamic> && data.containsKey('store_id') &&
            data.containsKey('orders')) {
          final int storeId = data['store_id'] as int;
          final List<dynamic> ordersRaw = data['orders'] as List<dynamic>;

          final orders = ordersRaw
              .whereType<Map<String, dynamic>>()
              .map((e) => OrderDetails.fromJson(e))
              .toList();

          _ordersStreams[storeId]?.add(orders);

          _ordersInitialStreams.putIfAbsent(storeId, () => BehaviorSubject<List<OrderDetails>>());
          _ordersInitialStreams[storeId]?.add(orders); // Adiciona a lista inicial
          print('[DEBUG] orders_initial data: $data');




        } else {
          print(
              '[ERRO] orders_initial: Formato de dados inesperado. Esperado Map com store_id e orders.');
        }
      } catch (e, stack) {
        print('[ERRO] orders_initial: $e\n$stack');
      }
    });

    _socket.on('order_updated', (data) {
      try {
        print('[DEBUG] order_updated data: $data');

        final orderData = _convertToOrderMap(data);
        final updatedOrder = OrderDetails.fromJson(orderData);
        final storeId = updatedOrder.storeId;

        final ordersSubject = _ordersStreams[storeId];
        if (ordersSubject != null && !ordersSubject.isClosed) {
          final currentOrders = List<OrderDetails>.from(
              ordersSubject.valueOrNull ?? []);
          final index = currentOrders.indexWhere((o) =>
          o.id == updatedOrder.id);





          if (index != -1) {
            currentOrders[index] = updatedOrder;
            print('[DEBUG] Pedido ${updatedOrder
                .id} atualizado na lista da loja $storeId.');
          } else {
            currentOrders.insert(0, updatedOrder);
            print('[DEBUG] Novo pedido ${updatedOrder
                .id} adicionado à lista da loja $storeId.');
          }
          ordersSubject.add(currentOrders);
        } else {
          print(
              '[DEBUG] order_updated: Stream de pedidos para loja $storeId não encontrado ou fechado.');
        }
      } catch (e, stack) {
        print('[ERRO] order_updated: $e\n$stack');
      }
    });

    _socket.onConnect((_) => print('[Socket] ✅ Conectado'));
    _socket.onDisconnect((_) => print('[Socket] 🔌 Desconectado'));
    _socket.onError((err) => print('[Socket] ❌ Erro: $err'));
  }

  // Método para injetar o StoresManagerCubit *depois* que ele for registrado no GetIt
  void setStoresManagerCubit(StoresManagerCubit cubit) {
    _storesManagerCubit = cubit;
    // Se RealtimeRepository precisar fazer algo imediatamente com o cubit, faça aqui
    // Por exemplo: _webSocketService.connect(cubit.activeStoreId);
  }
  Map<String, dynamic> _convertToOrderMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception('Formato de dados inválido: ${data.runtimeType}');
    }
  }

  Future<Either<void, void>> updateOrderStatus(int orderId,
      String newStatus) async {
    try {
      final result = await _socket.emitWithAckAsync('update_order_status', {
        'order_id': orderId,
        'new_status': newStatus,
      });

      if (result['error'] != null) return Left(null);
      return Right(null);
    } catch (_) {
      return Left(null);
    }
  }

  Future<Either<String, Map<String, dynamic>>> updateStoreSettings({
    bool? isDeliveryActive,
    bool? isTakeoutActive,
    bool? isTableServiceActive,
    bool? isStoreOpen,
    bool? autoAcceptOrders,
    bool? autoPrintOrders,
  }) async {
    try {
      final data = <String, dynamic>{
        if (isDeliveryActive != null) 'is_delivery_active': isDeliveryActive,
        if (isTakeoutActive != null) 'is_takeout_active': isTakeoutActive,
        if (isTableServiceActive !=
            null) 'is_table_service_active': isTableServiceActive,
        if (isStoreOpen != null) 'is_store_open': isStoreOpen,
        if (autoAcceptOrders != null) 'auto_accept_orders': autoAcceptOrders,
        if (autoPrintOrders != null) 'auto_print_orders': autoPrintOrders,
      };

      final result = await _socket.emitWithAckAsync(
          'update_store_settings', data);

      if (result['error'] != null) return Left(result['error'] as String);
      return Right(result as Map<String, dynamic>);
    } catch (_) {
      return Left('Erro ao atualizar configurações');
    }
  }


  void leaveStoreRoom(int storeId) {
    if (_storeStreams.containsKey(storeId)) {
      print('[Socket] Saindo da sala da loja: $storeId e fechando streams.');
      _socket.emit('leave_store_room', {'store_id': storeId});
      _storeStreams[storeId]?.close();
      _productsStreams[storeId]?.close();
      _ordersStreams[storeId]?.close();
      _storeStreams.remove(storeId);
      _productsStreams.remove(storeId);
      _ordersStreams.remove(storeId);
    } else {
      print('[Socket] Não estava na sala da loja: $storeId.');
    }
  }

  Stream<StoreWithRole> listenToStore(int storeId) {
    return _storeStreams[storeId]!.stream;
  }

  Stream<List<Product>> listenToProducts(int storeId) {
    return _productsStreams[storeId]!.stream;
  }

  Stream<List<OrderDetails>> listenToOrders(int storeId) {
    return _ordersStreams[storeId]!.stream;
  }


  void joinStoreRoom(int storeId) {
    // Garanta que os streams existam antes de entrar na sala
    _storeStreams.putIfAbsent(storeId, () => BehaviorSubject<StoreWithRole>());
    _productsStreams.putIfAbsent(
        storeId, () => BehaviorSubject<List<Product>>());
    _ordersStreams.putIfAbsent(
        storeId, () => BehaviorSubject<List<OrderDetails>>());

    _socket.emit('join_store_room', {'store_id': storeId});
  }

  void dispose() {
    // Limpe os maps após fechar os streams
    _storeStreams.forEach((_, stream) => stream.close());
    _productsStreams.forEach((_, stream) => stream.close());
    _ordersStreams.forEach((_, stream) => stream.close());
    _storeStreams.clear();
    _productsStreams.clear();
    _ordersStreams.clear();
    for (var c in _storeStreams.values)
      c.close();
    for (var c in _productsStreams.values)
      c.close();
    for (var c in _ordersStreams.values)
      c.close();
    _socket.disconnect();
    _socket.dispose();
    print('[Socket] RealtimeRepository disposto. Socket desconectado.');
  }


}
