// lib/cubits/chatbot/chatbot_cubit.dart

import 'dart:async';


import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'package:totem_pro_admin/repositories/chatbot_repository.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';
import '../../../models/store/store_chatbot_config.dart';
import '../../../models/store/store_chatbot_message.dart';
import 'chatbot_state.dart';

class ChatbotCubit extends Cubit<ChatbotState> {
  final int storeId;
  final ChatbotRepository _chatbotRepository;
  final RealtimeRepository _realtimeRepository;
  StreamSubscription? _configSubscription;
  final StoresManagerCubit _storesManagerCubit;

  StreamSubscription? _storesManagerSubscription;

  ChatbotCubit({
    required this.storeId,
    required ChatbotRepository chatbotRepository,
    required RealtimeRepository realtimeRepository,
    required StoresManagerCubit storesManagerCubit,
  })  : _chatbotRepository = chatbotRepository,
        _realtimeRepository = realtimeRepository,
        _storesManagerCubit = storesManagerCubit,
        super(ChatbotInitial());



  void initialize(StoreChatbotConfig? initialConfig, List<StoreChatbotMessage> initialMessages) {
    _processConfigUpdate(initialConfig, initialMessages);
    _listenForUpdates();
    _listenToStoresManager();
  }

  void _listenForUpdates() {
    _configSubscription?.cancel();
    _configSubscription = _realtimeRepository.onChatbotConfigUpdated.listen((updatedConfig) {
      final currentMessages = state is ChatbotConnected ? (state as ChatbotConnected).messages : <StoreChatbotMessage>[];
      _processConfigUpdate(updatedConfig, currentMessages);
    });
  }


  void _listenToStoresManager() {
    _storesManagerSubscription?.cancel();
    _storesManagerSubscription = _storesManagerCubit.stream.listen((storesState) {
      // Se o estado do StoresManager for carregado e o nosso for conectado
      if (storesState is StoresManagerLoaded && state is ChatbotConnected) {
        final currentChatbotState = state as ChatbotConnected;

        // Pega a nova lista de mensagens do StoresManagerCubit
        final newMessages = storesState.activeStore?.relations.chatbotMessages ?? [];

        // Compara com a lista atual para evitar emissões desnecessárias
        if (!listEquals(currentChatbotState.messages, newMessages)) {
          print('✅ [ChatbotCubit] Recebida nova lista de mensagens do StoresManagerCubit. Atualizando...');
          // Emite um novo estado COM A LISTA DE MENSAGENS ATUALIZADA
          emit(currentChatbotState.copyWith(messages: newMessages));
        }
      }
    });
  }




  void _processConfigUpdate(StoreChatbotConfig? config, List<StoreChatbotMessage> messages) {
    if (isClosed) return;
    if (config == null) {
      emit(ChatbotDisconnected());
      return;
    }
    switch (config.connectionStatus) {
      case 'connected':
        emit(ChatbotConnected(config: config, messages: messages));
        break;
      case 'awaiting_qr':
      case 'awaiting_pairing_code': // ✅ NOVO CASO
        emit(ChatbotAwaitingQr(qrCode: config.qrCode, pairingCode: config.pairingCode));
        break;
      case 'pending':
        emit(ChatbotLoading());
        break;
      case 'error':
        emit(const ChatbotError('Ocorreu um erro na conexão do chatbot.'));
        break;
      default:
        emit(ChatbotDisconnected());
    }
  }

  // ✅ MÉTODO ATUALIZADO
  Future<void> connectWhatsApp({required String method, String? phoneNumber}) async {
    emit(ChatbotLoading());
    final result = await _chatbotRepository.connectWhatsApp(
      storeId: storeId,
      method: method,
      phoneNumber: phoneNumber,
    );
    result.fold(
          (failure) => emit(ChatbotError(failure.message)),
          (_) => null, // O sucesso é tratado pelo listener de tempo real que recebe o QR/Pairing code
    );
  }

  Future<void> disconnectChatbot() async {
    emit(ChatbotLoading());
    final result = await _chatbotRepository.disconnectChatbot(storeId);
    result.fold(
          (failure) => emit(ChatbotError(failure.message)),
          (_) => null,
    );
  }


  Future<void> cancelConnectionAttempt() async {
    // A desconexão efetivamente cancela a tentativa de conexão (seja QR ou código)
    await disconnectChatbot();
    emit(ChatbotDisconnected()); // Volta para o estado desconectado
  }


  Future<void> updateMessageContent(String messageKey, String newContent) async {
    if (state is! ChatbotConnected) return;
    final currentState = state as ChatbotConnected;
    final currentMessages = currentState.messages;

    final updatedMessages = currentMessages.map((msg) {
      if (msg.templateKey == messageKey) {
        return msg.copyWith(customContent: newContent);
      }
      return msg;
    }).toList();

    emit(currentState.copyWith(messages: updatedMessages));

    final result = await _chatbotRepository.updateMessage(
      storeId: storeId,
      messageKey: messageKey,
      customContent: newContent,
    );

    result.fold(
          (failure) {
        print('Falha ao salvar conteúdo: ${failure.message}');
        emit(currentState.copyWith(messages: currentMessages));
      },
          (_) => print('Conteúdo da mensagem $messageKey salvo com sucesso!'),
    );
  }

  Future<void> toggleMessageActive(String messageKey, bool isActive) async {
    if (state is! ChatbotConnected) return;
    final currentState = state as ChatbotConnected;
    final currentMessages = currentState.messages;

    final updatedMessages = currentMessages.map((msg) {
      if (msg.templateKey == messageKey) {
        return msg.copyWith(isActive: isActive);
      }
      return msg;
    }).toList();

    emit(currentState.copyWith(messages: updatedMessages));

    final result = await _chatbotRepository.updateMessage(
      storeId: storeId,
      messageKey: messageKey,
      isActive: isActive,
    );

    result.fold(
          (failure) {
        print('Falha ao atualizar status: ${failure.message}');
        emit(currentState.copyWith(messages: currentMessages));
      },
          (_) => print('Status da mensagem $messageKey salvo com sucesso!'),
    );
  }



  Future<void> toggleChatbotActive(bool isActive) async {
    if (state is! ChatbotConnected) return;

    final currentState = state as ChatbotConnected;
    final originalConfig = currentState.config;

    // Otimistic UI: Atualiza a UI imediatamente
    final newConfig = originalConfig.copyWith(isActive: isActive);
    emit(currentState.copyWith(config: newConfig));

    // Chama a API
    final result = await _chatbotRepository.updateChatbotStatus(
      storeId: storeId,
      isActive: isActive,
    );

    // Em caso de falha, reverte a UI para o estado original
    result.fold(
          (failure) {
        print('Falha ao atualizar status do chatbot: ${failure.message}');
        emit(currentState.copyWith(config: originalConfig));
      },
          (_) => print('Status geral do chatbot salvo com sucesso!'),
    );
  }

  @override
  Future<void> close() {
    // Se o estado atual for de espera (QR ou código), cancela a tentativa ao fechar o cubit
    if (state is ChatbotAwaitingQr) {
      cancelConnectionAttempt();
    }
    _configSubscription?.cancel();
    _storesManagerSubscription?.cancel();
    return super.close();
  }
}