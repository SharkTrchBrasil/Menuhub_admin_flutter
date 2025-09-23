// lib/repositories/chatbot_repository.dart

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../core/failures.dart';

class ChatbotRepository {
  ChatbotRepository(this._dio);

  final Dio _dio;

  /// Solicita a conexão com o WhatsApp
  Future<Either<Failure, void>> connectWhatsApp(int storeId) async {
    try {
      await _dio.post('/stores/$storeId/chatbot-config/connect');
      return const Right(null);
    } on DioException catch (e) {
      debugPrint('connectWhatsApp error: $e');
      final errorMsg = e.response?.data?['detail'] ?? 'Falha ao conectar com o WhatsApp.';
      return Left(Failure(errorMsg));
    } catch (e) {
      return Left(Failure('Ocorreu um erro inesperado.'));
    }
  }

  /// Solicita a desconexão do WhatsApp
  Future<Either<Failure, void>> disconnectChatbot(int storeId) async {
    try {
      await _dio.post('/stores/$storeId/chatbot-config/disconnect');
      return const Right(null);
    } catch (e) {
      debugPrint('disconnectChatbot error: $e');
      return Left(Failure('Não foi possível desconectar o chatbot.'));
    }
  }

  /// Atualiza uma mensagem específica do chatbot.
  /// Pode atualizar o conteúdo, o status de ativação, ou ambos.
  Future<Either<Failure, void>> updateMessage({
    required int storeId,
    required String messageKey,
    String? customContent,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> payload = {};
      if (customContent != null) {
        payload['custom_content'] = customContent;
      }
      if (isActive != null) {
        payload['is_active'] = isActive;
      }
      if (payload.isEmpty) {
        return const Right(null);
      }

      // ✅ ROTA CORRIGIDA: Apontando para 'chatbot-config' para alinhar com a API Python.
      await _dio.patch(
        '/stores/$storeId/chatbot-config/$messageKey',
        data: payload,
      );

      return const Right(null);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail'] ?? 'Falha ao atualizar a mensagem.';
      return Left(Failure(errorMsg));
    } catch (e) {
      return Left(Failure('Ocorreu um erro inesperado ao salvar a mensagem.'));
    }
  }
}