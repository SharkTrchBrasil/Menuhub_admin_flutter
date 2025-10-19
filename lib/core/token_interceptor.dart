import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:totem_pro_admin/cubits/auth_cubit.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';
import 'di.dart';

class TokenInterceptor extends Interceptor {
  AuthRepository get _authRepository => getIt<AuthRepository>();

  // ✅ NOVO: Callback para notificar quando tokens expirarem
  Function? onBothTokensExpired;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ✅ Lógica mantida: não adiciona token em rotas de autenticação.
    if (options.path.contains('/auth/')) {
      return handler.next(options);
    }

    final accessToken = _authRepository.accessToken;
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // ✅ Verifica 401 e evita loop na rota de refresh.
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/refresh')) {

      log('[TokenInterceptor] 🔴 Token expirado detectado (401). Tentando renovar...');

      // ✅ Se já está renovando, aguarda
      if (_authRepository.isRefreshingToken) {
        log('[TokenInterceptor] ⏳ Renovação já em andamento. Aguardando...');
        return _awaitAndRetry(err, handler);
      }

      // ✅ Tenta renovar o token
      final refreshResult = await _authRepository.refreshAccessToken();

      return await refreshResult.fold(
        // ❌ FALHA: Refresh token também expirou
            (error) async {
          log('[TokenInterceptor] ❌ Falha ao renovar token: $error');
          log('[TokenInterceptor] 🚪 Ambos tokens expiraram. Fazendo logout...');

          // ✅ NOTIFICA O CALLBACK (para mostrar mensagem no UI)
          onBothTokensExpired?.call();

          // ✅ Faz logout
          await getIt<AuthCubit>().logout();

          return handler.next(err);
        },
        // ✅ SUCESSO: Token renovado
            (_) async {
          log('[TokenInterceptor] ✅ Token renovado com sucesso!');
          log('[TokenInterceptor] 🔄 Retentando requisição original...');

          try {
            final response = await _retry(err.requestOptions);
            return handler.resolve(response);
          } on DioException catch (e) {
            log('[TokenInterceptor] ❌ Erro ao retentar requisição: ${e.message}');
            return handler.reject(e);
          }
        },
      );
    }

    return handler.next(err);
  }

  /// ✅ Aguarda renovação em andamento e retenta
  Future<void> _awaitAndRetry(
      DioException err,
      ErrorInterceptorHandler handler,
      ) async {
    // Aguarda até que a flag _isRefreshing seja liberada.
    await Future.doWhile(() => _authRepository.isRefreshingToken);

    log('[TokenInterceptor] ✅ Renovação concluída. Retentando requisição em espera...');

    try {
      final response = await _retry(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      log('[TokenInterceptor] ❌ Erro ao retentar: ${e.message}');
      return handler.reject(e);
    }
  }

  /// ✅ Retenta requisição com novo token
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    log('[TokenInterceptor] 🔄 Refazendo requisição: ${requestOptions.path}');

    // 1. Atualiza o cabeçalho com o novo token
    final newToken = _authRepository.accessToken;
    if (newToken != null) {
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
    }

    // 2. Re-executa a requisição
    final dio = getIt<Dio>();
    return dio.fetch(requestOptions);
  }
}