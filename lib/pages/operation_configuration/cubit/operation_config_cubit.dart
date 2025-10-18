// Em: cubits/operation_config_cubit.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../models/store/store_operation_config.dart';
import '../../../repositories/store_operation_config_repository.dart';
import '../../../widgets/app_toasts.dart' as AppToasts;


part 'operation_config_state.dart';

class OperationConfigCubit extends Cubit<OperationConfigState> {
  final StoreOperationConfigRepository _storeOperationConfigRepository;

  OperationConfigCubit({
    required StoreOperationConfigRepository storeOperationConfigRepository,
  })  : _storeOperationConfigRepository = storeOperationConfigRepository,
        super(OperationConfigInitial());

  /// Atualiza as configurações de operação da loja
  Future<void> updateConfiguration(int storeId, StoreOperationConfig config) async {
    emit(OperationConfigActionInProgress());

    try {
      final result = await _storeOperationConfigRepository.updateConfiguration(
        storeId,
        config,
      );

      result.fold(
            (error) {
          emit(OperationConfigActionFailure(error));
          AppToasts.showError('Falha ao salvar as configurações.');
        },
            (_) {
          emit(const OperationConfigActionSuccess('Configurações de operação salvas!'));
          AppToasts.showSuccess('Configurações de operação salvas!');
        },
      );
    } catch (e) {
      emit(OperationConfigActionFailure(e.toString()));
      AppToasts.showError('Ocorreu um erro inesperado.');
    }
  }

  /// Atualiza configurações específicas (para uso em toggles rápidos)
  Future<void> updatePartialSettings(
      int storeId,
      StoreOperationConfig currentConfig, {
        bool? deliveryEnabled,
        bool? pickupEnabled,
        bool? tableEnabled,
        bool? isStoreOpen,
        bool? autoAcceptOrders,
        bool? autoPrintOrders,
        String? mainPrinterDestination,
        String? kitchenPrinterDestination,
        String? barPrinterDestination,
      }) async {
    final updatedConfig = currentConfig.copyWith(
      deliveryEnabled: deliveryEnabled ?? currentConfig.deliveryEnabled,
      pickupEnabled: pickupEnabled ?? currentConfig.pickupEnabled,
      tableEnabled: tableEnabled ?? currentConfig.tableEnabled,
      isStoreOpen: isStoreOpen ?? currentConfig.isStoreOpen,
      autoAcceptOrders: autoAcceptOrders ?? currentConfig.autoAcceptOrders,
      autoPrintOrders: autoPrintOrders ?? currentConfig.autoPrintOrders,
      mainPrinterDestination: mainPrinterDestination ?? currentConfig.mainPrinterDestination,
      kitchenPrinterDestination: kitchenPrinterDestination ?? currentConfig.kitchenPrinterDestination,
      barPrinterDestination: barPrinterDestination ?? currentConfig.barPrinterDestination,
    );

    await updateConfiguration(storeId, updatedConfig);
  }
}