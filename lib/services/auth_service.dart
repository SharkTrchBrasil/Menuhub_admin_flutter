import 'dart:async';
import 'dart:io';
import 'package:either_dart/either.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/models/totem_auth.dart';
import 'package:totem_pro_admin/models/totem_auth_and_stores.dart';
import 'package:totem_pro_admin/models/user.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';

import '../core/di.dart';
class AuthService {
  final AuthRepository _authRepository;
  final StoreRepository _storeRepository;

  RealtimeRepository? _realtimeRepository;

  RealtimeRepository get realtimeRepository {
    if (_realtimeRepository == null) {
      throw Exception("RealtimeRepository não foi inicializado.");
    }
    return _realtimeRepository!;
  }

  AuthService({
    required AuthRepository authRepository,
    required StoreRepository storeRepository,
  })  : _authRepository = authRepository,
        _storeRepository = storeRepository;

  Future<Either<SignInError, TotemAuthAndStores>> initializeApp() async {
    print('[AuthService] Inicializando o aplicativo...');
    final isLoggedIn = await _authRepository.initialize();
    if (!isLoggedIn) {
      return const Left(SignInError.notLoggedIn);
    }
    return await _postAuthenticationSetup();
  }

  Future<Either<SignInError, TotemAuthAndStores>> signIn({
    required String email,
    required String password,
  }) async {
    print('[AuthService] Tentando login para: $email');
    final authResult = await _authRepository.signIn(email: email, password: password);
    return authResult.fold(
          (error) => Left(error),
          (_) async => await _postAuthenticationSetup(),
    );
  }

  // ✅ _fetchStoresAndUpdateState foi renomeado para _postAuthenticationSetup
  Future<Either<SignInError, TotemAuthAndStores>> _postAuthenticationSetup() async {
    final user = _authRepository.user;
    final accessToken = _authRepository.accessToken;
    if (user == null || accessToken == null) return const Left(SignInError.unknown);


    _realtimeRepository = getIt<RealtimeRepository>();
    await _realtimeRepository!.initialize(accessToken);




    final storesResult = await _storeRepository.getStores();
    return storesResult.fold(
          (error) => const Left(SignInError.unknown),
          (stores) => Right(
        TotemAuthAndStores(
          authTokens: _authRepository.authTokens!,
          user: user,
          stores: stores,
        ),
      ),
    );
  }


  Future<void> logout() async {
    print('[AuthService] Executando logout...');
      _realtimeRepository?.dispose();

    await _authRepository.logout();
    print('[AuthService] Logout completo.');
  }



  Future<Either<SignUpError, void>> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _authRepository.signUp(
        name: name,
        phone: phone,
        email: email,
        password: password,
      );

      return result.fold((error) => Left(error), (_) async {
        final emailResult = await _authRepository.sendCode(email: email);
        return emailResult.fold(
              (_) => Left(SignUpError.emailNotSent),
              (_) => const Right(null),
        );
      });
    } catch (e) {
      return Left(_handleSignUpError(e));
    }
  }

  // 👇 ADICIONE ESTE NOVO MÉTODO AQUI 👇
  Future<Either<CodeError, void>> verifyCode({
    required String email,
    required String code,
  }) {
    // O serviço simplesmente delega a chamada para o repositório correto.
    return _authRepository.verifyCode(email: email, code: code);
  }



  // --- Métodos de Cadastro (sem alterações) ---

  SignUpError _handleSignUpError(dynamic error) {
    if (error is SocketException || error is TimeoutException) {
      return SignUpError.networkError;
    }
    return SignUpError.unknown;
  }

}

