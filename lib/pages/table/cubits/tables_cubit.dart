// lib/cubits/tables/tables_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/tables/saloon.dart';
import 'package:totem_pro_admin/models/tables/table.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:equatable/equatable.dart';

part 'tables_state.dart';

class TablesCubit extends Cubit<TablesState> {
  final RealtimeRepository _realtimeRepository;
  StreamSubscription? _saloonsSubscription;

  TablesCubit({required RealtimeRepository realtimeRepository})
      : _realtimeRepository = realtimeRepository,
        super(TablesInitial());

  /// Conecta ao stream de salões de uma loja
  void connectToStore(int storeId) {
    emit(TablesLoading());

    _saloonsSubscription?.cancel();
    _saloonsSubscription = _realtimeRepository
        .listenToSaloons(storeId)
        .listen(_handleSaloonsUpdate);
  }

  void _handleSaloonsUpdate(List<Saloon> saloons) {
    if (saloons.isEmpty && state is! TablesLoaded) {
      // Primeira carga ainda vazia
      emit(TablesLoaded(saloons: [], selectedTable: null));
      return;
    }

    final currentSelectedTable = state is TablesLoaded
        ? (state as TablesLoaded).selectedTable
        : null;

    // Atualiza a mesa selecionada se ela foi modificada
    TableModel? updatedSelectedTable;
    if (currentSelectedTable != null) {
      for (final saloon in saloons) {
        final foundTable = saloon.tables.firstWhere(
              (t) => t.id == currentSelectedTable.id,
          orElse: () => currentSelectedTable,
        );
        if (foundTable.id == currentSelectedTable.id) {
          updatedSelectedTable = foundTable;
          break;
        }
      }
    }

    emit(TablesLoaded(
      saloons: saloons,
      selectedTable: updatedSelectedTable,
    ));
  }

  /// Seleciona uma mesa
  void selectTable(TableModel table) {
    if (state is TablesLoaded) {
      emit((state as TablesLoaded).copyWith(selectedTable: table));
    }
  }

  /// Limpa a seleção
  void clearSelection() {
    if (state is TablesLoaded) {
      emit((state as TablesLoaded).copyWith(selectedTable: null));
    }
  }

  @override
  Future<void> close() {
    _saloonsSubscription?.cancel();
    return super.close();
  }
}