import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart'; // Import the repository
import '../../../models/tables/table.dart';
import 'tables_state.dart';
import 'dart:async'; // For StreamSubscription


class TablesCubit extends Cubit<TablesState> {
  // Declare the repository and subscription
  final RealtimeRepository _realtimeRepository;
  StreamSubscription? _saloonsSubscription;

  // Require the repository in the constructor
  TablesCubit({required RealtimeRepository realtimeRepository})
      : _realtimeRepository = realtimeRepository,
        super(TablesInitial());

  // Method to start listening, called from the UI
  void listenToSaloons(int storeId) {
    _saloonsSubscription?.cancel();
    _saloonsSubscription = _realtimeRepository.listenToSaloons(storeId).listen((saloons) {
      // Flatten all tables from saloons into a Map<int, TableModel>
      final Map<int, TableModel> allTables = {};
      for (final saloon in saloons) {
        for (final table in saloon.tables) {
          allTables[table.id] = table;
        }
      }
      emit(TablesLoaded(allTables));
    });
  }

  // Clean up subscriptions when closing the cubit
  @override
  Future<void> close() {
    _saloonsSubscription?.cancel();
    return super.close();
  }
}