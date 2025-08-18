// Em: lib/cubits/store_manager_state.dart

import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';

// ✅ MUDANÇA 1: A classe base agora estende `Equatable`
abstract class StoresManagerState extends Equatable {
  const StoresManagerState();

  // Getter seguro: por padrão, retorna null.
  Store? get activeStore => null;

  // A lista de props na classe base pode ser vazia
  @override
  List<Object?> get props => [];
}

class StoresManagerInitial extends StoresManagerState {
  const StoresManagerInitial();
}

class StoresManagerLoading extends StoresManagerState {
  const StoresManagerLoading();
}

class StoresManagerEmpty extends StoresManagerState {
  const StoresManagerEmpty();
}

class StoresManagerLoaded extends StoresManagerState {
  // ✅ CAMPOS UNIFICADOS: Todos os campos que você precisa em um só lugar.
  final Map<int, StoreWithRole> stores;
  final int activeStoreId;
  final List<int> consolidatedStores;
  final String? subscriptionWarning;
  final Map<int, int> notificationCounts;
  final DateTime lastUpdate;

  const StoresManagerLoaded({
    required this.stores,
    required this.activeStoreId,
    required this.consolidatedStores,
    this.subscriptionWarning,
    this.notificationCounts = const {},
    required this.lastUpdate,
  });

  // ✅ GETTER ÚNICO E CORRETO: Sobrescreve o getter da classe base.
  @override
  Store? get activeStore => stores[activeStoreId]?.store;

  // ✅ MÉTODO `copyWith` ÚNICO E COMPLETO: Inclui todos os campos.
  StoresManagerLoaded copyWith({
    Map<int, StoreWithRole>? stores,
    int? activeStoreId,
    List<int>? consolidatedStores,
    String? subscriptionWarning,
    Map<int, int>? notificationCounts,
    DateTime? lastUpdate,
  }) {
    return StoresManagerLoaded(
      stores: stores ?? this.stores,
      activeStoreId: activeStoreId ?? this.activeStoreId,
      consolidatedStores: consolidatedStores ?? this.consolidatedStores,
      subscriptionWarning: subscriptionWarning ?? this.subscriptionWarning,
      notificationCounts: notificationCounts ?? this.notificationCounts,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  // ✅ MUDANÇA 2: Usando `props` para a comparação, em vez de `operator==` e `hashCode` manuais.
  // É mais seguro e mais fácil de manter.
  @override
  List<Object?> get props => [
    stores,
    activeStoreId,
    consolidatedStores,
    subscriptionWarning,
    notificationCounts,
    lastUpdate,
  ];
}

class StoresManagerError extends StoresManagerState {
  final String message;
  const StoresManagerError({required this.message});

  @override
  List<Object?> get props => [message];
}