import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:totem_pro_admin/models/auth_tokens.dart';
import 'package:totem_pro_admin/models/user.dart';

import '../core/enums/auth_erros.dart';
import '../models/totem_auth.dart';


class SecureStorageKeys {
  static const accessToken = 'access_token';
  static const refreshToken = 'refresh_token'; // ✅ CORRIGIDO: era 'refreshToken'
  static const totemToken = 'totem_token';
}

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Dio _authDio;

  AuthRepository(this._dio, this._secureStorage)
      : _authDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));

  // ✅ Cache em memória dos tokens
  AuthTokens? _authTokens;
  AuthTokens? get authTokens => _authTokens;

  // ✅ CORRIGIDO: Getter que retorna token em memória ou do storage
  String? get accessToken => _authTokens?.accessToken;

  User? _user;
  User? get user => _user;

  bool _isRefreshing = false;
  bool get isRefreshingToken => _isRefreshing;

  // ✅ NOVO: Completer para fila de requisições durante refresh
  Future<Either<String, void>>? _refreshFuture;

  Future<bool> initialize() async {
    log('[AuthRepository] Inicializando e tentando renovar sessão...');

    // ✅ Tenta carregar tokens do storage
    final savedAccessToken = await _secureStorage.read(key: SecureStorageKeys.accessToken);
    final savedRefreshToken = await _secureStorage.read(key: SecureStorageKeys.refreshToken);

    if (savedRefreshToken == null || savedAccessToken == null) {
      log('[AuthRepository] Nenhum token encontrado. Usuário não está logado.');
      return false;
    }

    // ✅ NOVO: Carrega tokens na memória ANTES de renovar
    _authTokens = AuthTokens(
      accessToken: savedAccessToken,
      refreshToken: savedRefreshToken,
    );

    // Tenta renovar o access token
    final refreshResult = await refreshAccessToken();
    if (refreshResult.isLeft) {
      log('[AuthRepository] Falha ao renovar token. Limpando sessão.');
      await logout();
      return false;
    }

    // Se renovação OK, busca dados do usuário
    final userResult = await _getUserInfo();
    if (userResult.isLeft) {
      log('[AuthRepository] Token renovado, mas falha ao buscar usuário. Limpando sessão.');
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
      log('[AuthRepository] Tentando login para: $email');

      final response = await _authDio.post(
        '/auth/login',
        data: {'username': email, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final tokens = AuthTokens.fromJson(response.data);
      await _saveTokens(tokens);

      log('[AuthRepository] Login bem-sucedido. Buscando dados do usuário...');
      final result = await _getUserInfo();

      return result.fold(
            (_) {
          log('[AuthRepository] ❌ Falha ao buscar dados do usuário após login');
          return const Left(SignInError.unknown);
        },
            (_) {
          log('[AuthRepository] ✅ Dados do usuário obtidos com sucesso');
          return const Right(null);
        },
      );
    } on DioException catch (e) {
      log('[AuthRepository] ❌ Erro no login: ${e.response?.statusCode} - ${e.message}');

      if (e.response?.statusCode == 401) {
        final responseData = e.response?.data as Map<String, dynamic>?;
        final detail = responseData?['detail'] as String?;

        if (detail == 'Email not verified') {
          return const Left(SignInError.emailNotVerified);
        }
        if (detail == 'Inactive account') {
          return const Left(SignInError.inactiveAccount);
        }
        return const Left(SignInError.invalidCredentials);
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const Left(SignInError.networkError);
      }

      if (e.response?.statusCode != null && e.response!.statusCode! >= 500) {
        return const Left(SignInError.serverError);
      }

      return const Left(SignInError.unknown);
    }
  }

  // ✅ MÉTODO CORRIGIDO: Aguarda renovações em andamento
  Future<Either<String, void>> refreshAccessToken() async {
    // ✅ Se já está renovando, retorna a mesma Future para evitar duplicação
    if (_isRefreshing && _refreshFuture != null) {
      log('[AuthRepository] ⏳ Renovação já em andamento. Aguardando conclusão...');
      return _refreshFuture!;
    }

    _isRefreshing = true;

    // ✅ NOVO: Cria Future que será compartilhada com requisições simultâneas
    _refreshFuture = _performRefresh();

    try {
      return await _refreshFuture!;
    } finally {
      _isRefreshing = false;
      _refreshFuture = null;
    }
  }

  // ✅ NOVO: Método privado que executa o refresh
  Future<Either<String, void>> _performRefresh() async {
    try {
      final refreshToken = await _secureStorage.read(key: SecureStorageKeys.refreshToken);

      if (refreshToken == null) {
        log('[AuthRepository] ❌ Nenhum refresh token encontrado');
        return const Left('Nenhuma sessão para renovar.');
      }

      log('[AuthRepository] 🔄 Renovando access token...');

      final response = await _authDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newTokens = AuthTokens.fromJson(response.data);
        await _saveTokens(newTokens);

        log('[AuthRepository] ✅ Token renovado com sucesso');
        return const Right(null);
      }

      log('[AuthRepository] ❌ Resposta inesperada: ${response.statusCode}');
      return Left('Erro ao renovar token: status ${response.statusCode}');

    } on DioException catch (e) {
      log('[AuthRepository] ❌ Erro ao renovar token: ${e.response?.statusCode}');

      // ✅ NOVO: Detecta se refresh token expirou
      if (e.response?.statusCode == 401) {
        log('[AuthRepository] 🚨 Refresh token expirado. Sessão inválida.');
        return const Left('session_expired');
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const Left('Erro de conexão ao renovar token');
      }

      return Left('Falha ao renovar token: ${e.message}');
    } catch (e) {
      log('[AuthRepository] ❌ Erro inesperado ao renovar token: $e');
      return Left('Erro inesperado: ${e.toString()}');
    }
  }

  // ✅ MÉTODO CORRIGIDO: Salva em memória E no storage
  Future<void> _saveTokens(AuthTokens tokens) async {
    _authTokens = tokens;

    await Future.wait([
      _secureStorage.write(
        key: SecureStorageKeys.accessToken,
        value: tokens.accessToken,
      ),
      _secureStorage.write(
        key: SecureStorageKeys.refreshToken,
        value: tokens.refreshToken,
      ),
    ]);

    log('[AuthRepository] ✅ Tokens salvos (memória + storage)');
  }

  Future<void> logout() async {
    log('[AuthRepository] 🚪 Limpando tokens e dados de sessão...');

    _authTokens = null;
    _user = null;

    await Future.wait([
      _secureStorage.delete(key: SecureStorageKeys.accessToken),
      _secureStorage.delete(key: SecureStorageKeys.refreshToken),
    ]);

    log('[AuthRepository] ✅ Logout completo');
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

      debugPrint('Erro ao reenviar código: $e');
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

      debugPrint('Erro ao verificar código: $e');
      return const Left(CodeError.unknown);
    }
  }

  Future<Either<void, void>> _getUserInfo() async {
    try {
      log('[AuthRepository] Buscando dados do usuário...');

      // ✅ Esta chamada usa o _dio normal (com interceptor)
      final response = await _dio.get('/users/me');
      _user = User.fromJson(response.data);

      log('[AuthRepository] ✅ Usuário: ${_user?.name ?? _user?.email}');
      return const Right(null);
    } on DioException catch (e) {
      log('[AuthRepository] ❌ Erro ao buscar usuário: ${e.response?.statusCode}');
      return const Left(null);
    } catch (e) {
      log('[AuthRepository] ❌ Erro inesperado ao buscar usuário: $e');
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
      await _authDio.post(
        '/users',
        data: {
          'email': email,
          'phone': phone,
          'name': name,
          'password': password,
        },
      );

      log('[AuthRepository] ✅ Cadastro realizado com sucesso');
      return const Right(null);
    } on DioException catch (e) {
      log('[AuthRepository] ❌ Erro no cadastro: ${e.response?.statusCode}');

      if (e.response?.statusCode == 409) {
        final detail = e.response?.data?['detail'] as String?;
        if (detail?.contains('e-mail') == true || detail?.contains('email') == true) {
          return const Left(SignUpError.emailAlreadyExists);
        }
        if (detail?.contains('telefone') == true || detail?.contains('phone') == true) {
          return const Left(SignUpError.userAlreadyExists);
        }
      }

      if (e.response?.statusCode == 400) {
        final detail = e.response?.data?['detail'] as String?;
        if (detail?.contains('senha') == true || detail?.contains('password') == true) {
          return const Left(SignUpError.weakPassword);
        }
        return const Left(SignUpError.invalidData);
      }

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return const Left(SignUpError.networkError);
      }

      debugPrint('Erro no cadastro: $e');
      return const Left(SignUpError.unknown);
    }
  }
}