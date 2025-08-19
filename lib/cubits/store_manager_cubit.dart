// Em: cubits/store_manager_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

import '../models/product.dart';
import '../models/store.dart';
import 'auth_cubit.dart';

class StoresManagerCubit extends Cubit<StoresManagerState> {
  final StoreRepository _storeRepository;
  final RealtimeRepository _realtimeRepository;
  final AuthCubit _authCubit;

  StreamSubscription? _authSubscription;
  StreamSubscription? _adminStoresListSubscription;
  StreamSubscription? _notificationSubscription;
  // ✨ 1. ADICIONE UMA NOVA VARIÁVEL PARA A INSCRIÇÃO ✨
  StreamSubscription? _activeStoreSubscription;

  // ✅ 1. ADICIONE A INSCRIÇÃO PARA A LISTA DE PRODUTOS
  StreamSubscription? _productsSubscription;




  StoresManagerCubit({
    required StoreRepository storeRepository,
    required RealtimeRepository realtimeRepository,
    required AuthCubit authCubit,
  })  : _storeRepository = storeRepository,
        _realtimeRepository = realtimeRepository,
        _authCubit = authCubit,
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

      // Exemplo: atualizando a lista de produtos dentro do seu Cubit/Controller
      final newActiveStore = currentActiveStore.copyWith(
        relations: currentActiveStore.relations.copyWith( // <- Usando o copyWith de StoreRelations
          products: updatedProducts,
        ),
      );
      // Atualiza o mapa de lojas com a versão mais recente da loja ativa
      final newStoresMap = Map<int, StoreWithRole>.from(currentState.stores);
      newStoresMap[currentState.activeStoreId] = newStoresMap[currentState.activeStoreId]!.copyWith(store: newActiveStore);

      print("✅ StoresManagerCubit: Lista de produtos da loja ${currentState.activeStoreId} foi atualizada via socket.");

      // Emite o novo estado com o mapa de lojas atualizado
      emit(currentState.copyWith(stores: newStoresMap, lastUpdate: DateTime.now()));
    }
  }



// Em lib/cubits/stores_manager_cubit.dart
  void _onActiveStoreUpdated(Store? updatedStore) {
    if (updatedStore == null || isClosed) return;

    // Não pegamos o estado aqui. Esperamos até o momento de emitir.

    // Verificamos o estado atual logo antes de fazer qualquer coisa
    if (state is StoresManagerLoaded) {
      // Para evitar erros de tipo, criamos uma variável local do tipo correto
      final currentState = state as StoresManagerLoaded;

      final newStoresMap = Map<int, StoreWithRole>.from(currentState.stores);

      if (newStoresMap.containsKey(updatedStore.core.id)) {
        final oldStoreWithRole = newStoresMap[updatedStore.core.id]!;
        newStoresMap[updatedStore.core.id!] = oldStoreWithRole.copyWith(store: updatedStore);

        print("✅ [CUBIT] Loja ID ${updatedStore.core.id} foi atualizada no estado do Cubit.");

        // ✅ A MUDANÇA CRÍTICA ESTÁ AQUI
        // Usamos `currentState.copyWith`, que agora sabemos que é
        // a versão mais recente do estado no momento da emissão.
        emit(currentState.copyWith(
          stores: newStoresMap,
          lastUpdate: DateTime.now(),
        ));
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
        stores: {for (var s in stores) s.store.core.id!: s},
      ));
    } else {
      final firstStoreId = stores.first.store.core.id!;
      emit(StoresManagerLoaded(
        stores: {for (var s in stores) s.store.core.id!: s},
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


  // /// Força o recarregamento dos dados da loja ativa a partir do backend.
  // /// Essencial para manter a UI sincronizada após uma edição.
  // Future<void> reloadActiveStore() async {
  //   if (state is! StoresManagerLoaded) return;
  //
  //   final loadedState = state as StoresManagerLoaded;
  //   final activeStoreId = loadedState.activeStoreId;
  //
  //   try {
  //     // ✅ CORREÇÃO: Chama o método 'getStore' que existe no repositório.
  //     final storeResult = await _storeRepository.getStore(activeStoreId);
  //
  //     storeResult.fold(
  //       // Caso de falha
  //           (failure) {
  //         print("❌ StoresManagerCubit: Falha ao recarregar a loja ID $activeStoreId via getStore.");
  //       },
  //       // Caso de sucesso
  //           (updatedStore) {
  //         // Pega o 'role' do estado atual para manter a consistência.
  //         final currentRole = loadedState.stores[activeStoreId]?.role;
  //         if (currentRole == null) {
  //           print("❌ StoresManagerCubit: Não foi possível encontrar o 'role' para a loja ID $activeStoreId no estado atual.");
  //           return;
  //         }
  //
  //         // Cria um novo 'StoreWithRole' com os dados atualizados da loja e o 'role' existente.
  //         final updatedStoreWithRole = StoreWithRole(store: updatedStore, role: currentRole);
  //
  //         // Cria uma cópia do mapa de lojas e atualiza a loja modificada.
  //         final newStoresMap = Map<int, StoreWithRole>.from(loadedState.stores);
  //         newStoresMap[activeStoreId] = updatedStoreWithRole;
  //
  //         // Emite o novo estado com os dados atualizados.
  //         emit(loadedState.copyWith(
  //           stores: newStoresMap,
  //           lastUpdate: DateTime.now(), // Importante para forçar a atualização
  //         ));
  //         print("✅ StoresManagerCubit: Loja ID $activeStoreId recarregada com sucesso.");
  //       },
  //     );
  //   } catch (e) {
  //     print("❌ StoresManagerCubit: Erro ao recarregar a loja ID $activeStoreId: $e");
  //   }
  // }
  //

  // ✅ 1. MÉTODO PARA ADICIONAR UMA NOVA PAUSA
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
    final result = await _storeRepository.deleteScheduledPause(pauseId: pauseId);

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



// Em lib/cubits/stores_manager_cubit.dart

  Future<void> fetchHolidays() async {
    // Use 'state' directly for the most current state information
    if (state is! StoresManagerLoaded) return;
    if ((state as StoresManagerLoaded).holidays != null && (state as StoresManagerLoaded).holidays!.isNotEmpty) {
      return; // If holidays are already loaded, do nothing.
    }

    // To avoid showing a full-screen loader, you can emit a state
    // that indicates holidays are being fetched, if you want. For now, we'll just fetch.

    final result = await _storeRepository.getHolidays(DateTime.now().year);

    result.fold(
          (error) => print("Cubit Error fetching holidays: $error"),
          (holidays) {
        // ✅ THE FIX IS HERE:
        // We check the type of the CURRENT `state` again before emitting.
        // This ensures we are adding the holidays to the most up-to-date
        // version of the store's data.
        if (state is StoresManagerLoaded) {
          emit((state as StoresManagerLoaded).copyWith(holidays: holidays));
        }
      },
    );
  }


  String? getStoreNameById(int storeId) {
    final currentState = state;
    if (currentState is StoresManagerLoaded) {
      return currentState.stores[storeId]?.store.core.name;
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
