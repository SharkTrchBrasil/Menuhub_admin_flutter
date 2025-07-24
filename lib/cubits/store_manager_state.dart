// Em: cubits/store_manager_state.dart

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';

import '../models/store.dart';

@immutable
abstract class StoresManagerState {
  const StoresManagerState();
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
  // NOVO: Campo para guardar a mensagem de aviso.
  final String? subscriptionWarning;


  // --- NOVO: Campo para contagem de notificações ---
  final Map<int, int> notificationCounts;

  // ✅ GETTER ADICIONADO AQUI
  /// Retorna o objeto Store completo da loja que está ativa no momento.
  /// Ele faz a busca no mapa de 'stores' usando o 'activeStoreId'.
  Store? get activeStore => stores[activeStoreId]?.store;


  final DateTime lastUpdate;

  const StoresManagerLoaded({
    required this.stores,
    required this.activeStoreId,
    required this.consolidatedStores,
    this.notificationCounts = const {}, // Valor padrão é um mapa vazio
    required this.lastUpdate,
    this.subscriptionWarning, // NOVO
  });

  StoresManagerLoaded copyWith({
    Map<int, StoreWithRole>? stores,
    int? activeStoreId,
    List<int>? consolidatedStores,
    Map<int, int>? notificationCounts, // Permitir cópia do novo campo
    DateTime? lastUpdate,
    String? subscriptionWarning,
  }) {
    return StoresManagerLoaded(
      stores: stores ?? this.stores,
      activeStoreId: activeStoreId ?? this.activeStoreId,
      consolidatedStores: consolidatedStores ?? this.consolidatedStores,
      notificationCounts: notificationCounts ?? this.notificationCounts,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      subscriptionWarning: subscriptionWarning ?? this.subscriptionWarning,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other is StoresManagerLoaded &&
        mapEquals(other.stores, stores) &&
        other.activeStoreId == activeStoreId &&
        listEquals(other.consolidatedStores, consolidatedStores) &&
        mapEquals(other.notificationCounts, notificationCounts); // Comparar o novo campo
  }

  @override
  int get hashCode =>
      stores.hashCode ^
      activeStoreId.hashCode ^
      consolidatedStores.hashCode ^
      notificationCounts.hashCode; // Adicionar ao hashCode
}

class StoresManagerError extends StoresManagerState {
  final String message;
  const StoresManagerError({required this.message});
}