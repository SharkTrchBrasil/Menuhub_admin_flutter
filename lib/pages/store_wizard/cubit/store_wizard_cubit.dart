import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart' as AppToasts;
import 'package:totem_pro_admin/pages/store_wizard/store_wizard_page.dart';

import '../../../models/store/store_hour.dart';
import '../../edit_settings/general/store_profile_page.dart';
import '../../edit_settings/hours/hours_store_page.dart';
import '../../edit_settings/hours/widgets/add_shift_dialog.dart';
import '../../edit_settings/hours/widgets/edit_shift_dialog.dart';
import '../../products/products_page.dart';

part 'store_wizard_state.dart';

class StoreWizardCubit extends Cubit<StoreWizardState> {
  final StoresManagerCubit _storesManagerCubit;
  final int storeId;
  late final StreamSubscription _storesManagerSubscription;
  bool _hasReceivedInitialData = false;

  final profileKey = GlobalKey<StoreProfilePageState>();
  final hoursKey = GlobalKey<OpeningHoursPageState>();
  final catalogKey = GlobalKey<CategoryProductPageState>();

  StoreWizardCubit({
    required this.storeId,
    required StoresManagerCubit storesManagerCubit,
  })  : _storesManagerCubit = storesManagerCubit,
        super(StoreWizardInitial()) {
    _initialize();
    _storesManagerSubscription =
        _storesManagerCubit.stream.listen(_onStoresManagerUpdated);
  }

  @override
  Future<void> close() {
    _storesManagerSubscription.cancel();
    return super.close();
  }

  void _initialize() {
    final managerState = _storesManagerCubit.state;
    if (managerState is StoresManagerLoaded) {
      final storeWithRole = managerState.stores[storeId];
      if (storeWithRole != null) {
        if (_hasCompleteData(storeWithRole.store)) {
          _hasReceivedInitialData = true;
          _updateStateFromStore(storeWithRole.store, isInitialLoad: true);
        } else {
          print('⏳ Aguardando dados completos via WebSocket...');
          emit(StoreWizardLoading());
        }
      } else {
        emit(StoreWizardError("A loja com ID $storeId não foi encontrada."));
      }
    } else {
      emit(StoreWizardLoading());
    }
  }

  bool _hasCompleteData(Store store) {
    final hasPaymentMethods = store.relations.paymentMethodGroups != null;
    final hasCategories = store.relations.categories != null;
    final hasCities = store.relations.cities != null;

    print('📦 Verificando dados completos:');
    print('   - Pagamentos: $hasPaymentMethods (${store.relations.paymentMethodGroups?.length ?? 'null'} grupos)');
    print('   - Categorias: $hasCategories (${store.relations.categories?.length ?? 'null'} categorias)');
    print('   - Cidades: $hasCities (${store.relations.cities?.length ?? 'null'} cidades)');

    return hasPaymentMethods && hasCategories && hasCities;
  }

  void _onStoresManagerUpdated(StoresManagerState managerState) {
    if (managerState is StoresManagerLoaded) {
      final storeWithRole = managerState.stores[storeId];
      if (storeWithRole != null) {
        if (!_hasReceivedInitialData && _hasCompleteData(storeWithRole.store)) {
          print('🎉 Dados completos recebidos via WebSocket! Inicializando wizard...');
          _hasReceivedInitialData = true;
          _updateStateFromStore(storeWithRole.store, isInitialLoad: true);
        } else if (_hasReceivedInitialData) {
          _updateStateFromStore(storeWithRole.store, isInitialLoad: false);
        }
      }
    }
  }

  bool _isStepCompleted(StoreConfigStep step, Store store) {
    switch (step) {
      case StoreConfigStep.profile:
      // ✅ ALTERAÇÃO: Adicionada a verificação da imagem (file_key)
        return store.core.name.isNotEmpty &&
            (store.core.phone?.isNotEmpty ?? false) &&
            (store.address?.street?.isNotEmpty ?? false) &&
            (store.media?.image?.hasImage ?? false);



      case StoreConfigStep.paymentMethods:
        return store.relations.paymentMethodGroups
            .expand((group) => group.methods)
            .any((method) => method.activation?.isActive ?? false);
      case StoreConfigStep.deliveryArea:
        return store.relations.cities?.isNotEmpty ?? false;
      case StoreConfigStep.openingHours:
        return store.relations.hours.isNotEmpty;
      case StoreConfigStep.productCatalog:
        return store.relations.categories.isNotEmpty;
      case StoreConfigStep.finish:
        return store.core.isSetupComplete;
    }
  }

  StoreConfigStep _findFirstPendingStep(Store store) {
    final stepsInOrder = [
      StoreConfigStep.profile,
      StoreConfigStep.paymentMethods,
      StoreConfigStep.deliveryArea,
      StoreConfigStep.openingHours,
      StoreConfigStep.productCatalog,
    ];

    print('🔍 Buscando primeira etapa pendente:');

    for (final step in stepsInOrder) {
      final isCompleted = _isStepCompleted(step, store);
      print('   - $step: $isCompleted');

      if (!isCompleted) {
        print('🎯 PRIMEIRA ETAPA PENDENTE ENCONTRADA: $step');
        return step;
      }
    }

    print('✅ Todas as etapas estão completas, indo para FINISH');
    return StoreConfigStep.finish;
  }

  void _updateStateFromStore(Store store, {required bool isInitialLoad}) {
    final newStatusMap = <StoreConfigStep, bool>{};
    for (var step in StoreConfigStep.values) {
      newStatusMap[step] = _isStepCompleted(step, store);
    }

    final currentState = state;

    if (isInitialLoad || currentState is! StoreWizardLoaded) {
      final firstPendingStep = _findFirstPendingStep(store);

      print('🚀 CONFIGURANDO WIZARD:');
      print('   - Store: ${store.core.name} (ID: ${store.core.id})');
      print('   - Primeira etapa: $firstPendingStep');
      print('   - Status: Profile=${newStatusMap[StoreConfigStep.profile]}, '
          'Payments=${newStatusMap[StoreConfigStep.paymentMethods]}, '
          'Delivery=${newStatusMap[StoreConfigStep.deliveryArea]}, '
          'Hours=${newStatusMap[StoreConfigStep.openingHours]}, '
          'Catalog=${newStatusMap[StoreConfigStep.productCatalog]}');

      emit(StoreWizardLoaded(
        store: store,
        currentStep: firstPendingStep,
        stepCompletionStatus: newStatusMap,
      ));
    } else {
      emit(currentState.copyWith(
        store: store,
        stepCompletionStatus: newStatusMap,
      ));
    }
  }

  // Este método agora chama o método `validate` da página do passo atual.
  bool _validateCurrentStep(StoreWizardLoaded state) {
    switch (state.currentStep) {
      case StoreConfigStep.profile:
      // Chama a validação do Form dentro de StoreProfilePage
        return profileKey.currentState?.validateForm() ?? false;

    // Adicione a lógica para outros passos aqui, se eles tiverem formulários
    // case StoreConfigStep.openingHours:
    //   return hoursKey.currentState?.validateForm() ?? false;

    // Para passos sem formulário, podemos usar a lógica antiga
      case StoreConfigStep.paymentMethods:
        final isValid = _isStepCompleted(StoreConfigStep.paymentMethods, state.store);
        if (!isValid) AppToasts.showError("Selecione ao menos um método de pagamento.");
        return isValid;

      case StoreConfigStep.deliveryArea:
        final isValid = _isStepCompleted(StoreConfigStep.deliveryArea, state.store);
        if (!isValid) AppToasts.showError("Configure ao menos uma área de entrega.");
        return isValid;

      case StoreConfigStep.productCatalog:
        final isValid = _isStepCompleted(StoreConfigStep.productCatalog, state.store);
        if (!isValid) AppToasts.showError("Cadastre ao menos um produto.");
        return isValid;

      default:
        return true; // Passos como 'finish' são sempre válidos para avançar
    }
  }

  Future<void> goToNextStep() async {
    final currentState = state;
    if (currentState is! StoreWizardLoaded) return;

    // ✅ 3. LÓGICA DE VALIDAÇÃO DELEGADA PARA A PÁGINA
    bool isStepValid = _validateCurrentStep(currentState);

    // Se o passo atual não for válido, simplesmente retorne.
    // A própria página já terá mostrado os erros nos campos.
    if (!isStepValid) {
      return;
    }

    emit(currentState.copyWith(isLoadingAction: true));

    bool didSave = await _saveCurrentStep(currentState);
    if (!didSave) {
      emit(currentState.copyWith(isLoadingAction: false));
      return;
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final updatedState = state;
    if (updatedState is! StoreWizardLoaded) {
      emit(currentState.copyWith(isLoadingAction: false));
      return;
    }

    final currentIndex = updatedState.currentStep.index;
    final nextStep = (currentIndex + 1 < StoreConfigStep.values.length)
        ? StoreConfigStep.values[currentIndex + 1]
        : StoreConfigStep.finish;

    emit(updatedState.copyWith(
      currentStep: nextStep,
      isLoadingAction: false,
    ));
  }






  Future<bool> _saveCurrentStep(StoreWizardLoaded currentState) async {
    switch (currentState.currentStep) {
      case StoreConfigStep.profile:
        final hasChanges = profileKey.currentState?.hasChanges() ?? false;
        if (hasChanges) {
          return await profileKey.currentState?.save() ?? false;
        }
        return true;
      case StoreConfigStep.openingHours:
        return await hoursKey.currentState?.save() ?? true;
      default:
        return true;
    }
  }

  void goToPreviousStep() {
    final currentState = state;
    if (currentState is! StoreWizardLoaded || currentState.currentStep.index == 0) return;

    final previousStep = StoreConfigStep.values[currentState.currentStep.index - 1];
    emit(currentState.copyWith(currentStep: previousStep));
  }

  void goToStep(StoreConfigStep step) {
    final currentState = state;
    if (currentState is! StoreWizardLoaded) return;

    final currentStepIndex = currentState.currentStep.index;
    final targetStepIndex = step.index;

    // ✅ ALTERAÇÃO: Permite navegar para qualquer etapa anterior,
    // independentemente do status de "concluído".
    if (targetStepIndex < currentStepIndex) {
      emit(currentState.copyWith(currentStep: step));
    }
    // Mantém a lógica para etapas futuras: só pode ir se já estiver concluída.
    else if (currentState.stepCompletionStatus[step] ?? false) {
      emit(currentState.copyWith(currentStep: step));
    }
    else {
      AppToasts.showInfo("Complete as etapas anteriores primeiro.");
    }
  }

  Future<void> finishSetup(BuildContext context) async {
    final currentState = state;
    if (currentState is! StoreWizardLoaded) return;

    emit(currentState.copyWith(isLoadingAction: true));

    final result = await getIt<StoreRepository>().completeStoreSetup(storeId);
    result.fold(
          (failure) {
        AppToasts.showError(failure.message);
        emit(currentState.copyWith(isLoadingAction: false));
      },
          (_) {
        AppToasts.showSuccess('Configuração concluída! Bem-vindo(a)!');
        context.go('/stores/$storeId/dashboard');
      },
    );
  }

  Future<void> addHours(AddShiftResult result) async {
    await _storesManagerCubit.addHours(storeId, result);
  }

  Future<void> removeHour(StoreHour hourToRemove) async {
    await _storesManagerCubit.removeHour(storeId, hourToRemove);
  }

  Future<void> updateHour(StoreHour oldHour, EditShiftResult result) async {
    await _storesManagerCubit.updateHour(storeId, oldHour, result);
  }
}