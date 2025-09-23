// Em: lib/cubits/store_manager_state.dart

import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';

import '../core/enums/connectivity_status.dart';
import '../models/dashboard_data.dart';
import '../models/holiday.dart';

abstract class StoresManagerState extends Equatable {
  const StoresManagerState();

  // Getter seguro: por padrão, retorna null.
  Store? get activeStore => null;

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
  final Map<int, StoreWithRole> stores;
  final int activeStoreId;
  final List<int> consolidatedStores;
  final String? subscriptionWarning;
  final Map<int, int> notificationCounts;
  final DateTime lastUpdate;
  final List<Holiday>? holidays;
  final ConnectivityStatus connectivityStatus;
  final Set<int> stuckOrderIds;



  const StoresManagerLoaded({
    required this.stores,
    required this.activeStoreId,
    required this.consolidatedStores,
    this.subscriptionWarning,
    this.notificationCounts = const {},
    required this.lastUpdate,
    this.holidays,
    this.connectivityStatus = ConnectivityStatus.connected,
    this.stuckOrderIds = const {},

  });

  @override
  Store? get activeStore => stores[activeStoreId]?.store;

  // ✅ CORREÇÃO ADICIONADA AQUI
  /// Retorna o objeto completo [StoreWithRole], que inclui a loja e a permissão (role).
  /// Este é o getter que o Cubit deve usar para suas operações internas.
  StoreWithRole? get activeStoreWithRole => stores[activeStoreId];

  DashboardData? get dashboardData => activeStore?.relations.dashboardData;

  StoresManagerLoaded copyWith({
    Map<int, StoreWithRole>? stores,
    int? activeStoreId,
    List<int>? consolidatedStores,
    String? subscriptionWarning,
    Map<int, int>? notificationCounts,
    DateTime? lastUpdate,
    List<Holiday>? holidays,
    ConnectivityStatus? connectivityStatus,
    Set<int>? stuckOrderIds,

  }) {
    return StoresManagerLoaded(
      stores: stores ?? this.stores,
      activeStoreId: activeStoreId ?? this.activeStoreId,
      consolidatedStores: consolidatedStores ?? this.consolidatedStores,
      subscriptionWarning: subscriptionWarning ?? this.subscriptionWarning,
      notificationCounts: notificationCounts ?? this.notificationCounts,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      holidays: holidays ?? this.holidays,
      connectivityStatus: connectivityStatus ?? this.connectivityStatus,
      stuckOrderIds: stuckOrderIds ?? this.stuckOrderIds,

    );
  }

  @override
  List<Object?> get props => [
    stores,
    activeStoreId,
    consolidatedStores,
    subscriptionWarning,
    notificationCounts,
    holidays,
    lastUpdate,
    connectivityStatus,

  ];
}

class StoresManagerError extends StoresManagerState {
  final String message;
  const StoresManagerError({required this.message});

  @override
  List<Object?> get props => [message];
}