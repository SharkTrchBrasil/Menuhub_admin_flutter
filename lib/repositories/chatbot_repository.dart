// lib/repositories/chatbot_repository.dart

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../core/failures.dart';

class ChatbotRepository {
  ChatbotRepository(this._dio);

  final Dio _dio;

  Future<Either<Failure, void>> connectWhatsApp({
    required int storeId,
    required String method,
    String? phoneNumber,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'method': method,
      };
      if (phoneNumber != null) {
        payload['phone_number'] = phoneNumber;
      }

      await _dio.post(
        '/stores/$storeId/chatbot-config/connect',
        data: payload,
      );
      return const Right(null);
    } on DioException catch (e) {
      debugPrint('connectWhatsApp error: $e');
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Falha ao conectar com o WhatsApp',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, void>> disconnectChatbot(int storeId) async {
    try {
      await _dio.delete('/stores/$storeId/chatbot-config/disconnect');
      return const Right(null);
    } on DioException catch (e) {
      debugPrint('disconnectChatbot error: $e');
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Não foi possível desconectar o chatbot',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

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

      await _dio.patch(
        '/stores/$storeId/chatbot-config/$messageKey',
        data: payload,
      );

      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Falha ao atualizar a mensagem',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(
        message: 'Erro inesperado ao salvar a mensagem: $e',
      ));
    }
  }

  Future<Either<Failure, void>> updateChatbotStatus({
    required int storeId,
    required bool isActive,
  }) async {
    try {
      await _dio.post(
        '/chatbot/update-status',
        data: {
          'storeId': storeId,
          'isActive': isActive,
        },
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Falha ao atualizar o status do chatbot',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }
}