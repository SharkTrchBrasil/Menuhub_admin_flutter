// Em: cubits/store_manager_cubit.dart

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

import '../models/store.dart';

class StoresManagerCubit extends Cubit<StoresManagerState> {
  final StoreRepository _storeRepository;
  final RealtimeRepository _realtimeRepository;

  StreamSubscription? _adminStoresListSubscription;
  StreamSubscription? _notificationSubscription;
  // ✨ 1. ADICIONE UMA NOVA VARIÁVEL PARA A INSCRIÇÃO ✨
  StreamSubscription? _activeStoreSubscription;

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

  void _onAdminStoresListReceived(List<StoreWithRole> stores) {
    if (isClosed) return;

    if (stores.isEmpty) {
      emit(const StoresManagerEmpty());
      return;
    }

    final currentState = state;
    if (currentState is StoresManagerLoaded) {
      // Aqui usamos .copyWith() porque o estado já existe
      emit(currentState.copyWith(
        stores: {for (var s in stores) s.store.id!: s},
      ));
    } else {
      // Aqui criamos o estado do zero, fornecendo todos os valores iniciais
      emit(StoresManagerLoaded(
        stores: {for (var s in stores) s.store.id!: s},
        activeStoreId: stores.first.store.id!,
        consolidatedStores: const [], // Valor inicial: lista vazia
        notificationCounts: const {}, // Valor inicial: mapa vazio
        lastUpdate: DateTime.now(),   // ⬅️ CORREÇÃO: Use DateTime.now()
      ));
      _realtimeRepository.joinStoreRoom(stores.first.store.id!);
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



  Future<void> changeActiveStore(int newStoreId) async {
    if (isClosed) return;
    final currentState = state;

    if (currentState is StoresManagerLoaded) {
      if (currentState.activeStoreId == newStoreId) return;

      final previousStoreId = currentState.activeStoreId;

      // Passos 1 e 2: Troca de sala no socket
      await _realtimeRepository.leaveStoreRoom(previousStoreId);
      await _realtimeRepository.joinStoreRoom(newStoreId);

      // Passo 3: Manda o comando para limpar o repositório.
      // A resposta disso virá pelo stream, mas não vamos mais depender dela aqui.
      _realtimeRepository.clearNotificationsForStore(newStoreId);

      // ✨ CORREÇÃO CRÍTICA ESTÁ AQUI ✨
      // Nós mesmos vamos limpar a contagem de notificações do estado ATUAL
      // antes de emiti-lo, garantindo que a atualização seja instantânea.
      final newNotificationCounts = Map<int, int>.from(currentState.notificationCounts);
      newNotificationCounts.remove(newStoreId);

      // Passo 4: Emite o novo estado com a loja ativa ATUALIZADA e
      // as notificações já LIMPAS na mesma emissão.
      emit(currentState.copyWith(
        activeStoreId: newStoreId,
        notificationCounts: newNotificationCounts, // Passamos o mapa já limpo
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
    return super.close();
  }
}
