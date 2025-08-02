// Em: cubits/store_manager_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

import '../models/product.dart';
import '../models/store.dart';

class StoresManagerCubit extends Cubit<StoresManagerState> {
  final StoreRepository _storeRepository;
  final RealtimeRepository _realtimeRepository;

  StreamSubscription? _adminStoresListSubscription;
  StreamSubscription? _notificationSubscription;
  // ✨ 1. ADICIONE UMA NOVA VARIÁVEL PARA A INSCRIÇÃO ✨
  StreamSubscription? _activeStoreSubscription;

  // ✅ 1. ADICIONE A INSCRIÇÃO PARA A LISTA DE PRODUTOS
  StreamSubscription? _productsSubscription;




  StoresManagerCubit({
    required StoreRepository storeRepository,
    required RealtimeRepository realtimeRepository,
  })  : _storeRepository = storeRepository,
        _realtimeRepository = realtimeRepository,
        super(const StoresManagerInitial()) {
    _startRealtimeListeners();
  }

  void _startRealtimeListeners() {
    _adminStoresListSubscription?.cancel();
    _adminStoresListSubscription =
        _realtimeRepository.onAdminStoresList.listen(_onAdminStoresListReceived);

    _notificationSubscription?.cancel();
    _notificationSubscription =
        _realtimeRepository.onStoreNotification.listen(_onNotificationsReceived);

    // ✨ 2. INSCREVA-SE NO STREAM DE ATUALIZAÇÃO DA LOJA ATIVA ✨
    _activeStoreSubscription?.cancel();
    _activeStoreSubscription =
        _realtimeRepository.onActiveStoreUpdated.listen(_onActiveStoreUpdated);
  }

// ✅ 2. CRIE O MÉTODO QUE RECEBE A ATUALIZAÇÃO DA LISTA DE PRODUTOS
  void _onProductsUpdated(List<Product> updatedProducts) {
    if (isClosed) return;

    final currentState = state;
    if (currentState is StoresManagerLoaded) {
      // Pega a loja ativa atual
      final currentActiveStore = currentState.activeStore;
      if (currentActiveStore == null) return;

      // Cria uma versão atualizada da loja, trocando apenas a lista de produtos
      final newActiveStore = currentActiveStore.copyWith(products: updatedProducts);

      // Atualiza o mapa de lojas com a versão mais recente da loja ativa
      final newStoresMap = Map<int, StoreWithRole>.from(currentState.stores);
      newStoresMap[currentState.activeStoreId] = newStoresMap[currentState.activeStoreId]!.copyWith(store: newActiveStore);

      print("✅ StoresManagerCubit: Lista de produtos da loja ${currentState.activeStoreId} foi atualizada via socket.");

      // Emite o novo estado com o mapa de lojas atualizado
      emit(currentState.copyWith(stores: newStoresMap, lastUpdate: DateTime.now()));
    }
  }



  // ✨ 3. CRIE O MÉTODO QUE RECEBE A ATUALIZAÇÃO ✨
  void _onActiveStoreUpdated(Store? updatedStore) {
    if (updatedStore == null || isClosed) return;

    final currentState = state;
    if (currentState is StoresManagerLoaded) {
      // Cria uma cópia do mapa de lojas atual
      final newStoresMap = Map<int, StoreWithRole>.from(currentState.stores);

      // Se a loja atualizada existe no nosso mapa, vamos substituí-la
      if (newStoresMap.containsKey(updatedStore.id)) {
        final oldStoreWithRole = newStoresMap[updatedStore.id]!;
        // Atualiza o objeto 'store' dentro do 'StoreWithRole', mantendo a 'role'
        newStoresMap[updatedStore.id!] = oldStoreWithRole.copyWith(store: updatedStore);

        print("✅ StoresManagerCubit: Loja ID ${updatedStore.id} foi atualizada no estado.");

        // Emite o novo estado com o mapa de lojas fresquinho
        emit(currentState.copyWith(stores: newStoresMap));
      }
    }
  }

  // ✅ 4. ADICIONE A INSCRIÇÃO INICIAL QUANDO A PRIMEIRA LISTA DE LOJAS CHEGAR
  void _onAdminStoresListReceived(List<StoreWithRole> stores) {


    if (isClosed) return;

    if (stores.isEmpty) {
      emit(const StoresManagerEmpty());
      return;
    }

    final currentState = state;
    if (currentState is StoresManagerLoaded) {
      emit(currentState.copyWith(
        stores: {for (var s in stores) s.store.id!: s},
      ));
    } else {
      final firstStoreId = stores.first.store.id!;
      emit(StoresManagerLoaded(
        stores: {for (var s in stores) s.store.id!: s},
        activeStoreId: firstStoreId,
        consolidatedStores: const [],
        notificationCounts: const {},
        lastUpdate: DateTime.now(),
      ));
      _realtimeRepository.joinStoreRoom(firstStoreId);
      // Inicia a primeira inscrição na lista de produtos aqui
      _productsSubscription = _realtimeRepository.listenToProducts(firstStoreId).listen(_onProductsUpdated);
    }
  }




// ✅ VERSÃO CORRIGIDA
  void _onNotificationsReceived(Map<int, int> incomingNotificationCounts) {
    if (isClosed) return;
    final currentState = state;

    if (currentState is StoresManagerLoaded) {
      // Cria uma cópia do mapa de notificações que acabamos de receber
      final filteredCounts = Map<int, int>.from(incomingNotificationCounts);

      // ✨ ESTA É A LÓGICA CRÍTICA ✨
      // Remove a contagem da loja que está ativa na tela.
      // Assim, o toast só mostrará a soma das notificações de lojas INATIVAS.
      filteredCounts.remove(currentState.activeStoreId);

      // Emite o novo estado com o mapa de notificações já filtrado
      emit(currentState.copyWith(
        notificationCounts: filteredCounts,
      ));
    }
  }



// ✅ 3. MODIFIQUE `changeActiveStore` PARA GERENCIAR A INSCRIÇÃO
  Future<void> changeActiveStore(int newStoreId) async {
    if (isClosed) return;
    final currentState = state;

    if (currentState is StoresManagerLoaded) {
      if (currentState.activeStoreId == newStoreId) return;

      final previousStoreId = currentState.activeStoreId;

      // Cancela a inscrição da lista de produtos da loja anterior
      await _productsSubscription?.cancel();

      await _realtimeRepository.leaveStoreRoom(previousStoreId);
      await _realtimeRepository.joinStoreRoom(newStoreId);

      // Inscreve-se na lista de produtos da NOVA loja ativa
      _productsSubscription = _realtimeRepository.listenToProducts(newStoreId).listen(_onProductsUpdated);

      _realtimeRepository.clearNotificationsForStore(newStoreId);

      final newNotificationCounts = Map<int, int>.from(currentState.notificationCounts);
      newNotificationCounts.remove(newStoreId);

      emit(currentState.copyWith(
        activeStoreId: newStoreId,
        notificationCounts: newNotificationCounts,
      ));
    }
  }


  Future<void> updateStoreSettings(
      int storeId, {
        bool? isDeliveryActive,
        bool? isTakeoutActive,
        bool? isTableServiceActive,
        bool? isStoreOpen,
        bool? autoAcceptOrders,
        bool? autoPrintOrders,
        // ✅ NOVOS CAMPOS
        String? mainPrinterDestination,
        String? kitchenPrinterDestination,
        String? barPrinterDestination,
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
        // ✅ NOVOS CAMPOS
        mainPrinterDestination: mainPrinterDestination,
        kitchenPrinterDestination: kitchenPrinterDestination,
        barPrinterDestination: barPrinterDestination,
      );

      result.fold(
            (error) {
          print('[StoresManagerCubit] Erro ao atualizar configurações da loja $storeId: $error');
        },
            (success) {
          print('[StoresManagerCubit] Configurações da loja $storeId atualizadas com sucesso.');
        },
      );
    } catch (e) {
      print('[StoresManagerCubit] Erro inesperado ao atualizar configurações: $e');
    }
  }


  /// Força o recarregamento dos dados da loja ativa a partir do backend.
  /// Essencial para manter a UI sincronizada após uma edição.
  Future<void> reloadActiveStore() async {
    if (state is! StoresManagerLoaded) return;

    final loadedState = state as StoresManagerLoaded;
    final activeStoreId = loadedState.activeStoreId;

    try {
      // ✅ CORREÇÃO: Chama o método 'getStore' que existe no repositório.
      final storeResult = await _storeRepository.getStore(activeStoreId);

      storeResult.fold(
        // Caso de falha
            (failure) {
          print("❌ StoresManagerCubit: Falha ao recarregar a loja ID $activeStoreId via getStore.");
        },
        // Caso de sucesso
            (updatedStore) {
          // Pega o 'role' do estado atual para manter a consistência.
          final currentRole = loadedState.stores[activeStoreId]?.role;
          if (currentRole == null) {
            print("❌ StoresManagerCubit: Não foi possível encontrar o 'role' para a loja ID $activeStoreId no estado atual.");
            return;
          }

          // Cria um novo 'StoreWithRole' com os dados atualizados da loja e o 'role' existente.
          final updatedStoreWithRole = StoreWithRole(store: updatedStore, role: currentRole);

          // Cria uma cópia do mapa de lojas e atualiza a loja modificada.
          final newStoresMap = Map<int, StoreWithRole>.from(loadedState.stores);
          newStoresMap[activeStoreId] = updatedStoreWithRole;

          // Emite o novo estado com os dados atualizados.
          emit(loadedState.copyWith(
            stores: newStoresMap,
            lastUpdate: DateTime.now(), // Importante para forçar a atualização
          ));
          print("✅ StoresManagerCubit: Loja ID $activeStoreId recarregada com sucesso.");
        },
      );
    } catch (e) {
      print("❌ StoresManagerCubit: Erro ao recarregar a loja ID $activeStoreId: $e");
    }
  }
  String? getStoreNameById(int storeId) {
    final currentState = state;
    if (currentState is StoresManagerLoaded) {
      return currentState.stores[storeId]?.store.name;
    }
    return null;
  }

  @override
  Future<void> close() {
    _adminStoresListSubscription?.cancel();
    _notificationSubscription?.cancel();
    _activeStoreSubscription?.cancel();
    _productsSubscription?.cancel(); // Limpa a nova inscrição
    return super.close();
  }
}
