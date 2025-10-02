import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';

import 'package:totem_pro_admin/models/store/store_with_role.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/services/auth_service.dart';
import '../core/di.dart';
import '../services/print/printing_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  final StoresManagerCubit _storesManagerCubit;

  AuthCubit({
    required AuthService authService,
    required StoresManagerCubit storesManagerCubit,
  })  : _authService = authService,
        _storesManagerCubit = storesManagerCubit,
        super( AuthInitial()) {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print('[AuthCubit] Initializing app...');
    if (state is! AuthLoading) {
      emit( AuthLoading());
    }
    final result = await _authService.initializeApp();
    result.fold(
          (error) {
        print('[AuthCubit] App initialization failed: $error');
        if (error == SignInError.notLoggedIn) {
          print('[AuthCubit] Token inválido detectado. Forçando logout para limpeza.');
          unawaited(logout());
        } else {
          emit( AuthUnauthenticated());
        }
      },
          (data) async {
        print('[AuthCubit] App initialized. Emitting AuthAuthenticated.');
        emit(AuthAuthenticated(data));

        // ✅ INICIA O SERVIÇO DE IMPRESSÃO AQUI
        print('[AuthCubit] Inicializando serviços pós-autenticação...');
        await _storesManagerCubit.loadInitialData();
        getIt<PrintingService>().initialize();
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    print('[AuthCubit] Attempting sign-in for $email...');
    emit( AuthLoading());
    final result = await _authService.signIn(email: email, password: password);
    result.fold(
          (error) {
        if (error == SignInError.emailNotVerified) {
          emit(AuthNeedsVerification(email: email, password: password));
        } else {
          emit(AuthError(error));
        }
      },
          (data) {
        emit(AuthAuthenticated(data));

        _storesManagerCubit.loadInitialData();
          },
    );
  }

  Future<void> logout() async {
    print('[AuthCubit] Logging out...');
    if (state is! AuthLoading) {
      emit( AuthLoading());
    }
    await _authService.logout();
    print('[AuthCubit] Logout complete.');
    _storesManagerCubit.resetState();
    emit( AuthUnauthenticated());
  }

  Future<void> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    print('[AuthCubit] Attempting sign-up for $email...');
    emit( AuthLoading());
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

    emit( AuthLoading());
    final email = currentState.email;
    final password = currentState.password;
    final verifyResult = await _authService.verifyCode(email: email, code: code);

    await verifyResult.fold(
          (error) async {
        // Você pode adicionar uma mensagem de erro ao estado se quiser
        emit(currentState.copyWith(error: 'Código inválido'));
      },
          (_) async {
        print('[AuthCubit] Código verificado. Tentando login automático...');
        await signIn(email, password);
      },
    );
  }


  @override
  Future<void> close() {
    print('[AuthCubit] AuthCubit closed.');
    return super.close();
  }
}