// Em: cubits/opening_hours_state.dart

part of 'opening_hours_cubit.dart';

abstract class OpeningHoursState extends Equatable {
  const OpeningHoursState();

  @override
  List<Object> get props => [];
}

class OpeningHoursInitial extends OpeningHoursState {}

class OpeningHoursActionInProgress extends OpeningHoursState {}

class OpeningHoursActionSuccess extends OpeningHoursState {
  final String message;
  const OpeningHoursActionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class OpeningHoursActionFailure extends OpeningHoursState {
  final String error;
  const OpeningHoursActionFailure(this.error);

  @override
  List<Object> get props => [error];
}