// lib/repositories/chat_repository.dart

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';

import 'package:totem_pro_admin/models/chat_panel_initial_state.dart';
import '../core/failures.dart';

class ChatRepository {
  final Dio _dio;
  ChatRepository(this._dio);

  /// Busca o estado inicial de um painel de chat, incluindo o histórico
  /// de mensagens e o último pedido ativo do cliente.
  Future<Either<Failure, ChatPanelInitialState>> getInitialState({
    required int storeId,
    required String chatId,
  }) async {
    try {
      final response = await _dio.get(
        '/stores/$storeId/chatbot/conversations/$chatId',
      );
      return Right(ChatPanelInitialState.fromJson(response.data));
    } on DioException catch (e) {
      debugPrint('DioException em getInitialState: $e');
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Falha ao carregar o histórico da conversa',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      debugPrint('Erro inesperado em getInitialState: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, void>> sendMessage({
    required int storeId,
    required String chatId,
    String? textContent,
    String? mediaUrl,
    String? mediaType,
    String? mediaFilename,
  }) async {
    try {
      final payload = {
        'chat_id': chatId,
        'text_content': textContent,
        'media_url': mediaUrl,
        'media_type': mediaType,
        'media_filename': mediaFilename,
      };

      payload.removeWhere((key, value) => value == null);

      await _dio.post(
        '/stores/$storeId/chatbot/conversations/send-message',
        data: payload,
      );
      return const Right(null);
    } on DioException catch (e) {
      debugPrint('DioException em sendMessage: $e');
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Não foi possível enviar a mensagem',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      debugPrint('Erro inesperado em sendMessage: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, void>> markAsRead({
    required int storeId,
    required String chatId,
  }) async {
    try {
      await _dio.post(
        '/stores/$storeId/chatbot/conversations/$chatId/mark-as-read',
      );
      return const Right(null);
    } on DioException catch (e) {
      debugPrint('DioException em markAsRead: $e');
      return Left(Failure(
        message: e.response?.data?['detail'] ??
            'Falha ao marcar conversa como lida',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      debugPrint('Erro inesperado em markAsRead: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }

  Future<Either<Failure, String>> uploadMedia({
    required int storeId,
    required File file,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'media_file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      final response = await _dio.post(
        '/stores/$storeId/chatbot/upload-media',
        data: formData,
      );

      return Right(response.data['media_url']);
    } on DioException catch (e) {
      debugPrint('DioException em uploadMedia: $e');
      return Left(Failure(
        message: e.response?.data?['detail'] ?? 'Falha ao enviar a mídia',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      debugPrint('Erro inesperado em uploadMedia: $e');
      return Left(Failure(message: 'Erro inesperado: $e'));
    }
  }
}