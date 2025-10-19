import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:either_dart/either.dart';
import 'package:totem_pro_admin/models/totem_auth_and_stores.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';

import '../core/enums/auth_erros.dart';

class AuthService {
  final AuthRepository _authRepository;
  final StoreRepository _storeRepository;

  AuthService({
    required AuthRepository authRepository,
    required StoreRepository storeRepository,
  })  : _authRepository = authRepository,
        _storeRepository = storeRepository;

  Future<Either<SignInError, TotemAuthAndStores>> initializeApp() async {
    log('[AuthService] 🚀 Inicializando aplicativo...');

    final isLoggedIn = await _authRepository.initialize();

    if (!isLoggedIn) {
      log('[AuthService] ℹ️ Usuário não está logado');
      return const Left(SignInError.notLoggedIn);
    }

    log('[AuthService] ✅ Sessão válida. Configurando dados...');
    return await _postAuthenticationSetup();
  }

  Future<Either<SignInError, TotemAuthAndStores>> signIn({
    required String email,
    required String password,
  }) async {
    log('[AuthService] 🔐 Tentando login para: $email');

    try {
      final authResult = await _authRepository.signIn(
        email: email,
        password: password,
      );

      return authResult.fold(
            (error) {
          log('[AuthService] ❌ Falha no login: $error');
          return Left(error);
        },
            (_) async {
          log('[AuthService] ✅ Login bem-sucedido. Configurando dados...');
          return await _postAuthenticationSetup();
        },
      );
    } on SocketException {
      log('[AuthService] ❌ Erro de conexão ao fazer login');
      return const Left(SignInError.networkError);
    } on TimeoutException {
      log('[AuthService] ❌ Timeout ao fazer login');
      return const Left(SignInError.networkError);
    } catch (e) {
      log('[AuthService] ❌ Erro inesperado no login: $e');
      return const Left(SignInError.unknown);
    }
  }

  // ✅ VERSÃO FINAL: Usa propriedades e helpers da classe Failure
  Future<Either<SignInError, TotemAuthAndStores>> _postAuthenticationSetup() async {
    final user = _authRepository.user;
    final accessToken = _authRepository.accessToken;

    if (user == null || accessToken == null) {
      log('[AuthService] ❌ Dados de autenticação incompletos');
      return const Left(SignInError.unknown);
    }

    log('[AuthService] 📦 Buscando lojas do usuário...');

    try {
      final storesResult = await _storeRepository.getStores();

      return storesResult.fold(
            (failure) {
          log('[AuthService] ❌ Erro ao buscar lojas: ${failure.message} (Status: ${failure.statusCode})');

          // ✅ USA OS HELPERS DA CLASSE FAILURE

          // Erro 401 - Não autorizado (token inválido)
          if (failure.isUnauthorized) {
            log('[AuthService] 🔐 Token inválido ou expirado');
            return const Left(SignInError.unauthorized);
          }

          // Erro 403 - Acesso negado
          if (failure.isForbidden) {
            log('[AuthService] 🚫 Acesso negado às lojas');
            return const Left(SignInError.unauthorized);
          }

          // Erro 404 - Nenhuma loja encontrada
          if (failure.isNotFound) {
            log('[AuthService] 📭 Nenhuma loja cadastrada');
            return const Left(SignInError.noStoresAvailable);
          }

          // Erros de validação (400, 422)
          if (failure.isValidationError) {
            log('[AuthService] ⚠️ Erro de validação');
            return const Left(SignInError.unknown);
          }

          // Erros do servidor (500+)
          if (failure.isServerError) {
            log('[AuthService] 🔥 Erro no servidor');
            return const Left(SignInError.serverError);
          }

          // Erro de rede/conexão (sem status code)
          if (failure.isNetworkError) {
            log('[AuthService] 📡 Erro de conexão');
            return const Left(SignInError.networkError);
          }

          // ✅ FALLBACK: Analisa mensagem se não identificou pelo status
          final messageLower = failure.message.toLowerCase();

          if (messageLower.contains('no stores') ||
              messageLower.contains('nenhuma loja')) {
            return const Left(SignInError.noStoresAvailable);
          }

          if (messageLower.contains('network') ||
              messageLower.contains('connection') ||
              messageLower.contains('timeout')) {
            return const Left(SignInError.networkError);
          }

          // Erro genérico
          log('[AuthService] ❓ Erro não classificado: ${failure.message}');
          return const Left(SignInError.unknown);
        },
            (stores) {
          log('[AuthService] ✅ ${stores.length} loja(s) encontrada(s)');

          // ✅ Verifica se há lojas
          if (stores.isEmpty) {
            log('[AuthService] ⚠️ Lista de lojas vazia');
            return const Left(SignInError.noStoresAvailable);
          }

          return Right(
            TotemAuthAndStores(
              authTokens: _authRepository.authTokens!,
              user: user,
              stores: stores,
            ),
          );
        },
      );
    } on SocketException catch (e) {
      log('[AuthService] ❌ Erro de conexão ao buscar lojas: $e');
      return const Left(SignInError.networkError);
    } on TimeoutException catch (e) {
      log('[AuthService] ❌ Timeout ao buscar lojas: $e');
      return const Left(SignInError.networkError);
    } catch (e) {
      log('[AuthService] ❌ Erro inesperado ao buscar lojas: $e');
      return const Left(SignInError.unknown);
    }
  }

  Future<void> logout() async {
    log('[AuthService] 🚪 Executando logout...');
    await _authRepository.logout();
    log('[AuthService] ✅ Logout completo');
  }

  Future<Either<SignUpError, void>> signUp({
    required String name,
    required String phone,
    required String email,
    required String password,
  }) async {
    log('[AuthService] 📝 Tentando cadastro para: $email');

    try {
      final result = await _authRepository.signUp(
        name: name,
        phone: phone,
        email: email,
        password: password,
      );

      return result.fold(
            (error) {
          log('[AuthService] ❌ Erro no cadastro: $error');
          return Left(error);
        },
            (_) async {
          log('[AuthService] ✅ Cadastro OK. Enviando código de verificação...');

          final emailResult = await _authRepository.sendCode(email: email);

          return emailResult.fold(
                (error) {
              log('[AuthService] ❌ Erro ao enviar e-mail: $error');
              return const Left(SignUpError.emailNotSent);
            },
                (_) {
              log('[AuthService] ✅ E-mail de verificação enviado');
              return const Right(null);
            },
          );
        },
      );
    } on SocketException catch (e) {
      log('[AuthService] ❌ Erro de conexão no cadastro: $e');
      return Left(_handleSignUpError(e));
    } on TimeoutException catch (e) {
      log('[AuthService] ❌ Timeout no cadastro: $e');
      return Left(_handleSignUpError(e));
    } catch (e) {
      log('[AuthService] ❌ Erro inesperado no cadastro: $e');
      return Left(_handleSignUpError(e));
    }
  }

  Future<Either<CodeError, void>> verifyCode({
    required String email,
    required String code,
  }) {
    log('[AuthService] 🔢 Verificando código para: $email');
    return _authRepository.verifyCode(email: email, code: code);
  }

  SignUpError _handleSignUpError(dynamic error) {
    if (error is SocketException || error is TimeoutException) {
      return SignUpError.networkError;
    }
    return SignUpError.unknown;
  }
}