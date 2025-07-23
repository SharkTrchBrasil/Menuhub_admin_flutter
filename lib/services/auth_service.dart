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

  // TODO: The 'accessToken' getter is missing from your AuthRepository.
  // This line is commented out to fix the compile error. You will need to
  // expose the access token from your AuthRepository for other parts of the
  // app (like RealtimeRepository) to work correctly.
  // String? get accessToken => _authRepository.accessToken;

  /// **REFACTORED:** This method was rewritten to avoid nested .fold() calls,
  /// which improves readability and resolves potential type errors.
  Future<Either<SignInError, TotemAuthAndStores>> signIn({
    required String email,
    required String password,
  }) async {
    print('[AuthService] Tentando login para: $email');
    final authResult = await _authRepository.signIn(email: email, password: password);

    if (authResult.isLeft) {
      print('[AuthService] Erro no login: ${authResult.left}');
      return Left(authResult.left);
    }

    print('[AuthService] Login bem-sucedido. Buscando lojas...');
    final storesResult = await _storeRepository.getStores();

    if (storesResult.isLeft) {
      print('[AuthService] Erro ao carregar lojas após login: ${storesResult.toString()}');
      return Left(SignInError.unknown);
    }

    final stores = storesResult.right;
    if (stores.isEmpty) {
      print('[AuthService] Nenhuma loja disponível para o usuário após login.');
      return Left(SignInError.noStoresAvailable);
    }
    print('[AuthService] Lojas carregadas: ${stores.map((s) => s.store.name).join(', ')}');

    // Conecta ao socket da primeira loja como padrão
    final connectResult = await _connectToSocket(stores.first.store.store_url!);
    if (connectResult.isLeft) {
      print('[AuthService] Erro ao conectar ao socket após login: ${connectResult.left}');
      return Left(connectResult.left);
    }

    return Right(TotemAuthAndStores(totemAuth: connectResult.right, stores: stores));
  }

  /// **REFACTORED:** This method was also rewritten for clarity and correctness.
  Future<Either<SignInError, TotemAuthAndStores>> initializeApp() async {
    print('[AuthService] Inicializando o aplicativo...');
    final isLoggedIn = await _authRepository.initialize();

    if (!isLoggedIn) {
      print('[AuthService] Usuário não logado.');
      return Left(SignInError.notLoggedIn);
    }

    print('[AuthService] Usuário autenticado. Buscando lojas...');
    final storesResult = await _storeRepository.getStores();

    if (storesResult.isLeft) {
      print('[AuthService] Erro ao carregar lojas na inicialização do app: ${storesResult}');
      return Left(SignInError.unknown);
    }

    final stores = storesResult.right;
    if (stores.isEmpty) {
      print('[AuthService] Nenhuma loja disponível para o usuário na inicialização do app.');
      return Left(SignInError.noStoresAvailable);
    }
    print('[AuthService] Lojas carregadas na inicialização: ${stores.map((s) => s.store.name).join(', ')}');

    final connectionResult = await _connectToSocket(stores.first.store.store_url!);

    if (connectionResult.isLeft) {
      print('[AuthService] Erro ao conectar ao socket na inicialização: ${connectionResult.left}');
      return Left(connectionResult.left);
    }

    return Right(TotemAuthAndStores(totemAuth: connectionResult.right, stores: stores));
  }

  /// Método privado para obter o token de sessão do socket e inicializar o RealtimeRepository.
  Future<Either<SignInError, TotemAuth>> _connectToSocket(String storeUrl) async {
    final tokenResult = await _authRepository.getToken(storeUrl);

    return tokenResult.fold(
          (error) {
        print('[AuthService] Erro ao obter token para $storeUrl: {error}');
        return Left(SignInError.invalidCredentials);
      },
          (totemAuth) {
        if (!totemAuth.granted) {
          print('[AuthService] Erro: Acesso não concedido para $storeUrl');
          return Left(SignInError.invalidCredentials);
        }

        print('[AuthService] Token recebido para $storeUrl. SID: ${totemAuth.sid}');
        _registerAuthSingleton(totemAuth);

        // Agora passamos o objeto 'totemAuth' completo para o RealtimeRepository.
        _realtimeRepository.initialize(totemAuth);

        return Right(totemAuth);
      },
    );
  }

  void _registerAuthSingleton(TotemAuth auth) {
    if (GetIt.I.isRegistered<TotemAuth>()) {
      GetIt.I.unregister<TotemAuth>();
    }
    GetIt.I.registerSingleton<TotemAuth>(auth);
    print('[AuthService] TotemAuth registrado no GetIt.');
  }

  Future<void> logout() async {
    print('[AuthService] Executando logout...');

    // TODO: The 'logout' method is missing from your AuthRepository.
    // This line is commented out to fix the compile error. You will need to
    // implement a logout method in your repository to clear persistent tokens.
    // await _authRepository.logout();

    _realtimeRepository.dispose(); // O dispose do repo cuida de fechar o socket e os streams.
    print('[AuthService] RealtimeRepository disposed.');

    if (GetIt.I.isRegistered<TotemAuth>()) {
      GetIt.I.unregister<TotemAuth>();
      print('[AuthService] TotemAuth removido do GetIt.');
    }
    print('[AuthService] Logout completo.');
  }

  // --- Métodos de Cadastro (sem alterações) ---

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

  SignUpError _handleSignUpError(dynamic error) {
    if (error is SocketException || error is TimeoutException) {
      return SignUpError.networkError;
    }
    return SignUpError.unknown;
  }
}
