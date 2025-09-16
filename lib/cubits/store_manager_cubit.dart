// Em: cubits/store_manager_cubit.dart

import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

import '../core/enums/connectivity_status.dart';
import '../models/category.dart';
import '../models/customer_analytics_data.dart';
import '../models/dashboard_data.dart';
import '../models/dashboard_insight.dart';
import '../models/full_menu_data.dart';
import '../models/payment_method.dart';
import '../models/peak_hours.dart';
import '../models/product.dart';
import '../models/product_analytics_data.dart';
import '../models/store.dart';
import '../models/store_relations.dart';
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
  StreamSubscription? _connectivitySubscription; // ✅ Nova inscrição
  StreamSubscription? _fullMenuSubscription;


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

  void loadInitialData() {
    log('[StoresManagerCubit] Carregamento inicial de dados iniciado.');
    // Apenas inicia os listeners se eles ainda não estiverem ativos.
    if (_adminStoresListSubscription == null) {
      _startRealtimeListeners();
    }
  }

// ✨ PASSO 1: Deixe apenas UM método helper para atualização de estado.
  //    Vamos chamá-lo de _updateActiveStore para ficar bem claro.
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
    // Listeners que NÃO dependem de uma loja ativa
    _adminStoresListSubscription = _realtimeRepository.onAdminStoresList.listen(
      _onAdminStoresListReceived,
    );
    _notificationSubscription = _realtimeRepository.onStoreNotification.listen(
      _onNotificationsReceived,
    );
    // ... suas outras inscrições
    _connectivitySubscription = _realtimeRepository.onConnectivityChanged
        .listen(_onConnectivityChanged);

    // ✅ CORREÇÃO PRINCIPAL: Todos os listeners que dependem da loja ativa
    // agora são controlados por este único stream.
    _listenToActiveStoreData();
  }

  // ✅ Novo método para lidar com a mudança de status
  void _onConnectivityChanged(ConnectivityStatus status) {
    if (state is StoresManagerLoaded) {
      final currentState = state as StoresManagerLoaded;
      // Apenas atualiza o status, sem apagar os outros dados
      emit(currentState.copyWith(connectivityStatus: status));
    }
  }

  /// Este método agora centraliza a lógica de ouvir os dados da loja ativa.
  void _listenToActiveStoreData() {
    // Cancela todas as inscrições antigas
    _storeDetailsSubscription?.cancel();
    _dashboardDataSubscription?.cancel();
    _financialsSubscription?.cancel();
    _fullMenuSubscription?.cancel();
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



    // ✅ CORREÇÃO: UMA ÚNICA INSCRIÇÃO PARA O MENU INTEIRO
    _fullMenuSubscription = activeStoreIdStream
        .switchMap((storeId) {
      log("🔄 [CUBIT] Trocando inscrição do MENU COMPLETO para a loja ID: $storeId");
      return _realtimeRepository.listenToFullMenu(storeId);
    })
        .listen(_onFullMenuUpdated);



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







  void _onStoreDetailsUpdated(Store? updatedStoreDetails) {
    if (updatedStoreDetails == null) return;
    _updateActiveStore((_, activeStore) {
      final preservedRelations = activeStore.store.relations;
      final newStore = updatedStoreDetails.copyWith(
        relations: updatedStoreDetails.relations.copyWith(
          // Preserva as relações que não vêm neste evento
          dashboardData: preservedRelations.dashboardData,
          productAnalytics: preservedRelations.productAnalytics,
          customerAnalytics: preservedRelations.customerAnalytics,
          insights: preservedRelations.insights,
          peakHours: preservedRelations.peakHours,
          products: preservedRelations.products,
          categories: preservedRelations.categories,
          variants: preservedRelations.variants,
          payables: preservedRelations.payables,
          suppliers: preservedRelations.suppliers,
          payableCategories: preservedRelations.payableCategories,
          receivables: preservedRelations.receivables,
          receivableCategories: preservedRelations.receivableCategories,
        ),
      );
      return activeStore.copyWith(store: newStore);
    });
    log("✅ [CUBIT] Detalhes da loja atualizados via socket.");
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

    if (currentState is StoresManagerInitial && stores.isEmpty) {
      log(
        "🔵 [CUBIT] Ignorando lista de lojas inicial vazia (seed do BehaviorSubject). Aguardando dados reais.",
      );
      return; // Não faz nada, espera a próxima emissão
    }

    if (stores.isEmpty) {
      emit(const StoresManagerEmpty());
      return;
    }

    if (currentState is StoresManagerLoaded) {
      emit(
        currentState.copyWith(
          stores: {for (var s in stores) s.store.core.id!: s},
        ),
      );
    } else {
      final firstStoreId = stores.first.store.core.id!;
      emit(
        StoresManagerLoaded(
          stores: {for (var s in stores) s.store.core.id!: s},
          activeStoreId: firstStoreId,
          consolidatedStores: const [],
          notificationCounts: const {},
          lastUpdate: DateTime.now(),
        ),
      );
      _realtimeRepository.joinStoreRoom(firstStoreId);
     
    }
  }

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

      // Apenas emitimos a mudança de ID. O listener de produtos vai reagir a isso.
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








  // ✅ ADICIONE ESTE NOVO MÉTODO ÚNICO
  void _onFullMenuUpdated(FullMenuData menuData) {
    _updateActiveStore((_, activeStore) {
      final newRelations = activeStore.store.relations.copyWith(
        products: menuData.products,
        categories: menuData.categories, // Já vem reconciliada!
        variants: menuData.variants,
      );
      return activeStore.copyWith(store: activeStore.store.copyWith(relations: newRelations));
    });


    log("✅ [CUBIT] Menu completo (produtos, categorias, variantes) atualizado via socket de forma atômica.");
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



  void _cancelSubscriptions() {
    _adminStoresListSubscription?.cancel();
    _notificationSubscription?.cancel();
    _connectivitySubscription?.cancel();
    _storeDetailsSubscription?.cancel();
    _dashboardDataSubscription?.cancel();
    _financialsSubscription?.cancel();


    _adminStoresListSubscription = null;
  }

  // ✅ ATUALIZE O MÉTODO resetState
  void resetState() {
    log('[StoresManagerCubit] Resetando estado e cancelando listeners...');
    // 1. Apenas cancela as assinaturas ativas
    _cancelSubscriptions();
    // 2. Emite o estado inicial para limpar a UI
    emit(const StoresManagerInitial());
  }

  // ✅ ATUALIZE O MÉTODO close PARA USAR O HELPER
  @override
  Future<void> close() {
    log('[StoresManagerCubit] Fechando o Cubit e todos os listeners.');
    _cancelSubscriptions();
    return super.close();
  }
}
