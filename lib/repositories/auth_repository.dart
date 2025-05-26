import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/token_interceptor.dart';
import 'package:totem_pro_admin/models/auth_tokens.dart';
import 'package:totem_pro_admin/models/user.dart';

enum SignInError { invalidCredentials, inactiveAccount, emailNotVerified, unknown }
enum CodeError { unknown, userNotFound, alreadyVerified, invalidCode }
enum ResendError { unknown, userNotFound, resendError }
enum SignUpError { userAlreadyExists, unknown }

class SecureStorageKeys {
  static const refreshToken = 'refreshToken';
}

class AuthRepository {

  AuthRepository(this._dio, this._secureStorage);

  final Dio _dio;

  AuthTokens? _authTokens;
  AuthTokens? get authTokens => _authTokens;

  User? _user;
  User? get user => _user;

  final FlutterSecureStorage _secureStorage;

  Future<bool> initialize() async {
    final refreshToken = await _secureStorage.read(key: SecureStorageKeys.refreshToken);
    if (refreshToken == null) return false;

    final result = await _refreshAccessToken(refreshToken);

    if (result.isLeft) {
      return false;
    }

    final userResult = await _getUserInfo();

    if (userResult.isLeft) {
      _authTokens = null;
      return false;
    }

    return true;
  }

  Future<Either<SignInError, void>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final response = await _dio.post(
        '/auth/login',
        data: FormData.fromMap({'username': email, 'password': password}),
      );

      _authTokens = AuthTokens.fromJson(response.data);

      await _secureStorage.write(
        key: SecureStorageKeys.refreshToken,
        value: _authTokens!.refreshToken,
      );

      final result = await _getUserInfo();

      if (result.isLeft) {
        _authTokens = null;
        return Left(SignInError.unknown);
      }

      return Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        final detail = e.response?.data?['detail'];

        if (detail == 'Email not verified') {
          return const Left(SignInError.emailNotVerified);
        }

        if (detail == 'Inactive account') {
          return const Left(SignInError.inactiveAccount);
        }

        return const Left(SignInError.invalidCredentials);
      }

      debugPrint('$e');
      return const Left(SignInError.unknown);
    }
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

      if (e.response?.statusCode == 404 && detail == 'Usuário não encontrado.') {
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
        queryParameters: {
          'email': email,
          'code': code,
        },
      );

      // Aqui, o código foi validado com sucesso, podemos redirecionar
      if (response.statusCode == 200) {
        // Ex: print(response.data['message']); se quiser usar a mensagem
        return const Right(null);
      }

      return const Left(CodeError.unknown);
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'];

      if (e.response?.statusCode == 404 && detail == 'Usuário não encontrado.') {
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
























  Future<Either<void, void>> _refreshAccessToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      );

      _authTokens = AuthTokens.fromJson(response.data);

      return const Right(null);
    } catch (e) {
      return const Left(null);
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
    required String email,
    required String password,

  }) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      await _dio.post(
        '/users',
        data: {'email': email, 'name': name, 'password': password, },
      );

      return Right(null);
    } on DioException catch (e) {
      if(e.response?.statusCode == 400 && e.response?.data?['detail'] == 'User already exists') {
        return Left(SignUpError.userAlreadyExists);
      }
      debugPrint('$e');
      return Left(SignUpError.unknown);
    }
  }

  void signOut() {
    _authTokens = null;
    _user = null;
    _secureStorage.delete(key: SecureStorageKeys.refreshToken);
  }
}
