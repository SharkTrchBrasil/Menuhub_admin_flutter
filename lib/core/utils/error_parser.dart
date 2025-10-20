import 'package:dio/dio.dart';

class ErrorParser {
  /// ✅ Extrai mensagem de erro de DioException de forma segura
  static String parseErrorMessage(DioException error, {String fallback = 'Erro desconhecido'}) {
    try {
      if (error.response?.data == null) {
        return _getDefaultMessageForStatusCode(error.response?.statusCode);
      }

      final data = error.response!.data;

      // Caso 1: data é String
      if (data is String) {
        return data.isNotEmpty ? data : fallback;
      }

      // Caso 2: data é Map
      if (data is Map<String, dynamic>) {
        final detail = data['detail'];

        // Caso 2a: detail é Map (formato novo do backend)
        if (detail is Map<String, dynamic>) {
          return detail['message'] as String? ?? fallback;
        }

        // Caso 2b: detail é String (formato antigo)
        if (detail is String) {
          return detail.isNotEmpty ? detail : fallback;
        }

        // Caso 2c: message direto no root
        if (data['message'] is String) {
          return data['message'] as String;
        }
      }

      return fallback;
    } catch (e) {
      return fallback;
    }
  }

  /// ✅ Extrai código de erro (se existir)
  static String? parseErrorCode(DioException error) {
    try {
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        final detail = data['detail'];

        if (detail is Map<String, dynamic>) {
          return detail['code'] as String?;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// ✅ Verifica se é erro de permissão
  static bool isPermissionError(DioException error) {
    final code = parseErrorCode(error);
    return code == 'REQUIRES_ANOTHER_ROLE' ||
        code == 'NO_ACCESS_STORE' ||
        error.response?.statusCode == 403;
  }

  /// ✅ Mensagens padrão por status code
  static String _getDefaultMessageForStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Dados inválidos';
      case 401:
        return 'Não autenticado';
      case 403:
        return 'Você não tem permissão para esta ação';
      case 404:
        return 'Recurso não encontrado';
      case 409:
        return 'Conflito: recurso já existe';
      case 422:
        return 'Dados inválidos';
      case 500:
        return 'Erro no servidor';
      case 503:
        return 'Serviço temporariamente indisponível';
      default:
        return 'Erro desconhecido';
    }
  }
}