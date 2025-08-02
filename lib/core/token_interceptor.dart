import 'package:dio/dio.dart';
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/repositories/auth_repository.dart';

class TokenInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final AuthRepository authRepository = getIt();

    final token = authRepository.accessToken;

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Deixa a requisição continuar
    handler.next(options);
  }
}