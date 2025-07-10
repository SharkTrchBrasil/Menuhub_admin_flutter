// lib/pages/orders/order_page_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';

import 'package:totem_pro_admin/cubits/store_manager_cubit.dart'; // Importe o StoresManagerCubit
import 'package:totem_pro_admin/cubits/store_manager_state.dart'; // Importe o estado do StoresManagerCubit

import 'order_page_state.dart'; // Seu arquivo de estado

class OrderCubit extends Cubit<OrderState> {
  final RealtimeRepository _realtimeRepository;
  final StoresManagerCubit _storesManagerCubit; // <--- ADICIONE ESTA LINHA

  StreamSubscription<List<OrderDetails>>? _ordersSubscription; // Renomeado para clareza
  StreamSubscription? _storeManagerSubscription; // <--- ADICIONE ESTA LINHA para ouvir o StoresManagerCubit

  int? _currentStoreId; // Para rastrear qual loja está sendo ouvida

  // Modifique o construtor para receber o StoresManagerCubit
  OrderCubit({
    required RealtimeRepository realtimeRepository,
    required StoresManagerCubit storesManagerCubit, // <--- ADICIONE ESTE PARÂMETRO
  })  : _realtimeRepository = realtimeRepository,
        _storesManagerCubit = storesManagerCubit, // <--- ATRIBUA
        super(const OrderState()) {
    _initialize(); // <--- CHAME UM MÉTODO DE INICIALIZAÇÃO
  }

  void _initialize() {
    // 1. Inicie a escuta ao StoresManagerCubit
    _storeManagerSubscription = _storesManagerCubit.stream.listen((state) {

      print('[OrderCubit] Estado do StoresManagerCubit mudou: $state');

      if (state is StoresManagerLoaded) {

        print('[OrderCubit] StoresManagerLoaded - activeStoreId: ${state.activeStoreId}, currentStoreId: $_currentStoreId');
        if (state.activeStoreId != _currentStoreId && state.activeStoreId != null) {
          print('[OrderCubit] Loja ativa diferente! Mudando para: ${state.activeStoreId}');
          _currentStoreId = state.activeStoreId;
          startListeningToStore(_currentStoreId!); // Chame seu método existente
        } else if (state.activeStoreId == null) {
          print('[OrderCubit] Nenhuma loja ativa. Limpando pedidos.');
          _ordersSubscription?.cancel();
          _currentStoreId = null;
          emit(this.state.copyWith(orders: [], status: OrderStatus.success)); // Ou OrderStatus.empty
        }
      } else if (state is StoresManagerEmpty) {
        print('[OrderCubit] StoresManagerEmpty. Limpando tudo.');
        _ordersSubscription?.cancel();
        _currentStoreId = null;
        emit(this.state.copyWith(orders: [], status: OrderStatus.success)); // Ou OrderStatus.empty
      }
      // Outros estados do StoresManagerCubit (Loading, Error) podem ser tratados aqui se necessário
    });

    // 2. Dispare a carga inicial com a loja ativa atual (se já houver uma no estado inicial do StoresManagerCubit)
    final initialStoreState = _storesManagerCubit.state;
    if (initialStoreState is StoresManagerLoaded && initialStoreState.activeStoreId != null) {
      _currentStoreId = initialStoreState.activeStoreId;
      startListeningToStore(_currentStoreId!);
    }











  }


  /// Escuta os pedidos de uma loja específica (seu método existente)
  void startListeningToStore(int storeId) {
    if (_ordersSubscription != null) {
      _ordersSubscription!.cancel(); // Cancela a assinatura anterior se existir
    }
    _currentStoreId = storeId; // Garante que _currentStoreId está atualizado

    emit(state.copyWith(status: OrderStatus.loading));

    _ordersSubscription =
        _realtimeRepository.listenToOrders(storeId).listen((orders) {
          emit(state.copyWith(orders: orders, status: OrderStatus.success));
        }, onError: (error) {
          emit(state.copyWith(status: OrderStatus.failure, error: error.toString()));
        });
  }

  /// Atualiza status do pedido
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    // É importante ter um storeId ativo para esta operação
    if (_currentStoreId == null) {
      emit(state.copyWith(status: OrderStatus.failure, error: 'Nenhuma loja selecionada para atualizar pedido.'));
      return;
    }
    try {
      await _realtimeRepository.updateOrderStatus(orderId, newStatus);
      // O socket deve notificar a atualização e o stream irá atualizar os pedidos automaticamente.
      // Então, geralmente, não é necessário emitir um novo estado aqui, a menos que haja um delay
      // e você queira uma atualização otimista na UI.
    } catch (e) {
      emit(state.copyWith(status: OrderStatus.failure, error: e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _ordersSubscription?.cancel(); // Cancele a assinatura de pedidos
    await _storeManagerSubscription?.cancel(); // Cancele a assinatura do StoresManagerCubit
    return super.close();
  }
}