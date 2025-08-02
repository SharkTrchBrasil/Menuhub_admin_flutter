import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/token_interceptor.dart';
import 'package:totem_pro_admin/models/auth_tokens.dart';
import 'package:totem_pro_admin/models/user.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';
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
  // ✅ ALTERAÇÃO 1: A chave principal de autenticação agora é o JWT do usuário.
  static const accessToken = 'access_token';
  static const refreshToken = 'refreshToken';
  // A chave do totem é mantida para outras funcionalidades, se houver.
  static const totemToken = 'totem_token';
}


class AuthRepository {
  AuthRepository(this._dio, this._secureStorage);

  final Dio _dio;

  AuthTokens? _authTokens;

  AuthTokens? get authTokens => _authTokens;
  // ✅ ALTERAÇÃO 2: A propriedade principal agora é o token de acesso (JWT).
  // Ele será guardado em memória para acesso rápido durante a sessão.
  String? _accessToken;
  String? get accessToken => _accessToken;

  User? _user;

  User? get user => _user;

  final FlutterSecureStorage _secureStorage;

  /// ✅ ALTERAÇÃO 3: O método initialize agora foca em restaurar a sessão do ADMIN.
  /// Ele lê o token JWT salvo e o valida.
  Future<bool> initialize() async {
    // Tenta renovar o token usando o refresh_token salvo.
    final refreshResult = await refreshAccessToken();
    if (refreshResult.isLeft) {
      // Se a renovação falhar (ex: refresh_token expirado), desloga o usuário.
      await logout();
      return false;
    }

    // Se a renovação foi bem-sucedida, busca os dados do usuário.
    final userResult = await _getUserInfo();
    if (userResult.isLeft) {
      await logout();
      return false;
    }

    return true;
  }

  /// ✅ ALTERAÇÃO 2: O método signIn agora salva AMBOS os tokens.
  Future<Either<SignInError, void>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'username': email, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      final tokens = AuthTokens.fromJson(response.data);
      _accessToken = tokens.accessToken;

      // Salva ambos os tokens no armazenamento seguro.
      await _secureStorage.write(key: SecureStorageKeys.accessToken, value: _accessToken);
      await _secureStorage.write(key: SecureStorageKeys.refreshToken, value: tokens.refreshToken);

      final result = await _getUserInfo();
      if (result.isLeft) {
        return Left(SignInError.unknown);
      }

      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final responseData = e.response?.data as Map<String, dynamic>?;
        if (responseData?['detail'] == 'Email not verified') {
          // Encontramos nosso caso específico!
          return Left(SignInError.emailNotVerified);
        }
        // Se for outro erro 401, consideramos credenciais inválidas.
        return Left(SignInError.invalidCredentials);
      }
      return const Left(SignInError.unknown);
    }
  }

  /// ✅ ALTERAÇÃO 3: O método de refresh foi tornado público e corrigido.
  /// Ele será chamado pelo RealtimeRepository quando a conexão cair.
  Future<Either<String, void>> refreshAccessToken() async {
    final refreshToken = await _secureStorage.read(key: SecureStorageKeys.refreshToken);
    if (refreshToken == null) {
      return const Left('Nenhuma sessão para renovar.');
    }

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final newTokens = AuthTokens.fromJson(response.data);
      _accessToken = newTokens.accessToken;

      // Salva os novos tokens, sobrescrevendo os antigos.
      await _secureStorage.write(key: SecureStorageKeys.accessToken, value: _accessToken);
      await _secureStorage.write(key: SecureStorageKeys.refreshToken, value: newTokens.refreshToken);

      print('[AuthRepository] Token de acesso renovado com sucesso.');
      return const Right(null);
    } catch (e) {
      print('[AuthRepository] Falha ao renovar o token: $e');
      return Left('Falha ao renovar o token: ${e.toString()}');
    }
  }


  /// ✅ ALTERAÇÃO 4: O logout agora limpa AMBOS os tokens.
  Future<void> logout() async {
    _accessToken = null;
    _user = null;
    await _secureStorage.delete(key: SecureStorageKeys.accessToken);
    await _secureStorage.delete(key: SecureStorageKeys.refreshToken);
  }



  Future<Either<ResendError, void>> sendCode({required String email}) async {
    try {
      final response = await _dio.post(
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
      final response = await _dio.post(
        '/verify-code',
        queryParameters: {'email': email, 'code': code},
      );

      // Aqui, o código foi validado com sucesso, podemos redirecionar
      if (response.statusCode == 200) {
        // Ex: print(response.data['message']); se quiser usar a mensagem
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
      final response = await _dio.get('/users/me');
      _user = User.fromJson(response.data);
      return const Right(null);
    } catch (e) {
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
      await Future.delayed(const Duration(seconds: 2));

      await _dio.post(
        '/users',
        data: {'email': email, 'phone': phone, 'name': name, 'password': password},
      );

      return Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 &&
          e.response?.data?['detail'] == 'User already exists') {
        return Left(SignUpError.userAlreadyExists);
      }
      debugPrint('$e');
      return Left(SignUpError.unknown);
    }
  }



  Future<Either<void, TotemAuth>> checkToken() async {
    try {
      final token = await getTotemToken();
      if (token.isEmpty) {
        return Left(null);
      }

      final response = await _dio.post(
        '/auth/check-token',
        data: {'totem_token': token},
      );

      return Right(TotemAuth.fromJson(response.data));
    } catch (e) {
      print('Error in checkToken: $e');
      return Left(null);
    }
  }

  Future<Either<void, TotemAuth>> getToken(String storeSlug) async {
    try {
      final response = await _dio.post(
        '/auth/subdomain',

        data: {'store_url': storeSlug, 'totem_token': await getTotemToken()},
      );

      final TotemAuth totemAuth = TotemAuth.fromJson(response.data);

      await _secureStorage.write(key: 'totem_token', value: totemAuth.token);

      return Right(totemAuth);
    } catch (e) {
      print('Erro ao buscar token do subdomínio: $e');
      return Left(null);
    }
  }

  Future<String> getTotemToken() async {
    String? token = await _secureStorage.read(key: 'totem_token');
    if (token != null && token.isNotEmpty) return token;

    token = const Uuid().v4();
    await _secureStorage.write(key: 'totem_token', value: token);
    return token;
  }
}
