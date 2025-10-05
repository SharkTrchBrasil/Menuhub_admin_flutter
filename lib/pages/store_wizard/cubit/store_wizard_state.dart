part of 'store_wizard_cubit.dart';

abstract class StoreWizardState extends Equatable {
  const StoreWizardState();
  @override
  List<Object?> get props => [];
}

class StoreWizardInitial extends StoreWizardState {}

class StoreWizardLoading extends StoreWizardState {}

class StoreWizardLoaded extends StoreWizardState {
  final Store store;
  final StoreConfigStep currentStep;
  final Map<StoreConfigStep, bool> stepCompletionStatus;
  final bool isLoadingAction;
  final StoreConfigStep? lastWorkStep;

  const StoreWizardLoaded({
    required this.store,
    required this.currentStep,
    required this.stepCompletionStatus,
    this.isLoadingAction = false,
    this.lastWorkStep,
  });

  @override
  List<Object?> get props => [
    store,
    currentStep,
    stepCompletionStatus,
    isLoadingAction,
    lastWorkStep,
  ];

  StoreWizardLoaded copyWith({
    Store? store,
    StoreConfigStep? currentStep,
    Map<StoreConfigStep, bool>? stepCompletionStatus,
    bool? isLoadingAction,
    StoreConfigStep? lastWorkStep,
  }) {
    return StoreWizardLoaded(
      store: store ?? this.store,
      currentStep: currentStep ?? this.currentStep,
      stepCompletionStatus: stepCompletionStatus ?? this.stepCompletionStatus,
      isLoadingAction: isLoadingAction ?? this.isLoadingAction,
      lastWorkStep: lastWorkStep ?? this.lastWorkStep,
    );
  }
}

class StoreWizardError extends StoreWizardState {
  final String message;
  const StoreWizardError(this.message);
  @override
  List<Object> get props => [message];
}