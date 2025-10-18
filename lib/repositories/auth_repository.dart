import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:totem_pro_admin/models/auth_tokens.dart';
import 'package:totem_pro_admin/models/user.dart';
import 'package:uuid/uuid.dart';

import '../models/totem_auth.dart';

enum SignInError {
  invalidCredentials, // Credenciais incorretas
  inactiveAccount, // Conta desativada
  emailNotVerified, // E-mail não verificado
  noStoresAvailable, // Nenhuma loja disponível (novo)
  notLoggedIn, // Usuário não está logado (novo)
  networkError, // Problema de conexão (novo)
  serverError, // Erro no servidor (novo)
  unauthorized, // Acesso não autorizado (novo)
  sessionExpired, // Sessão expirada (novo)
  unknown, // Erro desconhecido
}

enum SignUpError {
  userAlreadyExists, // Email já cadastrado
  invalidData, // Dados inválidos
  weakPassword, // Senha fraca
  networkError, // Problema de conexão
  emailNotSent, // Falha no envio do email de verificação
  unknown; // Erro desconhecido

  String get message {
    switch (this) {
      case SignUpError.userAlreadyExists:
        return 'user_already_exists'.tr();
      case SignUpError.invalidData:
        return 'invalid_data'.tr();
      case SignUpError.weakPassword:
        return 'weak_password'.tr();
      case SignUpError.networkError:
        return 'network_error'.tr();
      case SignUpError.emailNotSent:
        return 'verification_email_not_sent'.tr();
      case SignUpError.unknown:
        return 'failed_to_create_account'.tr();
    }
  }
}

enum StoreCreationError {
  creationFailed,
  connectionFailed,
  unknown;

  String get message {
    switch (this) {
      case StoreCreationError.creationFailed:
        return 'Falha ao criar a loja';
      case StoreCreationError.connectionFailed:
        return 'Falha ao conectar com a loja';
      case StoreCreationError.unknown:
        return 'Erro desconhecido';
    }
  }
}

enum CodeError { unknown, userNotFound, alreadyVerified, invalidCode }

enum ResendError { unknown, userNotFound, resendError }

class SecureStorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refreshToken';
  static const totemToken = 'totem_token';
}

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  // ✅ NOVO: Dio dedicado para chamadas de autenticação que não devem ser interceptadas.
  final Dio _authDio;

  AuthRepository(this._dio, this._secureStorage)
  // Inicializa o _authDio com a mesma base URL, mas sem interceptors.
      : _authDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));

  AuthTokens? _authTokens;
  AuthTokens? get authTokens => _authTokens;
  String? get accessToken => _authTokens?.accessToken;

  User? _user;
  User? get user => _user;

  bool _isRefreshing = false;
  bool get isRefreshingToken => _isRefreshing;

  Future<bool> initialize() async {
    log('[AuthRepository] Inicializando e tentando renovar sessão...');
    // Tenta carregar o refresh token do armazenamento seguro
    final refreshToken = await _secureStorage.read(key: SecureStorageKeys.refreshToken);
    if (refreshToken == null) {
      log('[AuthRepository] Nenhum refresh token encontrado. Usuário não está logado.');
      return false;
    }

    // Tenta obter um novo access token
    final refreshResult = await refreshAccessToken();
    if (refreshResult.isLeft) {
      log('[AuthRepository] Falha ao renovar token durante a inicialização. Limpando sessão.');
      await logout();
      return false;
    }

    // Se a renovação foi bem-sucedida, busca os dados do usuário.
    final userResult = await _getUserInfo();
    if (userResult.isLeft) {
      log('[AuthRepository] Token renovado, mas falha ao buscar dados do usuário. Limpando sessão.');
      await logout();
      return false;
    }

    log('[AuthRepository] Sessão inicializada com sucesso.');
    return true;
  }

  Future<Either<SignInError, void>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // ✅ Usa o _authDio para a chamada de login
      final response = await _authDio.post(
        '/auth/login',
        data: {'username': email, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final tokens = AuthTokens.fromJson(response.data);
      await _saveTokens(tokens);

      final result = await _getUserInfo();
      return result.fold(
            (_) => const Left(SignInError.unknown),
            (_) => const Right(null),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final responseData = e.response?.data as Map<String, dynamic>?;
        if (responseData?['detail'] == 'Email not verified') {
          return const Left(SignInError.emailNotVerified);
        }
        return const Left(SignInError.invalidCredentials);
      }
      return const Left(SignInError.unknown);
    }
  }

  Future<Either<String, void>> refreshAccessToken() async {
    if (_isRefreshing) {
      return const Left('Renovação de token já em andamento.');
    }
    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.read(key: SecureStorageKeys.refreshToken);
      if (refreshToken == null) {
        // Garante que a flag seja resetada antes de sair.
        _isRefreshing = false;
        return const Left('Nenhuma sessão para renovar.');
      }

      // ✅ Usa o _authDio para a chamada de refresh
      final response = await _authDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newTokens = AuthTokens.fromJson(response.data);
      await _saveTokens(newTokens);

      log('[AuthRepository] Token de acesso renovado com sucesso.');
      return const Right(null);
    } catch (e) {
      log('[AuthRepository] Falha ao renovar o token: $e');
      return Left('Falha ao renovar o token: ${e.toString()}');
    } finally {
      _isRefreshing = false;
    }
  }

  // ✅ NOVO: Método privado para salvar tokens, garantindo consistência.
  Future<void> _saveTokens(AuthTokens tokens) async {
    _authTokens = tokens;
    await _secureStorage.write(key: SecureStorageKeys.accessToken, value: tokens.accessToken);
    // IMPORTANTE: Salva o novo refresh token, caso o backend o rotacione.
    await _secureStorage.write(key: SecureStorageKeys.refreshToken, value: tokens.refreshToken);
  }

  Future<void> logout() async {
    log('[AuthRepository] Limpando tokens e dados de sessão.');
    _authTokens = null;
    _user = null;
    await _secureStorage.delete(key: SecureStorageKeys.accessToken);
    await _secureStorage.delete(key: SecureStorageKeys.refreshToken);
  }

  Future<Either<ResendError, void>> sendCode({required String email}) async {
    try {
      final response = await _authDio.post(
        '/verify-code/resend',
        data: {'email': email},
      );

      if (response.statusCode == 200) {
        return const Right(null);
      } else {
        return const Left(ResendError.resendError);
      }
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'];

      if (e.response?.statusCode == 404 &&
          detail == 'Usuário não encontrado.') {
        return const Left(ResendError.userNotFound);
      }

      if (e.response?.statusCode == 400 && detail == 'Email já verificado.') {
        return const Left(ResendError.resendError);
      }

      debugPrint('Erro: $e');
      return const Left(ResendError.unknown);
    }
  }

  Future<Either<CodeError, void>> verifyCode({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _authDio.post(
        '/verify-code',
        queryParameters: {'email': email, 'code': code},
      );

      if (response.statusCode == 200) {
        return const Right(null);
      }

      return const Left(CodeError.unknown);
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'];

      if (e.response?.statusCode == 404 &&
          detail == 'Usuário não encontrado.') {
        return const Left(CodeError.userNotFound);
      }

      if (e.response?.statusCode == 400) {
        if (detail == 'Código já validado.') {
          return const Left(CodeError.alreadyVerified);
        }
        if (detail == 'Código incorreto.') {
          return const Left(CodeError.invalidCode);
        }
      }

      debugPrint('$e');
      return const Left(CodeError.unknown);
    }
  }

  Future<Either<void, void>> _getUserInfo() async {
    try {
      // ✅ Esta chamada usa o _dio normal e será interceptada, o que é correto.
      final response = await _dio.get('/users/me');
      _user = User.fromJson(response.data);
      return const Right(null);
    } catch (e) {
      log('[AuthRepository] Falha ao obter informações do usuário: $e');
      return const Left(null);
    }
  }

  Future<Either<SignUpError, void>> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      // ✅ Usa _authDio para não enviar token de um usuário antigo, se houver.
      await _authDio.post(
        '/users',
        data: {'email': email, 'phone': phone, 'name': name, 'password': password},
      );
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data?['detail'] == 'User already exists') {
        return const Left(SignUpError.userAlreadyExists);
      }
      debugPrint('$e');
      return const Left(SignUpError.unknown);
    }
  }
}