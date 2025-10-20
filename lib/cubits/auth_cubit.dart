// Em: lib/cubits/auth_cubit.dart

import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/services/auth_service.dart';
import '../core/di.dart';
import '../core/enums/auth_erros.dart';
import '../models/totem_auth_and_stores.dart';
import '../repositories/realtime_repository.dart';
import '../services/print/printing_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;
  StreamSubscription? _sessionRevokedSubscription;
  bool _hasInitialized = false; // ✅ Flag para evitar re-inicialização

  AuthCubit({
    required AuthService authService,
  })  : _authService = authService,
        super(AuthInitial()) {
    // ✅ Só inicializa se nunca foi inicializado
    if (!_hasInitialized) {
      _initializeApp();
    }
  }


  Future<void> _initializeApp() async {
    if (_hasInitialized) return; // ✅ Proteção dupla

    log('[AuthCubit] Iniciando app...');
    emit(AuthLoading());

    final result = await _authService.initializeApp();
    result.fold(
          (error) {
        log('[AuthCubit] Falha na inicialização do app: $error');
        // ✅ Só faz logout se NÃO for erro de "não logado"
        if (error != SignInError.notLoggedIn) {
          logout();
        } else {
          emit(AuthUnauthenticated());
        }
      },
          (data) async {
        log('[AuthCubit] App inicializado com sucesso...');
        _hasInitialized = true; // ✅ Marca como inicializado
        await _postAuthenticationSetup(data);
      },
    );
  }


  Future<void> signIn(String email, String password) async {
    log('[AuthCubit] Tentando login para $email...');
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
        log('[AuthCubit] Login bem-sucedido. Orquestrando setup pós-autenticação...');
        await _postAuthenticationSetup(data);
      },
    );
  }

  /// ✅ MÉTODO CENTRALIZADO: Garante a ordem correta das operações pós-login.
  Future<void> _postAuthenticationSetup(TotemAuthAndStores data) async {
    try {
      log('➡️ [AuthCubit] PASSO 1: Registrando singletons de escopo de usuário...');
      registerUserScopeSingletons();
      log('✅ [AuthCubit] PASSO 1: Concluído.');

      log('➡️ [AuthCubit] PASSO 2: Inicializando RealtimeRepository...');
      final accessToken = data.authTokens.accessToken;
      await getIt<RealtimeRepository>().initialize(accessToken);
      log('✅ [AuthCubit] PASSO 2: Concluído.');

      // ✅ NOVO: Configura listener para sessão revogada ANTES de carregar dados
      log('➡️ [AuthCubit] PASSO 2.5: Configurando listener de sessão revogada...');
      _listenToSessionRevoked();
      log('✅ [AuthCubit] PASSO 2.5: Concluído.');

      log('➡️ [AuthCubit] PASSO 3: Aguardando StoresManagerCubit.loadInitialData()...');
      await getIt<StoresManagerCubit>().loadInitialData();
      log('✅ [AuthCubit] PASSO 3: StoresManagerCubit.loadInitialData() finalizado.');

      log('➡️ [AuthCubit] PASSO 4: Inicializando PrintingService...');
      getIt<PrintingService>().initialize();
      log('✅ [AuthCubit] PASSO 4: Concluído.');

      log('➡️ [AuthCubit] PASSO 5: Emitindo estado AuthAuthenticated...');
      emit(AuthAuthenticated(data));
      log('✅ [AuthCubit] PASSO 5: Estado AuthAuthenticated emitido. Setup completo!');
    } catch (e, st) {
      log('[AuthCubit] Erro crítico durante o setup pós-autenticação: $e', error: e, stackTrace: st);
      await logout();
    }
  }

// ✅ ATUALIZADO: _listenToSessionRevoked agora chama logout com reason
  void _listenToSessionRevoked() {
    _sessionRevokedSubscription?.cancel();

    _sessionRevokedSubscription = getIt<RealtimeRepository>()
        .onSessionRevoked
        .listen((data) {
      if (isClosed) return;

      final reason = data['reason'] as String? ?? 'Sessão encerrada';
      final message = data['message'] as String? ??
          'Você foi desconectado. Outro dispositivo fez login nesta conta.';

      log('🚨 [AuthCubit] ========================================');
      log('🚨 [AuthCubit] SESSÃO REVOGADA POR OUTRO DISPOSITIVO!');
      log('🚨 [AuthCubit] Motivo: $reason');
      log('🚨 [AuthCubit] Mensagem: $message');
      log('🚨 [AuthCubit] Fazendo logout automático...');
      log('🚨 [AuthCubit] ========================================');

      // ✅ CORRIGIDO: Passa reason e message para o logout
      logout(reason: 'session_revoked', message: message);
    });

    log('✅ [AuthCubit] Listener de sessão revogada configurado.');
  }



// ✅ MÉTODO CORRIGIDO: Logout com reason
  Future<void> logout({String? reason, String? message}) async {
    log('[AuthCubit] Iniciando processo de logout... Reason: ${reason ?? 'manual'}');

    // Evita múltiplas chamadas
    if (state is AuthUnauthenticated) {
      log('[AuthCubit] Já está deslogado. Ignorando.');
      return;
    }

    // Mostra loading (exceto se vier de sessão revogada)
    if (reason != 'session_revoked') {
      emit(AuthLoading());
    }

    try {
      // 1. Cancela listener de sessão revogada PRIMEIRO
      log('[AuthCubit] Cancelando listener de sessão revogada...');
      _sessionRevokedSubscription?.cancel();
      _sessionRevokedSubscription = null;

      // 2. Limpa o estado do StoresManagerCubit
      if (getIt.isRegistered<StoresManagerCubit>()) {
        log('[AuthCubit] Resetando StoresManagerCubit...');
        await getIt<StoresManagerCubit>().resetState();
      }

      // 3. Desregistra serviços de escopo de usuário
      log('[AuthCubit] Desregistrando singletons de escopo de usuário...');
      await unregisterUserScopeSingletons();

      // 4. Faz reset do RealtimeRepository
      if (getIt.isRegistered<RealtimeRepository>()) {
        log('[AuthCubit] Fazendo reset do RealtimeRepository...');
        getIt<RealtimeRepository>().reset();
      }

      // 5. Chama o serviço de autenticação para limpar tokens
      log('[AuthCubit] Limpando tokens via AuthService...');
      await _authService.logout();

      // 6. ✅ CORRIGIDO: Emite o estado final COM reason e message
      emit(AuthUnauthenticated(
        reason: reason,
        message: message ?? _getLogoutMessage(reason),
      ));

      log('[AuthCubit] ✅ Logout completo. Reason: ${reason ?? 'manual'}');
    } catch (e, st) {
      log('[AuthCubit] ❌ Erro durante o logout: $e', error: e, stackTrace: st);
      // Mesmo em caso de erro, força o estado de deslogado
      emit(AuthUnauthenticated(reason: reason, message: message));
    }

  }

  // ✅ NOVO: Helper para gerar mensagens de logout
  String _getLogoutMessage(String? reason) {
    switch (reason) {
      case 'session_expired':
        return 'Sua sessão expirou após 7 dias de inatividade.';
      case 'session_revoked':
        return 'Você foi desconectado por outro dispositivo.';
      case 'token_refresh_failed':
        return 'Não foi possível renovar sua sessão. Faça login novamente.';
      case 'manual':
        return 'Logout realizado com sucesso.';
      default:
        return '';
    }
  }

  Future<void> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());
    final result = await _authService.signUp(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
    result.fold(
          (error) => emit(AuthSignUpError(error)),
          (_) => emit(AuthNeedsVerification(email: email, password: password)),
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
          (error) async => emit(currentState.copyWith(error: 'Código inválido')),
          (_) async {
        log('[AuthCubit] Código verificado. Tentando login automático...');
        await signIn(email, password);
      },
    );
  }

// No AuthCubit, adicione:
  String? getUserName() {
    final authState = state;
    if (authState is AuthAuthenticated) {
      return authState.data.user.name ?? authState.data.user?.email?.split('@').first;
    }
    return null;
  }


  @override
  Future<void> close() {
    log('[AuthCubit] Fechando AuthCubit permanentemente.');

    // ✅ NOVO: Cancela listener de sessão revogada ao fechar o cubit
    _sessionRevokedSubscription?.cancel();

    return super.close();
  }
}