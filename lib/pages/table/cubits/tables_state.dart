// logic/tables/tables_state.dart
import 'package:equatable/equatable.dart';

import '../../../models/table.dart';


abstract class TablesState extends Equatable {
  const TablesState();
  @override
  List<Object> get props => [];
}

class TablesInitial extends TablesState {}

class TablesLoading extends TablesState {}

class TablesLoaded extends TablesState {
  final Map<int, Table> tables; // Usar um Map<tableId, TableDetails> é eficiente

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