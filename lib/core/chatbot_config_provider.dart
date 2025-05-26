import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/store_chatbot.dart';

import 'package:either_dart/either.dart';

import '../repositories/chatbot_repository.dart';
import 'package:dio/dio.dart';


class ChatBotConfigController extends ChangeNotifier {
  ChatBotConfigController(this._repository);

  final ChatBotConfigRepository _repository;

  StoreChatBotConfig? config;
  bool loading = false;
  String? qrCode;
  String? error;




  Future<void> init(int storeId) async {
    loading = true;
    notifyListeners();

    final result = await _repository.getConfig(storeId);

    if (result.isRight) {
      config = result.right;
      if (config?.connectionStatus != 'connected') {
        await _fetchQrCode(storeId);
      }
    } else {
      // Se não existe, tenta criar
      final created = await _repository.createConfig(storeId);
      if (created.isRight) {
        config = created.right;
        await _fetchQrCode(storeId);
      } else {
        error = 'Erro ao criar a configuração';
      }
    }

    loading = false;
    notifyListeners();
  }

  Future<void> _fetchQrCode(int storeId) async {
    final result = await _repository.fetchQrCode(storeId);
    result.fold(
          (qr) {
        qrCode = qr;
        error = null;
      },
          (error) {
        this.error = 'Erro ao buscar QR Code';
        qrCode = null;
      },
    );
    notifyListeners();
  }


  Future<void> connectWhatsApp(int storeId) async {
    try {
      loading = true;
      notifyListeners();

      final result = await _repository.connectWhatsApp(storeId);

      if (result.isRight) {
        error = null;
        // Após solicitar a conexão, você pode querer buscar o status novamente
        await init(storeId);
      } else {
        error = 'Erro ao iniciar conexão com WhatsApp';
      }
    } catch (e) {
      error = 'Erro ao conectar WhatsApp: $e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}