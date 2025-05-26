import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../models/store_chatbot.dart';

class ChatBotConfigRepository {
  ChatBotConfigRepository(this._dio);

  final Dio _dio;

  /// Busca a configuração do chatbot
  Future<Either<void, StoreChatBotConfig>> getConfig(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/chatbot-config');
      return Right(StoreChatBotConfig.fromJson(response.data));
    } catch (e) {
      debugPrint('getConfig error: $e');
      return const Left(null);
    }
  }

  /// Cria uma nova configuração (ex: quando conecta o WhatsApp pela primeira vez)
  Future<Either<void, StoreChatBotConfig>> createConfig(int storeId) async {
    try {
      final response = await _dio.post('/stores/$storeId/chatbot-config');
      return Right(StoreChatBotConfig.fromJson(response.data));
    } catch (e) {
      debugPrint('createConfig error: $e');
      return const Left(null);
    }
  }

  /// Atualiza a configuração existente
  Future<Either<void, StoreChatBotConfig>> updateConfig(
      int storeId,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _dio.patch(
        '/stores/$storeId/chatbot-config',
        data: data,
      );
      return Right(StoreChatBotConfig.fromJson(response.data));
    } catch (e) {
      debugPrint('updateConfig error: $e');
      return const Left(null);
    }
  }

  /// Busca o QR Code base64
  Future<Either<String, void>> fetchQrCode(int storeId) async {
    try {
      final response = await _dio.get('/stores/$storeId/chatbot-config');
      if (response.data != null && response.data['last_qr_code'] != null) {
        return Left(response.data['last_qr_code'] as String);
      } else {
        return const Right(null); // Indica que o QR code não foi encontrado na resposta
      }
    } catch (e) {
      debugPrint('fetchQrCode error: $e');
      return const Right(null);
    }
  }

  /// Solicita a conexão com o WhatsApp
  Future<Either<void, void>> connectWhatsApp(int storeId) async {
    try {
      await _dio.post('/stores/$storeId/chatbot-config/connect');
      return const Right(null);
    } catch (e) {
      debugPrint('connectWhatsApp error: $e');
      return const Left(null);
    }
  }
}