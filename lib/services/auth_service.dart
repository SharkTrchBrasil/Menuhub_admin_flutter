// =======================================================================
// ARQUIVO 1: services/auth_service.dart (Refatorado e Limpo)
// =======================================================================
import 'dart:async';
import 'dart:io';

import 'package:either_dart/either.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/models/totem_auth.dart';
import 'package:totem_pro_admin/models/totem_auth_and_stores.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';

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




  Future<Either<SignInError, TotemAuthAndStores>> signIn({
    required String email,
    required String password,
  }) async {
    print('[AuthService] Tentando login para: $email');

    // 1. Autentica via /auth/login e salva o JWT (JSON Web Token).
    final authResult = await _authRepository.signIn(email: email, password: password);
    if (authResult.isLeft) {
      return Left(authResult.left);
    }




    // ✅ MUDANÇA 1: Pega o usuário que o repositório acabou de buscar.
    final user = _authRepository.user;
    if (user == null) {
      // Isso não deve acontecer se o login foi bem-sucedido.
      return Left(SignInError.unknown);
    }
    // 2. Busca as lojas associadas ao usuário.
    final storesResult = await _storeRepository.getStores();
    if (storesResult.isLeft) {
      return Left(SignInError.unknown);
    }
    final stores = storesResult.right;




    // if (stores.isEmpty) {
    //   return Left(SignInError.noStoresAvailable);
    // }




    // 3. Pega o JWT que foi salvo e inicializa a conexão do WebSocket.
    final jwt = _authRepository.accessToken;
    if (jwt == null) {
      return Left(SignInError.unknown); // Não deveria acontecer
    }
    await _realtimeRepository.initialize(jwt);

    // ✅ MUDANÇA 2: Retorna o objeto completo, agora incluindo o usuário.
    return Right(TotemAuthAndStores(
      totemAuth: TotemAuth.dummy(),
      stores: stores,
      user: user, // <--- DADOS DO USUÁRIO INCLUÍDOS!
    ));

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

      return result.fold(
            (error) => Left(error),
            (_) async {
          final emailResult = await _authRepository.sendCode(email: email);
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



// 👇 ADICIONE ESTE NOVO MÉTODO AQUI 👇
  Future<Either<CodeError, void>> verifyCode({
    required String email,
    required String code,
  }) {
    // O serviço simplesmente delega a chamada para o repositório correto.
    return _authRepository.verifyCode(email: email, code: code);
  }


  Future<Either<SignInError, TotemAuthAndStores>> initializeApp() async {
    print('[AuthService] Inicializando o aplicativo...');

    // 1. Verifica se há um JWT salvo e o valida.
    final isLoggedIn = await _authRepository.initialize();
    if (!isLoggedIn) {
      return Left(SignInError.notLoggedIn);
    }


    // ✅ MUDANÇA 3: Pega o usuário que foi carregado durante a inicialização.
    final user = _authRepository.user;
    if (user == null) {
      return Left(SignInError.unknown);
    }


    // 2. Busca as lojas.
    final storesResult = await _storeRepository.getStores();
    if (storesResult.isLeft) {
      return Left(SignInError.unknown);
    }
    final stores = storesResult.right;

    // if (stores.isEmpty) {
    //   return Left(SignInError.noStoresAvailable);
    // }

    // 3. Pega o JWT salvo e inicializa o socket.
    final jwt = _authRepository.accessToken!;
    await _realtimeRepository.initialize(jwt);

    // ✅ MUDANÇA 4: Retorna o objeto completo na inicialização também.
    return Right(TotemAuthAndStores(
      totemAuth: TotemAuth.dummy(),
      stores: stores,
      user: user, // <--- DADOS DO USUÁRIO INCLUÍDOS!
    ));

  }

  /// ✅ CORREÇÃO: O método de logout agora chama o método correto do repositório.
  Future<void> logout() async {
    print('[AuthService] Executando logout...');
    await _authRepository.logout();
    _realtimeRepository.dispose();
    if (GetIt.I.isRegistered<TotemAuth>()) {
      GetIt.I.unregister<TotemAuth>();
    }
    print('[AuthService] Logout completo.');
  }

  // --- Métodos de Cadastro (sem alterações) ---




  SignUpError _handleSignUpError(dynamic error) {
    if (error is SocketException || error is TimeoutException) {
      return SignUpError.networkError;
    }
    return SignUpError.unknown;
  }
}
