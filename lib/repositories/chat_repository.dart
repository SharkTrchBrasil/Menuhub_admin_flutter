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
      // Tratamento de erro específico para Dio, igual ao StoreRepository
      debugPrint('DioException em getInitialState: $e');
      final errorMsg = e.response?.data?['detail'] ?? 'Falha ao carregar o histórico da conversa.';
      return Left(Failure(errorMsg));
    } catch (e) {
      // Tratamento de erro genérico
      debugPrint('Erro inesperado em getInitialState: $e');
      return Left(Failure('Ocorreu um erro inesperado.'));
    }
  }

  Future<Either<Failure, void>> sendMessage({
    required int storeId,
    required String chatId,
    String? textContent, // Torna o texto opcional para mídias sem legenda
    String? mediaUrl,
    String? mediaType,
    String? mediaFilename,
  }) async {
    try {
      // Monta o payload dinamicamente com todos os dados
      final payload = {
        'chat_id': chatId,
        'text_content': textContent,
        'media_url': mediaUrl,
        'media_type': mediaType,
        'media_filename': mediaFilename,
      };

      // Remove chaves nulas para enviar um payload limpo para a API
      payload.removeWhere((key, value) => value == null);

      await _dio.post(
        '/stores/$storeId/chatbot/conversations/send-message',
        data: payload,
      );
      return const Right(null);
    } on DioException catch (e) {
      debugPrint('DioException em sendMessage: $e');
      final errorMsg = e.response?.data?['detail'] ?? 'Não foi possível enviar a mensagem.';
      return Left(Failure(errorMsg));
    } catch (e) {
      debugPrint('Erro inesperado em sendMessage: $e');
      return Left(Failure('Ocorreu um erro inesperado.'));
    }
  }


  Future<void> markAsRead({
    required int storeId,
    required String chatId,
  }) async {
    try {
      // Não nos preocupamos com a resposta, apenas enviamos o comando.
      await _dio.post(
        '/stores/$storeId/chatbot/conversations/$chatId/mark-as-read',
      );
    } catch (e) {
      // Em caso de falha, apenas logamos. Não precisa interromper o usuário.
      debugPrint('Falha ao marcar conversa como lida: $e');
    }
  }

  Future<Either<Failure, String>> uploadMedia({
    required int storeId,
    required File file,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'media_file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      // Supondo que você crie este endpoint no seu backend Python
      final response = await _dio.post(
        '/stores/$storeId/chatbot/upload-media',
        data: formData,
      );

      // O backend deve retornar um JSON como: { "media_url": "https://..." }
      return Right(response.data['media_url']);

    } on DioException catch (e) {
      debugPrint('DioException em uploadMedia: $e');
      return Left(Failure('Falha ao enviar a mídia.'));
    } catch (e) {
      debugPrint('Erro inesperado em uploadMedia: $e');
      return Left(Failure('Ocorreu um erro inesperado.'));
    }
  }





}