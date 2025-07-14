import 'dart:async';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

import '../core/di.dart';
import '../cubits/store_manager_cubit.dart';
import '../models/store.dart';
import '../models/store_with_role.dart';
import '../models/totem_auth.dart';
import '../repositories/auth_repository.dart';
import '../repositories/store_repository.dart';


import 'package:get_it/get_it.dart';
import '../models/totem_auth.dart';
import '../repositories/auth_repository.dart';
import '../repositories/realtime_repository.dart';
import '../repositories/store_repository.dart';

class AuthService {
  final AuthRepository _authRepository;
  final StoreRepository _storeRepository;
  final RealtimeRepository _realtimeRepository;

  AuthService({
    AuthRepository? authRepository,
    StoreRepository? storeRepository,
    RealtimeRepository? realtimeRepository,
  })  : _authRepository = authRepository ?? GetIt.I<AuthRepository>(),
        _storeRepository = storeRepository ?? GetIt.I<StoreRepository>(),
        _realtimeRepository = realtimeRepository ?? GetIt.I<RealtimeRepository>();

  // 1. Autenticação principal
  Future<Either<SignInError, TotemAuth>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _authRepository.signIn(email: email, password: password);
    return result.fold(
          (error) => Left(error),
          (_) async {
        final storesResult = await _storeRepository.getStores();
        return storesResult.fold(
              (_) => Left(SignInError.unknown),
              (stores) async {
            if (stores.isEmpty) return Left(SignInError.noStoresAvailable);
            return await _connectToSocket(stores.first.store.store_url!);
          },
        );
      },
    );
  }

  Future<Either<SignInError, TotemAuth>> initializeApp() async {
    // 1. Verifica autenticação
    final isLoggedIn = await _authRepository.initialize();
    getIt.registerSingleton<bool>(true, instanceName: 'isInitialized');

    if (!isLoggedIn) return Left(SignInError.notLoggedIn);

    // 2. Busca as lojas do usuário
    final storesResult = await _storeRepository.getStores();

    return await storesResult.fold(
          (_) => Left(SignInError.unknown),
          (stores) async {
        if (stores.isEmpty) return Left(SignInError.noStoresAvailable);

        // 3. Conecta ao socket da primeira loja
        final connectionResult = await _connectToSocket(stores.first.store.store_url!);

        if (connectionResult.isLeft) return Left(connectionResult.left);

        // 4. INICIALIZA o StoresManagerCubit com as lojas
      //  getIt<StoresManagerCubit>().initialize(); // 👈 ESSENCIAL

        return Right(connectionResult.right);
      },
    );
  }



  Future<Either<SignUpError, void>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authRepository.signUp(
        name: name,
        email: email,
        password: password,
      );

      return result.fold(
            (error) => Left(error),
            (_) async {
          // Opcional: Enviar email de verificação
          final emailResult = await _authRepository.sendCode( email:email);
          return emailResult.fold(
                (_) => Left(SignUpError.emailNotSent),
                (_) => const Right(null),
          );
        },
      );
    } catch (e) {
      return Left(_handleSignUpError(e));
    }
  }

  SignUpError _handleSignUpError(dynamic error) {
    if (error is SocketException || error is TimeoutException) {
      return SignUpError.networkError;
    }
    // Adicione outros tratamentos específicos aqui
    return SignUpError.unknown;
  }









  // 3. Conexão com Socket (método privado reutilizável)
  Future<Either<SignInError, TotemAuth>> _connectToSocket(String storeUrl) async {
    final tokenResult = await _authRepository.getToken(storeUrl);

    if (tokenResult.isLeft || !tokenResult.right.granted) {
      return Left(SignInError.invalidCredentials);
    }

    final auth = tokenResult.right;
    _registerAuthSingleton(auth);
    _initializeSocket(auth.token);

    return Right(auth);
  }

  // 4. Inicialização do Socket
  void _initializeSocket(String token) {
    _realtimeRepository.initialize(token);
  }

  // 5. Gerenciamento da instância de autenticação
  void _registerAuthSingleton(TotemAuth auth) {
    if (GetIt.I.isRegistered<TotemAuth>()) {
      GetIt.I.unregister<TotemAuth>();
    }
    GetIt.I.registerSingleton<TotemAuth>(auth);
  }

  // 6. Logout
  Future<void> logout() async {

   // await _authRepository.logout();
  //  _realtimeRepository.disconnect();
    if (GetIt.I.isRegistered<TotemAuth>()) {
      GetIt.I.unregister<TotemAuth>();
    }
  }
}