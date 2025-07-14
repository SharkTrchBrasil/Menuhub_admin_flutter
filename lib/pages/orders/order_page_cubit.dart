// lib/pages/orders/order_page_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart'; // Para groupFoldBy
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';

import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

import '../../models/store_with_role.dart';

import 'order_page_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final RealtimeRepository _realtimeRepository;
  final StoresManagerCubit _storesManagerCubit;
  StreamSubscription? _storesManagerSubscription;

  // Mapa de assinaturas de streams de pedidos, por storeId
  final Map<int, StreamSubscription> _orderStreamsSubscriptions = {};
  // Cache dos pedidos, agrupados por storeId.
  // IMPORTANTE: Cada lista aqui representa o último estado do stream daquela loja.
  final Map<int, List<OrderDetails>> _ordersCacheByStore = {};

  // Estado interno para o filtro de pedidos, se você tiver um seletor na UI
  OrderFilter _currentFilter = OrderFilter.all;

  OrderCubit({
    required RealtimeRepository realtimeRepository,
    required StoresManagerCubit storesManagerCubit,
  })  : _realtimeRepository = realtimeRepository,
        _storesManagerCubit = storesManagerCubit,
        super(const OrdersInitial()) {
    _subscribeToStoresManagerCubit();
  }

  void _subscribeToStoresManagerCubit() {
    // Escuta mudanças no estado do StoresManagerCubit para reagir a:
    // 1. Lojas serem carregadas pela primeira vez.
    // 2. A lista de lojas (ou seus status de consolidação) ser atualizada.
    // 3. A loja ativa mudar.
    _storesManagerSubscription = _storesManagerCubit.stream.listen((state) {
      if (state is StoresManagerLoaded) {
        print('[OrderCubit] StoresManagerLoaded recebido. Loja ativa: ${state.activeStoreId}');
        // Se este é o primeiro carregamento ou uma mudança significativa
        // que pode afetar os pedidos consolidados (e.g., mudança de lojas consolidadas)
        // emitimos OrdersLoading.
        // Evitamos emitir Loading se a lista de consolidatedStoreIds não mudou
        // para evitar flickering desnecessário na UI.

        // Obtém a lista ATUAL de IDs de lojas consolidadas do StoresManagerCubit
        final List<int> newConsolidatedStoreIds = _storesManagerCubit.currentConsolidatedStoreIds;
        final int? newActiveStoreId = state.activeStoreId;

        // Gera a lista de lojas que DEVERIAM estar com subscriptions ativas
        final Set<int> desiredSubscriptions = newConsolidatedStoreIds.toSet();
        if (newActiveStoreId != null) {
          // Se a loja ativa NÃO está consolidada, mas queremos exibir seus pedidos,
          // adicione-a também à lista de desiredSubscriptions.
          // Ajuste esta lógica conforme a regra de negócio:
          // A) Pedidos consolidados (sempre exibidos)
          // B) Pedidos da loja ativa (se não estiver consolidada, mas quiser exibir)
          if (!desiredSubscriptions.contains(newActiveStoreId)) {
            // Opcional: Se a loja ativa DEVE ser sempre mostrada, mesmo que não consolidada
            desiredSubscriptions.add(newActiveStoreId);
            print('[OrderCubit] Loja ativa $newActiveStoreId adicionada à lista de assinaturas desejadas.');
          }
        }

        // Verifica se a lista de assinaturas desejadas mudou desde a última vez
        final Set<int> currentActiveSubscriptions = _orderStreamsSubscriptions.keys.toSet();

        if (!currentActiveSubscriptions.containsAll(desiredSubscriptions) ||
            !desiredSubscriptions.containsAll(currentActiveSubscriptions)) {
          // Se as listas de lojas a serem monitoradas mudaram, emitimos loading.
          emit(const OrdersLoading());
          _updateOrderStreams(desiredSubscriptions.toList());
        } else {
          // Se a lista de lojas monitoradas não mudou (mas os dados podem ter mudado dentro da mesma lista),
          // apenas garante que o estado é emitido novamente com os dados mais recentes.
          // Isso é importante porque StoresManagerLoaded é emitido mesmo se apenas uma StoreWithRole interna mudou.
          _emitConsolidatedOrders();
        }

      } else if (state is StoresManagerError) {
        // Se o StoresManagerCubit reporta um erro, isso afeta o OrderCubit.
        emit(OrdersError('Erro no gerenciamento de lojas: ${state.message}'));
      } else if (state is StoresManagerEmpty) {
        // Se não há lojas para o admin gerenciar, não há pedidos.
        _orderStreamsSubscriptions.values.forEach((sub) => sub.cancel());
        _orderStreamsSubscriptions.clear();
        _ordersCacheByStore.clear();
        emit(const OrdersEmpty(message: 'Nenhuma loja disponível para carregar pedidos.'));
      }
    });

    // Pós-construção: Carrega o estado inicial do StoresManagerCubit.
    // Se o StoresManagerCubit já tiver um estado carregado na inicialização do OrderCubit,
    // garantimos que o OrdersLoading seja emitido e as assinaturas sejam atualizadas.
    if (_storesManagerCubit.state is StoresManagerLoaded) {
      final loadedState = _storesManagerCubit.state as StoresManagerLoaded;
      final List<int> initialConsolidatedStoreIds = _storesManagerCubit.currentConsolidatedStoreIds;
      final int? initialActiveStoreId = loadedState.activeStoreId;

      final Set<int> initialDesiredSubscriptions = initialConsolidatedStoreIds.toSet();
      if (initialActiveStoreId != null) {
        initialDesiredSubscriptions.add(initialActiveStoreId);
      }

      emit(const OrdersLoading());
      _updateOrderStreams(initialDesiredSubscriptions.toList());
    } else if (_storesManagerCubit.state is StoresManagerEmpty) {
      emit(const OrdersEmpty(message: 'Nenhuma loja disponível no início.'));
    }
  }


  void _updateOrderStreams(List<int> desiredStoreIds) {
    print('[OrderCubit] Atualizando assinaturas de pedidos. Desejadas: $desiredStoreIds');

    // Cancelar assinaturas que NÃO estão mais na lista de desejadas
    _orderStreamsSubscriptions.keys.toList().forEach((storeId) {
      if (!desiredStoreIds.contains(storeId)) {
        _orderStreamsSubscriptions[storeId]?.cancel();
        _orderStreamsSubscriptions.remove(storeId);
        _ordersCacheByStore.remove(storeId); // Limpa o cache da loja removida
        print('[OrderCubit] Cancelou assinatura e removeu cache da loja $storeId.');
      }
    });

    // Se a lista de desejadas estiver vazia, significa que não há pedidos para mostrar
    if (desiredStoreIds.isEmpty) {
      _ordersCacheByStore.clear(); // Garante que o cache esteja limpo
      emit(const OrdersEmpty()); // Emitir estado de vazio
      return;
    }

    // Inscrever-se em novas lojas desejadas
    bool anyNewSubscription = false;
    for (final storeId in desiredStoreIds) {
      if (!_orderStreamsSubscriptions.containsKey(storeId)) {
        print('[OrderCubit] Assinando stream de pedidos da loja $storeId.');
        anyNewSubscription = true;

        // ** Importante: No RealtimeRepository, listenToOrders(storeId) deve
        //    primeiro garantir que estamos na sala/canal de pedidos daquela loja
        //    antes de tentar ouvir os eventos. **
        //    Seu RealtimeRepository.listenToOrders já deve fazer isso internamente,
        //    chamando joinStoreRoom para a sala de pedidos, se necessário.
        final subscription = _realtimeRepository.listenToOrders(storeId).listen(
              (orders) {
            print('[OrderCubit] Recebidos ${orders.length} pedidos para storeId $storeId.');
            _ordersCacheByStore[storeId] = orders; // Atualiza o cache para esta loja
            _emitConsolidatedOrders(); // Emite os pedidos consolidados
          },
          onError: (error) {
            print('[OrderCubit] Erro no stream de pedidos da loja $storeId: $error');
            // Remove a assinatura problemática, pode tentar reconectar ou apenas deixar de fora.
            _orderStreamsSubscriptions[storeId]?.cancel();
            _orderStreamsSubscriptions.remove(storeId);
            _ordersCacheByStore.remove(storeId);
            // Emite um erro geral, mas mantém outros pedidos se houver
            emit(OrdersError('Erro ao carregar pedidos da loja $storeId: $error'));
            _emitConsolidatedOrders(); // Tenta emitir o que resta
          },
          onDone: () {
            print('[OrderCubit] Stream de pedidos da loja $storeId concluído (onDone).');
            _orderStreamsSubscriptions.remove(storeId);
            _ordersCacheByStore.remove(storeId);
            _emitConsolidatedOrders(); // Atualiza a lista de pedidos após a desconexão
          },
        );
        _orderStreamsSubscriptions[storeId] = subscription;
      }
    }

    // Se não houver novas assinaturas, mas já temos dados em cache,
    // apenas emite os pedidos consolidados para garantir que a UI esteja atualizada.
    // Isso cobre casos onde o StoresManagerCubit emite por uma pequena mudança
    // que não altera as assinaturas ativas.
    if (!anyNewSubscription && _ordersCacheByStore.isNotEmpty) {
      _emitConsolidatedOrders();
    }
  }


  // Método auxiliar para consolidar e emitir os pedidos
  void _emitConsolidatedOrders() {
    List<OrderDetails> allConsolidatedOrders = [];

    _ordersCacheByStore.values.forEach((orders) {
      allConsolidatedOrders.addAll(orders);
    });

    // Garante unicidade dos pedidos pelo ID e pega a versão mais recente
    final List<OrderDetails> uniqueOrders = allConsolidatedOrders.groupFoldBy<int, OrderDetails>(
          (order) => order.id,
          (OrderDetails? previous, OrderDetails order) =>
      previous == null || order.updatedAt.isAfter(previous.updatedAt) ? order : previous,
    ).values.toList();

    // Ordena os pedidos (por data de criação, mais recentes primeiro)
    uniqueOrders.sort((OrderDetails a, OrderDetails b) => b.createdAt.compareTo(a.createdAt));

    if (uniqueOrders.isEmpty) {
      emit(const OrdersEmpty());
    } else {
      // Emite o estado carregado com os pedidos consolidados e o filtro atual
      emit(OrdersLoaded(orders: uniqueOrders, selectedFilter: _currentFilter));
    }
    print('[OrderCubit] Total de ${uniqueOrders.length} pedidos consolidados emitidos.');
  }

  // Método para aplicar filtros na UI
  void applyFilter(OrderFilter filter) {
    if (_currentFilter == filter) return; // Nenhuma mudança no filtro
    _currentFilter = filter;
    // Se já estiver em um estado Loaded, reemita com o filtro aplicado
    if (state is OrdersLoaded) {
      final currentLoadedState = state as OrdersLoaded;
      emit(OrdersLoaded(
        orders: currentLoadedState.orders, // Reutiliza os pedidos brutos
        selectedFilter: _currentFilter, // Aplica o novo filtro
      ));
    } else {
      // Se não estiver Loaded, apenas atualiza o filtro e espera que os dados cheguem
      // ou que um _emitConsolidatedOrders futuro reemita o estado.
      _emitConsolidatedOrders(); // Força a reemissão com o novo filtro
    }
  }


  // Métodos de Ação (e.g., aceitar, rejeitar, etc.)
  Future<void> updateOrderStatus(int orderId, String newStatus) async {
    // Para saber de qual loja é o pedido, você pode buscar no cache
    // Ou, idealmente, a API de atualização de status do pedido já sabe disso pelo orderId
    final currentOrder = _ordersCacheByStore.values
        .expand((list) => list)
        .firstWhereOrNull((order) => order.id == orderId);

    if (currentOrder == null) {
      emit(OrdersError('Pedido com ID $orderId não encontrado no cache para atualização.'));
      return;
    }

    try {
      // Esta chamada ao RealtimeRepository deve enviar a atualização para o backend
      // O backend então, por sua vez, deve emitir uma atualização via socket
      // que será capturada pelo listenToOrders e atualizará o cache e o estado.
      await _realtimeRepository.updateOrderStatus(orderId, newStatus);
      print('[OrderCubit] Solicitação de atualização de status para pedido $orderId ($newStatus) enviada.');
      // Não emitimos novo estado aqui, esperamos a notificação do socket.
    } catch (e) {
      print('[OrderCubit] Erro ao enviar atualização de status para pedido $orderId: $e');
      emit(OrdersError('Erro ao atualizar status do pedido: ${e.toString()}'));
    }
  }

  // Exemplo de aceitar pedido
  Future<void> acceptOrder(int orderId) async {
    await updateOrderStatus(orderId, 'accepted');
  }

  // Exemplo de rejeitar pedido
  Future<void> rejectOrder(int orderId) async {
    await updateOrderStatus(orderId, 'rejected');
  }


  @override
  Future<void> close() async {
    _storesManagerSubscription?.cancel();
    // Cancela todas as assinaturas de stream de pedidos
    _orderStreamsSubscriptions.values.forEach((sub) => sub.cancel());
    _orderStreamsSubscriptions.clear();
    _ordersCacheByStore.clear(); // Limpa o cache ao fechar
    print('[OrderCubit] OrderCubit fechado. Todos os subscriptions e caches limpos.');
    return super.close();
  }
}