// Em: cubits/operation_config_state.dart

part of 'operation_config_cubit.dart';

abstract class OperationConfigState extends Equatable {
  const OperationConfigState();

  @override
  List<Object> get props => [];
}

class OperationConfigInitial extends OperationConfigState {}

class OperationConfigActionInProgress extends OperationConfigState {}

class OperationConfigActionSuccess extends OperationConfigState {
  final String message;
  const OperationConfigActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class OperationConfigActionFailure extends OperationConfigState {
  final String error;
  const OperationConfigActionFailure(this.error);

  @override
  List<Object> get props => [error];
}