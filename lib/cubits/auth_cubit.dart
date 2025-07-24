import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/services/auth_service.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';

// CORREÇÃO: Importando o modelo para ter acesso a 'TotemAuthAndStores'.
// O caminho pode precisar de ajuste.
import 'package:totem_pro_admin/models/totem_auth_and_stores.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  final RealtimeRepository _realtimeRepository;

  AuthCubit({
    required AuthService authService,
    required RealtimeRepository realtimeRepository,
  })  : _authService = authService,
        _realtimeRepository = realtimeRepository,
        super(AuthInitial()) {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print('[AuthCubit] Initializing app...');
    if (state is! AuthLoading) {
      emit(AuthLoading());
    }

    final result = await _authService.initializeApp();

    await result.fold(
          (error) {
        print('[AuthCubit] App initialization failed: $error');
        emit(AuthUnauthenticated());
      },
          (data) async {
        print('[AuthCubit] App initialized. User authenticated. Initializing RealtimeRepository.');
        await _realtimeRepository.initialize(data.totemAuth);
        print('[AuthCubit] RealtimeRepository initialized. Emitting AuthAuthenticated.');

        // CORREÇÃO: Passando os dados de autenticação e lojas para o estado.
        // Agora, o listener do GoRouter terá acesso imediato à lista de lojas.
        emit(AuthAuthenticated(data));
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    print('[AuthCubit] Attempting sign-in for $email...');
    emit(AuthLoading());

    final result = await _authService.signIn(email: email, password: password);

    await result.fold(
          (error) {
        print('[AuthCubit] Sign-in failed: $error');
        emit(AuthError(error));
      },
          (data) async {
        print('[AuthCubit] Sign-in successful for $email. Initializing RealtimeRepository.');
        await _realtimeRepository.initialize(data.totemAuth);
        print('[AuthCubit] RealtimeRepository initialized. Emitting AuthAuthenticated.');

        // CORREÇÃO: Passando os dados de autenticação e lojas para o estado.
        emit(AuthAuthenticated(data));
      },
    );
  }

  Future<void> logout() async {
    print('[AuthCubit] Logging out...');
    emit(AuthLoading());

    _realtimeRepository.dispose();
    await _authService.logout();

    print('[AuthCubit] Logout complete. RealtimeRepository disposed.');
    emit(AuthUnauthenticated());
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    print('[AuthCubit] Attempting sign-up for $email...');
    emit(AuthLoading());
    final result = await _authService.signUp(name: name, email: email, password: password);
    result.fold(
          (error) {
        print('[AuthCubit] Sign-up failed: $error');
        // CORREÇÃO: Usando o estado correto para erro de cadastro (SignUpError)
        // e evitando o cast incorreto para SignInError.
        emit(AuthSignUpError(error));
      },
          (_) {
        print('[AuthCubit] Sign-up successful. Emitting AuthUnauthenticated for login/verification.');
        emit(AuthUnauthenticated());
      },
    );
  }

  @override
  Future<void> close() {
    print('[AuthCubit] AuthCubit closed.');
    return super.close();
  }
}
