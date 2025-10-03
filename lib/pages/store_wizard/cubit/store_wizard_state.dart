part of 'store_wizard_cubit.dart';

abstract class StoreWizardState extends Equatable {
  const StoreWizardState();

  @override
  List<Object> get props => [];
}

class StoreWizardInitial extends StoreWizardState {}

class StoreWizardLoading extends StoreWizardState {}

class StoreWizardLoaded extends StoreWizardState {
  final Store store;

  const StoreWizardLoaded(this.store);

  @override
  List<Object> get props => [store];
}

class StoreWizardError extends StoreWizardState {
  final String message;

  const StoreWizardError(this.message);

  @override
  List<Object> get props => [message];
}