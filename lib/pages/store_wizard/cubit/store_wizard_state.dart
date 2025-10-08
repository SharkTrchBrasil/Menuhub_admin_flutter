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

  const StoreWizardLoaded({
    required this.store,
    required this.currentStep,
    required this.stepCompletionStatus,
    this.isLoadingAction = false,
  });

  @override
  List<Object?> get props => [
    store,
    currentStep,
    stepCompletionStatus,
    isLoadingAction,
  ];

  StoreWizardLoaded copyWith({
    Store? store,
    StoreConfigStep? currentStep,
    Map<StoreConfigStep, bool>? stepCompletionStatus,
    bool? isLoadingAction,
  }) {
    return StoreWizardLoaded(
      store: store ?? this.store,
      currentStep: currentStep ?? this.currentStep,
      stepCompletionStatus: stepCompletionStatus ?? this.stepCompletionStatus,
      isLoadingAction: isLoadingAction ?? this.isLoadingAction,
    );
  }
}

class StoreWizardError extends StoreWizardState {
  final String message;
  const StoreWizardError(this.message);
  @override
  List<Object> get props => [message];
}