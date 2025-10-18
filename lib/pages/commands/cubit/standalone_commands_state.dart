// lib/pages/commands/cubit/standalone_commands_state.dart
part of 'standalone_commands_cubit.dart';

abstract class StandaloneCommandsState extends Equatable {
  const StandaloneCommandsState();

  @override
  List<Object?> get props => [];
}

class StandaloneCommandsInitial extends StandaloneCommandsState {}

class StandaloneCommandsLoading extends StandaloneCommandsState {}

class StandaloneCommandsLoaded extends StandaloneCommandsState {
  final List<Command> commands;

  const StandaloneCommandsLoaded({required this.commands});

  @override
  List<Object> get props => [commands];

  StandaloneCommandsLoaded copyWith({List<Command>? commands}) {
    return StandaloneCommandsLoaded(
      commands: commands ?? this.commands,
    );
  }

  // ✅ HELPERS ÚTEIS
  int get totalCommands => commands.length;

  int get commandsWithTable => commands.where((c) => c.tableId != null).length;

  int get commandsWithoutTable => commands.where((c) => c.tableId == null).length;
}

class StandaloneCommandsError extends StandaloneCommandsState {
  final String message;

  const StandaloneCommandsError(this.message);

  @override
  List<Object> get props => [message];
}