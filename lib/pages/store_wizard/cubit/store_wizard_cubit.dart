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

  final profileKey = GlobalKey<StoreProfilePageState>();
  final hoursKey = GlobalKey<OpeningHoursPageState>();
  final catalogKey = GlobalKey<CategoryProductPageState>();

  StoreWizardCubit({
    required this.storeId,
    required StoresManagerCubit storesManagerCubit,
  })  : _storesManagerCubit = storesManagerCubit,
        super(StoreWizardInitial()) {
    // ✅ LÓGICA DE INICIALIZAÇÃO MOVIDA PARA O CONSTRUTOR
    _initialize();

    // A escuta de eventos continua, mas agora só para atualizações em background
    _storesManagerSubscription =
        _storesManagerCubit.stream.listen(_onStoresManagerUpdated);
  }

  void _initialize() {
    final managerState = _storesManagerCubit.state;
    if (managerState is StoresManagerLoaded) {
      final storeWithRole = managerState.stores[storeId];
      if (storeWithRole != null) {
        final store = storeWithRole.store;
        final statusMap = <StoreConfigStep, bool>{};
        for (var step in StoreConfigStep.values) {
          statusMap[step] = _isStepCompleted(step, store);
        }

        // Esta é a lógica que tínhamos perdido: encontrar a primeira etapa pendente.
        // Agora ela roda APENAS na inicialização.
        StoreConfigStep firstPendingStep = StoreConfigStep.values.firstWhere(
              (step) => !statusMap[step]!,
          orElse: () => StoreConfigStep.finish,
        );

        emit(StoreWizardLoaded(
          store: store,
          currentStep: firstPendingStep,
          stepCompletionStatus: statusMap,
        ));
      } else {
        emit(StoreWizardError("A loja com ID $storeId não foi encontrada."));
      }
    } else {
      emit(StoreWizardLoading());
    }
  }

  // ✅ NOVA FUNÇÃO APENAS PARA ATUALIZAÇÕES
  void _onStoresManagerUpdated(StoresManagerState managerState) {
    final currentState = state;
    if (managerState is StoresManagerLoaded && currentState is StoreWizardLoaded) {
      final storeWithRole = managerState.stores[storeId];
      if (storeWithRole != null) {
        final newStoreData = storeWithRole.store;
        final newStatusMap = <StoreConfigStep, bool>{};
        for (var step in StoreConfigStep.values) {
          newStatusMap[step] = _isStepCompleted(step, newStoreData);
        }

        // Apenas atualiza os dados, NUNCA a etapa atual.
        emit(currentState.copyWith(
          store: newStoreData,
          stepCompletionStatus: newStatusMap,
        ));
      }
    }
  }

  // ... (O resto do arquivo continua exatamente como na sua versão)

  bool _isStepCompleted(StoreConfigStep step, Store store) {
    switch (step) {
      case StoreConfigStep.profile:
        return store.core.name.isNotEmpty &&
            (store.core.urlSlug?.isNotEmpty ?? false) &&
            (store.core.phone?.isNotEmpty ?? false);

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

  Future<void> goToNextStep() async {
    final currentState = state;
    if (currentState is! StoreWizardLoaded) return;

    emit(currentState.copyWith(isLoadingAction: true));

    bool canAdvance = await _validateCurrentStep(currentState);

    if (canAdvance) {
      final newStatusMap =
      Map<StoreConfigStep, bool>.from(currentState.stepCompletionStatus);
      newStatusMap[currentState.currentStep] = true;

      final currentIndex = currentState.currentStep.index;
      final nextStep = (currentIndex + 1 < StoreConfigStep.values.length)
          ? StoreConfigStep.values[currentIndex + 1]
          : StoreConfigStep.finish;

      StoreConfigStep? newLastWorkStep = currentState.lastWorkStep;

      if (nextStep != StoreConfigStep.finish) {
        newLastWorkStep = nextStep;
      }

      emit(currentState.copyWith(
        currentStep: nextStep,
        stepCompletionStatus: newStatusMap,
        isLoadingAction: false,
        lastWorkStep: newLastWorkStep,
      ));
    } else {
      emit(currentState.copyWith(isLoadingAction: false));
    }
  }

  Future<bool> _validateCurrentStep(StoreWizardLoaded currentState) async {
    switch (currentState.currentStep) {
      case StoreConfigStep.profile:
        final hasChanges = profileKey.currentState?.hasChanges() ?? false;
        return hasChanges
            ? (await profileKey.currentState?.save() ?? false)
            : true;
      case StoreConfigStep.openingHours:
        return await hoursKey.currentState?.save() ?? false;
      case StoreConfigStep.productCatalog:
        final hasContent = await catalogKey.currentState?.hasContent() ?? false;
        if (!hasContent) {
          AppToasts.showError(
              "Você precisa adicionar pelo menos uma categoria e um produto.");
        }
        return hasContent;
      default:
        return true;
    }
  }

  void goToPreviousStep() {
    final currentState = state;
    if (currentState is! StoreWizardLoaded) return;
    if (currentState.currentStep.index == 0) return;

    StoreConfigStep previousStep;
    final currentStep = currentState.currentStep;

    if (currentStep == StoreConfigStep.finish) {
      previousStep = currentState.lastWorkStep ?? StoreConfigStep.productCatalog;
    } else {
      previousStep = StoreConfigStep.values[currentStep.index - 1];
    }

    emit(currentState.copyWith(currentStep: previousStep));
  }

  void goToStep(StoreConfigStep step) {
    final currentState = state;
    if (currentState is! StoreWizardLoaded) return;

    if (step.index <= currentState.currentStep.index ||
        (currentState.stepCompletionStatus[step] ?? false)) {
      emit(currentState.copyWith(currentStep: step));
    } else {
      AppToasts.showInfo("Por favor, complete as etapas anteriores primeiro.");
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
        context.go('/stores/$storeId/splash');
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

  @override
  Future<void> close() {
    _storesManagerSubscription.cancel();
    return super.close();
  }
}