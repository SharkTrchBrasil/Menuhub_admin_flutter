import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:totem_pro_admin/cubits/auth_cubit.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';

import 'di.dart';

class TokenInterceptor extends Interceptor {
  AuthRepository get _authRepository => getIt<AuthRepository>();

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
    // ✅ Lógica mantida: verifica 401 e evita loop na rota de refresh.
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/refresh')) {
      log('[TokenInterceptor] Token expirado detectado. Tentando renovar...');

      if (_authRepository.isRefreshingToken) {
        log('[TokenInterceptor] Renovação já em andamento. Aguardando...');
        // Ouve a conclusão do processo de renovação para tentar novamente.
        return _awaitAndRetry(err, handler);
      }

      final refreshResult = await _authRepository.refreshAccessToken();

      return await refreshResult.fold(
            (error) async {
          log('[TokenInterceptor] Falha ao renovar o token: $error. Deslogando usuário.');
          await getIt<AuthCubit>().logout();
          return handler.next(err);
        },
            (_) async {
          log('[TokenInterceptor] Token renovado com sucesso. Tentando requisição original novamente.');
          try {
            final response = await _retry(err.requestOptions);
            return handler.resolve(response);
          } on DioException catch (e) {
            return handler.reject(e);
          }
        },
      );
    }

    return handler.next(err);
  }

  // ✅ NOVO: Método mais robusto para aguardar uma renovação em andamento.
  Future<void> _awaitAndRetry(DioException err, ErrorInterceptorHandler handler) async {
    // Aguarda até que a flag _isRefreshing seja liberada.
    await Future.doWhile(() => _authRepository.isRefreshingToken);

    log('[TokenInterceptor] Renovação concluída. Tentando novamente a requisição que estava em espera.');
    try {
      final response = await _retry(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.reject(e);
    }
  }

  // ✨ MÉTODO _retry CORRIGIDO E ROBUSTO ✨
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    log('[TokenInterceptor] Refazendo a requisição para: ${requestOptions.path}');

    // 1. Atualiza o cabeçalho da requisição original com o novo token.
    requestOptions.headers['Authorization'] = 'Bearer ${_authRepository.accessToken}';

    // 2. Usa dio.fetch() que recebe um RequestOptions e o re-executa.
    //    Este método é capaz de lidar corretamente com streams de FormData
    //    e outros tipos de corpo de requisição complexos.
    final dio = getIt<Dio>();
    return dio.fetch(requestOptions);
  }
}