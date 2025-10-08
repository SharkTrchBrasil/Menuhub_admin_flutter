import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';

import 'package:totem_pro_admin/models/store/store_with_role.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/services/auth_service.dart';
import '../core/di.dart';
import '../repositories/realtime_repository.dart';
import '../services/print/printing_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit({
    required AuthService authService,
  })  : _authService = authService,
        super(AuthInitial()) {
    _initializeApp();
  }


  Future<void> _initializeApp() async {
    print('[AuthCubit] Initializing app...');
    if (state is! AuthLoading) {
      emit(AuthLoading());
    }

    final result = await _authService.initializeApp();
    result.fold(
          (error) {
        print('[AuthCubit] App initialization failed: $error');
        // ✅ REFINAMENTO: Em qualquer erro de inicialização, garantimos o logout
        // e a transição para o estado não autenticado.
        if (error == SignInError.notLoggedIn) {
          print('[AuthCubit] Token inválido ou ausente. Forçando logout para limpeza.');
          unawaited(logout()); // O logout emitirá AuthUnauthenticated
        } else {
          // Para outros erros, também consideramos o usuário como não autenticado.
          emit(AuthUnauthenticated());
        }
      },
          (data) async {
        print('[AuthCubit] App initialized. Setting up user scope...');

        registerUserScopeSingletons();

        // ✅ CORREÇÃO: PRIMEIRO inicializa o RealtimeRepository
        final accessToken = data.authTokens.accessToken;
        await getIt<RealtimeRepository>().initialize(accessToken);

        // ✅ AGORA emite o estado autenticado
        emit(AuthAuthenticated(data));

        // ✅ FINALMENTE carrega os dados das lojas
        print('[AuthCubit] Inicializando serviços pós-autenticação...');
        await getIt<StoresManagerCubit>().loadInitialData();
        getIt<PrintingService>().initialize();
      },
    );
  }



  Future<void> signIn(String email, String password) async {
    print('[AuthCubit] Attempting sign-in for $email...');
    emit(AuthLoading());
    final result = await _authService.signIn(email: email, password: password);
    result.fold(
          (error) {
        if (error == SignInError.emailNotVerified) {
          emit(AuthNeedsVerification(email: email, password: password));
        } else {
          emit(AuthError(error));
        }
      },
          (data) async {
        print('[AuthCubit] Sign-in successful. Setting up user scope...');


        registerUserScopeSingletons();

        // 2. Inicializa o serviço de tempo real com o token
        final accessToken = data.authTokens.accessToken;
        await getIt<RealtimeRepository>().initialize(accessToken);

        // 3. Emite o estado de autenticado para o app reagir
        emit(AuthAuthenticated(data));

        // 4. Carrega os dados das lojas e inicializa outros serviços
        await getIt<StoresManagerCubit>().loadInitialData();
        getIt<PrintingService>().initialize();
      },
    );
  }

  // ♻️ REFACTOR: Método de logout completo e robusto
  Future<void> logout() async {
    log('[AuthCubit] Iniciando processo de logout robusto...');

    if (state is AuthUnauthenticated || state is AuthInitial) {
      log('[AuthCubit] Já está deslogado. Abortando.');
      return;
    }

    emit(AuthLoading());

    try {
      await unregisterUserScopeSingletons();
      await _authService.logout();
      emit(AuthUnauthenticated());
      log('[AuthCubit] Logout completo. O estado agora é AuthUnauthenticated.');
    } catch (e, st) {
      log('[AuthCubit] Erro crítico durante logout: $e', error: e, stackTrace: st);
      emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    log('[AuthCubit] Fechando AuthCubit...');
    return super.close();
  }

  Future<void> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    print('[AuthCubit] Attempting sign-up for $email...');
    emit(AuthLoading());
    final result = await _authService.signUp(name: name, phone: phone, email: email, password: password);
    result.fold(
          (error) {
        print('[AuthCubit] Sign-up failed: $error');
        emit(AuthSignUpError(error));
      },
          (_) {
        print('[AuthCubit] Sign-up successful. Emitting AuthNeedsVerification.');
        emit(AuthNeedsVerification(email: email, password: password));
      },
    );
  }

  Future<void> verifyCodeAndLogin({required String code}) async {
    final currentState = state;
    if (currentState is! AuthNeedsVerification) return;

    emit(AuthLoading());
    final email = currentState.email;
    final password = currentState.password;
    final verifyResult = await _authService.verifyCode(email: email, code: code);

    await verifyResult.fold(
          (error) async {
        emit(currentState.copyWith(error: 'Código inválido'));
      },
          (_) async {
        print('[AuthCubit] Código verificado. Tentando login automático...');
        await signIn(email, password);
      },
    );
  }
}