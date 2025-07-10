import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/store_with_role.dart';

abstract class StoresManagerState extends Equatable {
  const StoresManagerState();

  @override
  List<Object?> get props => [];
}

class StoresManagerLoading extends StoresManagerState {
  const StoresManagerLoading();
}

class StoresManagerEmpty extends StoresManagerState {
  const StoresManagerEmpty();
}

class StoresManagerLoaded extends StoresManagerState {
  final Map<int, StoreWithRole> stores;
  final int? activeStoreId;
  final DateTime lastUpdate;

  const StoresManagerLoaded({
    required this.stores,
    required this.activeStoreId,
    required this.lastUpdate,
  });

  StoreWithRole? get activeStore => stores[activeStoreId];

  @override
  List<Object?> get props => [stores, activeStoreId, lastUpdate];
}

class StoresManagerError extends StoresManagerState {
  final String message;

  const StoresManagerError({required this.message});

  @override
  List<Object?> get props => [message];
}
