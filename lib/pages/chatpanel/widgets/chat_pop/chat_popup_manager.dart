// lib/features/chat/widgets/chat_popup_manager.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/chatbot_conversation.dart';
import 'package:totem_pro_admin/models/chatbot_message.dart';
import 'package:totem_pro_admin/pages/chatpanel/chat_panel_screen.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';

import '../../../../core/di.dart';
import 'chat_popup_widget.dart';

class ChatPopupManager extends StatefulWidget {
  final Widget child;

  const ChatPopupManager({Key? key, required this.child}) : super(key: key);

  @override
  State<ChatPopupManager> createState() => _ChatPopupManagerState();

  static _ChatPopupManagerState? of(BuildContext context) {
    return context.findAncestorStateOfType<_ChatPopupManagerState>();
  }
}

class _ChatPopupManagerState extends State<ChatPopupManager> {
  final List<ChatPopup> _activePopups = [];
  final double _popupWidth = 320;
  final double _popupHeight = 450;
  final double _minimizedHeight = 64;
  StreamSubscription? _newMessageSubscription;

  @override
  void initState() {
    super.initState();
    _listenForNewMessages();
  }

  void _listenForNewMessages() {
    // Ouve novas mensagens em tempo real
    _newMessageSubscription = getIt<RealtimeRepository>().onNewChatMessage.listen((message) {
      // Abre popup automaticamente para novas mensagens
      _openChatForNewMessage(message);
    });
  }

  void _openChatForNewMessage(ChatbotMessage message) {
    // Verifica se o chat já está aberto
    final existingIndex = _activePopups.indexWhere((popup) => popup.chatId == message.chatId);

    if (existingIndex >= 0) {
      // Se já existe, apenas atualiza e traz para frente
      setState(() {
        final existing = _activePopups.removeAt(existingIndex);
        _activePopups.add(existing.copyWith(
          hasUnreadMessage: true,
          isMinimized: false,
        ));
      });
    } else {
      // Cria novo popup para a conversa
      setState(() {
        _activePopups.add(ChatPopup(
          storeId: message.storeId,
          chatId: message.chatId,
          customerName: message.customerName ?? 'Cliente',
          isMinimized: false,
          hasUnreadMessage: true,
        ));
      });
    }
  }

  void openChat({
    required int storeId,
    required String chatId,
    required String customerName,
  }) {
    final existingIndex = _activePopups.indexWhere((popup) => popup.chatId == chatId);

    if (existingIndex >= 0) {
      setState(() {
        final existing = _activePopups.removeAt(existingIndex);
        _activePopups.add(existing.copyWith(
          isMinimized: false,
          hasUnreadMessage: false, // Marca como lida ao abrir
        ));
      });
    } else {
      setState(() {
        _activePopups.add(ChatPopup(
          storeId: storeId,
          chatId: chatId,
          customerName: customerName,
          isMinimized: false,
          hasUnreadMessage: false,
        ));
      });
    }
  }

  void _minimizeChat(String chatId) {
    setState(() {
      final index = _activePopups.indexWhere((popup) => popup.chatId == chatId);
      if (index >= 0) {
        _activePopups[index] = _activePopups[index].copyWith(isMinimized: true);
      }
    });
  }

  void _closeChat(String chatId) {
    setState(() {
      _activePopups.removeWhere((popup) => popup.chatId == chatId);
    });
  }

  void _bringToFront(String chatId) {
    setState(() {
      final index = _activePopups.indexWhere((popup) => popup.chatId == chatId);
      if (index >= 0) {
        final popup = _activePopups.removeAt(index);
        _activePopups.add(popup.copyWith(hasUnreadMessage: false));
      }
    });
  }

  @override
  void dispose() {
    _newMessageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Popups de chat no canto inferior direito
        if (_activePopups.isNotEmpty) ...[
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: _popupWidth,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < _activePopups.length; i++)
                    ChatPopupWidget(
                      key: ValueKey(_activePopups[i].chatId),
                      popup: _activePopups[i],
                      width: _popupWidth,
                      expandedHeight: _popupHeight,
                      minimizedHeight: _minimizedHeight,
                      onMinimize: _minimizeChat,
                      onClose: _closeChat,
                      onTap: _bringToFront,
                      isTopmost: i == _activePopups.length - 1,
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

@immutable
class ChatPopup {
  final int storeId;
  final String chatId;
  final String customerName;
  final bool isMinimized;
  final bool hasUnreadMessage;

  const ChatPopup({
    required this.storeId,
    required this.chatId,
    required this.customerName,
    required this.isMinimized,
    this.hasUnreadMessage = false,
  });

  ChatPopup copyWith({
    bool? isMinimized,
    bool? hasUnreadMessage,
  }) {
    return ChatPopup(
      storeId: storeId,
      chatId: chatId,
      customerName: customerName,
      isMinimized: isMinimized ?? this.isMinimized,
      hasUnreadMessage: hasUnreadMessage ?? this.hasUnreadMessage,
    );
  }
}