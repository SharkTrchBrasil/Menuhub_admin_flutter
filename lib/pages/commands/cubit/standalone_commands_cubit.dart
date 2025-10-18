// lib/pages/commands/cubit/standalone_commands_cubit.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/tables/command.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:equatable/equatable.dart';

part 'standalone_commands_state.dart';

class StandaloneCommandsCubit extends Cubit<StandaloneCommandsState> {
  final RealtimeRepository _realtimeRepository;
  StreamSubscription? _commandsSubscription;

  StandaloneCommandsCubit({required RealtimeRepository realtimeRepository})
      : _realtimeRepository = realtimeRepository,
        super(StandaloneCommandsInitial());

  /// Conecta ao stream de comandas avulsas de uma loja
  void connectToStore(int storeId) {
    emit(StandaloneCommandsLoading());

    _commandsSubscription?.cancel();
    _commandsSubscription = _realtimeRepository
        .listenToStandaloneCommands(storeId)
        .listen(_handleCommandsUpdate);
  }

  void _handleCommandsUpdate(List<Command> commands) {
    emit(StandaloneCommandsLoaded(commands: commands));
  }

  @override
  Future<void> close() {
    _commandsSubscription?.cancel();
    return super.close();
  }
}