import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/models/store/store_hour.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/add_shift_dialog.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/edit_shift_dialog.dart';

part 'store_wizard_state.dart';

class StoreWizardCubit extends Cubit<StoreWizardState> {
  final StoresManagerCubit _storesManagerCubit;
  final int storeId;
  late final StreamSubscription _storesManagerSubscription;

  StoreWizardCubit({
    required this.storeId,
    required StoresManagerCubit storesManagerCubit,
  })  : _storesManagerCubit = storesManagerCubit,
        super(StoreWizardInitial()) {
    // Escuta as mudanças no cubit principal
    _storesManagerSubscription =
        _storesManagerCubit.stream.listen(_onStoresManagerStateChanged);

    // Processa o estado inicial do cubit principal
    _onStoresManagerStateChanged(_storesManagerCubit.state);
  }

  void _onStoresManagerStateChanged(StoresManagerState managerState) {
    if (managerState is StoresManagerLoaded) {
      final storeWithRole = managerState.stores[storeId];
      if (storeWithRole != null) {
        // Se a loja for encontrada, emite o estado `Loaded` com os dados dela
        emit(StoreWizardLoaded(storeWithRole.store));
      } else {
        // Se a loja não for encontrada no cubit principal, emite um erro
        emit(StoreWizardError(
            "A loja com ID $storeId não foi encontrada no estado principal."));
      }
    } else {
      // Se o cubit principal estiver carregando, este cubit também estará
      emit(StoreWizardLoading());
    }
  }

  // Os métodos de ação agora simplesmente DELEGAM a chamada para o cubit principal.

  Future<void> addHours(AddShiftResult result) async {
    await _storesManagerCubit.addHours(storeId, result);
  }

  Future<void> removeHour(StoreHour hourToRemove) async {
    await _storesManagerCubit.removeHour(storeId, hourToRemove);
  }

  Future<void> updateHour(StoreHour oldHour, EditShiftResult result) async {
    await _storesManagerCubit.updateHour(storeId, oldHour, result);
  }

  @override
  Future<void> close() {
    _storesManagerSubscription.cancel();
    return super.close();
  }
}