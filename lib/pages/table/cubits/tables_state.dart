// logic/tables/tables_state.dart
import 'package:equatable/equatable.dart';

import '../../../models/tables/table.dart';


abstract class TablesState extends Equatable {
  const TablesState();
  @override
  List<Object> get props => [];
}

class TablesInitial extends TablesState {}

class TablesLoading extends TablesState {}

class TablesLoaded extends TablesState {
  final Map<int, TableModel> tables; // Use TableModel from the model

  const TablesLoaded(this.tables);

  @override
  List<Object> get props => [tables];
}

class TablesError extends TablesState {
  final String message;
  const TablesError(this.message);

  @override
  List<Object> get props => [message];
}