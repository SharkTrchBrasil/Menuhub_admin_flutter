// lib/cubits/tables/tables_state.dart
part of 'tables_cubit.dart';

abstract class TablesState extends Equatable {
  const TablesState();

  @override
  List<Object?> get props => [];
}

class TablesInitial extends TablesState {}

class TablesLoading extends TablesState {}

class TablesLoaded extends TablesState {
  final List<Saloon> saloons;
  final TableModel? selectedTable;

  const TablesLoaded({
    required this.saloons,
    this.selectedTable,
  });

  @override
  List<Object?> get props => [saloons, selectedTable];

  TablesLoaded copyWith({
    List<Saloon>? saloons,
    TableModel? selectedTable,
  }) {
    return TablesLoaded(
      saloons: saloons ?? this.saloons,
      selectedTable: selectedTable,
    );
  }

  // ✅ HELPERS ÚTEIS
  int get totalTables => saloons.fold(0, (sum, saloon) => sum + saloon.tables.length);

  int get availableTables => saloons.fold(
    0,
        (sum, saloon) => sum + saloon.tables.where((t) => t.isAvailable).length,
  );

  int get occupiedTables => saloons.fold(
    0,
        (sum, saloon) => sum + saloon.tables.where((t) => t.isOccupied).length,
  );
}

class TablesError extends TablesState {
  final String message;

  const TablesError(this.message);

  @override
  List<Object> get props => [message];
}