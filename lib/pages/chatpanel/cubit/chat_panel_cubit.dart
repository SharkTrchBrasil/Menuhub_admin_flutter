// lib/cubits/chat/chat_panel_cubit.dart
import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:totem_pro_admin/models/chatbot_message.dart';
import 'package:totem_pro_admin/repositories/chat_repository.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'chat_panel_state.dart';

class ChatPanelCubit extends Cubit<ChatPanelState> {
  final int storeId;
  final String chatId;
  final ChatRepository _chatRepository;
  final RealtimeRepository _realtimeRepository;
  StreamSubscription? _messageSubscription;

  ChatPanelCubit({
    required this.storeId,
    required this.chatId,
    required ChatRepository chatRepository,
    required RealtimeRepository realtimeRepository,
  })  : _chatRepository = chatRepository,
        _realtimeRepository = realtimeRepository,
        super(ChatPanelInitial());

  Future<void> initialize() async {
    emit(ChatPanelLoading());
    final result = await _chatRepository.getInitialState(storeId: storeId, chatId: chatId);
    result.fold(
          (failure) => emit(ChatPanelError(failure.message)),
          (initialState) {
        emit(ChatPanelLoaded(
          messages: initialState.messages,
          activeOrder: initialState.activeOrder,
        ));
        _listenForRealtimeMessages();
      },
    );
  }

  void _listenForRealtimeMessages() {
    _messageSubscription?.cancel();

    _messageSubscription = _realtimeRepository.onNewChatMessage.listen((newMessage) {
      if (newMessage.chatId == chatId && state is ChatPanelLoaded) {
        final currentState = state as ChatPanelLoaded;

        // ✅ LÓGICA DE SUBSTITUIÇÃO MELHORADA
        final tempMessageIndex = currentState.messages.indexWhere((m) => m.status == MessageStatus.sending && m.contentType == newMessage.contentType);

        final updatedMessages = List<ChatbotMessage>.from(currentState.messages);

        if (tempMessageIndex != -1) {
          // Se encontrou uma mensagem temporária, substitui pela final
          updatedMessages[tempMessageIndex] = newMessage;
        } else {
          // Senão, apenas adiciona a nova mensagem no topo
          updatedMessages.insert(0, newMessage);
        }

        emit(currentState.copyWith(messages: updatedMessages));
      }
    });


  }

  Future<void> sendMessage(String textContent) async {
    // ✅ CORREÇÃO 1: Removemos a lógica de UI Otimista daqui.
    // A mensagem não é mais adicionada à UI antes de ser enviada.
    // Ela só aparecerá quando o servidor confirmar e enviar de volta via WebSocket.

    // Apenas envia a mensagem de verdade para o repositório.
    await _chatRepository.sendMessage(storeId: storeId, chatId: chatId, textContent: textContent);
  }

// Em lib/cubits/chat/chat_panel_cubit.dart

  Future<void> uploadAndSendMedia(File file, String mediaType, {String? caption}) async {
    if (state is! ChatPanelLoaded) return;

    final currentState = state as ChatPanelLoaded;

    // 1. Cria uma mensagem temporária com status "sending"
    final tempMessage = ChatbotMessage(
      id: -1, // ID temporário
      storeId: storeId,
      messageUid: DateTime.now().millisecondsSinceEpoch.toString(), // UID temporário
      chatId: chatId,
      senderId: 'me', // Identificador local
      contentType: mediaType,
      textContent: caption,
      isFromMe: true,
      timestamp: DateTime.now(),
      status: MessageStatus.sending, // <-- O status importante
      localFile: file,              // <-- O arquivo local para o preview
    );

    // 2. Adiciona a mensagem temporária à UI imediatamente
    final optimisticMessages = [tempMessage, ...currentState.messages];
    emit(currentState.copyWith(messages: optimisticMessages));

    // 3. Inicia o processo de upload e envio em segundo plano
    final uploadResult = await _chatRepository.uploadMedia(storeId: storeId, file: file);

    uploadResult.fold(
          (failure) {
        // Se falhar, você pode atualizar a mensagem temporária para um status de erro
        // ou simplesmente removê-la. Por simplicidade, vamos apenas logar o erro.
        debugPrint('Falha no upload: ${failure.message}');
        // TODO: Implementar lógica para mostrar erro na UI
      },
          (mediaUrl) {
        // Se o upload funcionou, envia a mensagem com a URL da mídia
        _chatRepository.sendMessage(
          storeId: storeId,
          chatId: chatId,
          textContent: caption,
          mediaUrl: mediaUrl,
          mediaType: mediaType,
          mediaFilename: file.path.split('/').last,
        );
        // Não precisamos remover a mensagem temporária aqui. O WebSocket
        // trará a mensagem final e a lógica de "não duplicar"
        // no _listenForRealtimeMessages irá lidar com a substituição.
      },
    );
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}