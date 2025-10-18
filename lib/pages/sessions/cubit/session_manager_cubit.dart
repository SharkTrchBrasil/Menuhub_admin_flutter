import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../models/active_session.dart';
import '../../../repositories/session_manager_repository.dart';

// States
abstract class SessionManagerState extends Equatable {
  const SessionManagerState();

  @override
  List<Object?> get props => [];
}

class SessionManagerInitial extends SessionManagerState {}

class SessionManagerLoading extends SessionManagerState {}

class SessionManagerLoaded extends SessionManagerState {
  final List<ActiveSession> sessions;

  const SessionManagerLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class SessionManagerError extends SessionManagerState {
  final String message;

  const SessionManagerError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class SessionManagerCubit extends Cubit<SessionManagerState> {
  final SessionManagerRepository _repository;

  SessionManagerCubit({required SessionManagerRepository repository})
      : _repository = repository,
        super(SessionManagerInitial());

  Future<void> loadActiveSessions() async {
    emit(SessionManagerLoading());

    final result = await _repository.getActiveSessions();

    result.fold(
          (error) => emit(SessionManagerError(error)),
          (sessions) => emit(SessionManagerLoaded(sessions)),
    );
  }

  Future<bool> revokeSession(int sessionId) async {
    final result = await _repository.revokeSession(sessionId);

    return result.fold(
          (error) {
        emit(SessionManagerError(error));
        return false;
      },
          (_) {
        loadActiveSessions(); // Recarrega a lista
        return true;
      },
    );
  }

  Future<bool> revokeAllOtherSessions(String currentSid) async {
    final result = await _repository.revokeAllOtherSessions(currentSid);

    return result.fold(
          (error) {
        emit(SessionManagerError(error));
        return false;
      },
          (_) {
        loadActiveSessions(); // Recarrega a lista
        return true;
      },
    );
  }
}