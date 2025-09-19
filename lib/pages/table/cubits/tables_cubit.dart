import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart'; // 👈 Importe o repositório
import 'tables_state.dart';
import 'dart:async'; // Para StreamSubscription

class TablesCubit extends Cubit<TablesState> {
  // ✅ PASSO 1: Declare o repositório e a inscrição
  final RealtimeRepository _realtimeRepository;
  StreamSubscription? _tablesSubscription;
  StreamSubscription? _commandsSubscription;

  // ✅ PASSO 2: Exija o repositório no construtor
  TablesCubit({required RealtimeRepository realtimeRepository})
      : _realtimeRepository = realtimeRepository,
        super(TablesInitial());

  // Você precisará de um método para iniciar a escuta,
  // que será chamado a partir da UI
  void listenToTables(int storeId) {
    _tablesSubscription?.cancel();
    _tablesSubscription = _realtimeRepository.listenToTables(storeId).listen((tables) {
      // Aqui você pode combinar com as comandas se quiser, ou apenas emitir as mesas
      // Por enquanto, vamos apenas emitir as mesas para a UI
      // TODO: Crie seu modelo `TableDetails` que combina mesas e comandas
      // emit(TablesLoaded(tables));
    });

    // Opcional: ouvir comandas também
    _commandsSubscription?.cancel();
    _commandsSubscription = _realtimeRepository.listenToCommands(storeId).listen((commands) {
      // Lógica para combinar com as mesas
    });
  }

  // ✅ PASSO 3: Lembre-se de limpar as inscrições ao fechar o cubit
  @override
  Future<void> close() {
    _tablesSubscription?.cancel();
    _commandsSubscription?.cancel();
    return super.close();
  }
}