// lib/repositories/chatbot_repository.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import '../core/failures.dart';

class ChatbotRepository {
  ChatbotRepository(this._dio);

  final Dio _dio;


  // ✅ MÉTODO ATUALIZADO
  Future<Either<Failure, void>> connectWhatsApp({
    required int storeId,
    required String method,
    String? phoneNumber, // phoneNumber agora é opcional
  }) async {
    try {
      // Monta o payload dinamicamente
      final Map<String, dynamic> payload = {
        'method': method,
      };
      if (phoneNumber != null) {
        payload['phone_number'] = phoneNumber;
      }

      await _dio.post(
        '/stores/$storeId/chatbot-config/connect',
        data: payload, // Envia o payload completo
      );
      return const Right(null);
    } on DioException catch (e) {
      debugPrint('connectWhatsApp error: $e');
      final errorMsg = e.response?.data?['detail'] ?? 'Falha ao conectar com o WhatsApp.';
      return Left(Failure(errorMsg));
    } catch (e) {
      return Left(Failure('Ocorreu um erro inesperado.'));
    }
  }


  Future<Either<Failure, void>> disconnectChatbot(int storeId) async {
    try {
      await _dio.delete('/stores/$storeId/chatbot-config/disconnect');
      return const Right(null);
    } catch (e) {
      debugPrint('disconnectChatbot error: $e');
      return Left(Failure('Não foi possível desconectar o chatbot.'));
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
      final errorMsg = e.response?.data?['detail'] ?? 'Falha ao atualizar a mensagem.';
      return Left(Failure(errorMsg));
    } catch (e) {
      return Left(Failure('Ocorreu um erro inesperado ao salvar a mensagem.'));
    }
  }


  Future<Either<Failure, void>> updateChatbotStatus({
    required int storeId,
    required bool isActive,
  }) async {
    try {
      // Este endpoint está na raiz da API do Node, não sob /stores/{id}
      await _dio.post(
        '/chatbot/update-status',
        data: {
          'storeId': storeId,
          'isActive': isActive,
        },
      );
      return const Right(null);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail'] ?? 'Falha ao atualizar o status do chatbot.';
      return Left(Failure(errorMsg));
    } catch (e) {
      return Left(Failure('Ocorreu um erro inesperado.'));
    }
  }

}