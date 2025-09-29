// lib/features/chat/widgets/chat_popup_manager.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/models/chatbot_conversation.dart';
import 'package:totem_pro_admin/models/chatbot_message.dart';
import 'package:totem_pro_admin/pages/chatpanel/chat_panel_screen.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';

import '../../../../core/di.dart';
import '../../../../services/chat_visibility_service.dart';
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

  // ✅ 2. Obtenha a instância do serviço
  final _visibilityService = getIt<ChatVisibilityService>();


  @override
  void initState() {
    super.initState();
    _listenForNewMessages();
    _visibilityService.isCentralPanelVisible.addListener(
        _onCentralPanelVisibilityChanged);
  }

  void _listenForNewMessages() {
    _newMessageSubscription =
        getIt<RealtimeRepository>().onNewChatMessage.listen((message) {
          // A lógica anterior que verifica se a central está aberta continua válida
          if (_visibilityService.isCentralPanelVisible.value) {
            return;
          }
          _openChatForNewMessage(message);
        });
  }

  void _onCentralPanelVisibilityChanged() {
    // Se o painel central se tornou visível, feche todos os popups.
    if (_visibilityService.isCentralPanelVisible.value) {
      _closeAllPopups();
    }
  }

  // ✅ 4. Crie a função para fechar todos os popups
  void _closeAllPopups() {
    // Verifica se há popups para evitar reconstruções desnecessárias
    if (_activePopups.isNotEmpty) {
      setState(() {
        _activePopups.clear();
      });
    }
  }






  void _openChatForNewMessage(ChatbotMessage message) {
    final existingIndex = _activePopups.indexWhere((popup) => popup.chatId == message.chatId);

    if (existingIndex >= 0) {
      // Chat já existe - traz para frente
      _bringToFront(message.chatId);
    } else {
      // Novo chat
      setState(() {
        final newPopup = ChatPopup(
          storeId: message.storeId,
          chatId: message.chatId,
          customerName: message.customerName ?? 'Cliente',
          isMinimized: !_canExpandMorePopups, // ✅ Se não tem espaço, já cria minimizado
          hasUnreadMessage: true,
        );

        _activePopups.add(newPopup);
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
      // Chat existe - traz para frente
      _bringToFront(chatId);
    } else {
      // Novo chat
      setState(() {
        _activePopups.add(ChatPopup(
          storeId: storeId,
          chatId: chatId,
          customerName: customerName,
          isMinimized: !_canExpandMorePopups, // ✅ Se não tem espaço, já cria minimizado
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


  List<ChatPopup> get _expandedPopups =>
      _activePopups
          .where((popup) => !popup.isMinimized)
          .toList();

  List<ChatPopup> get _minimizedPopups =>
      _activePopups
          .where((popup) => popup.isMinimized)
          .toList();

  bool get _canExpandMorePopups => _expandedPopups.length < 2;

  void _bringToFront(String chatId) {
    setState(() {
      final index = _activePopups.indexWhere((popup) => popup.chatId == chatId);
      if (index >= 0) {
        final popup = _activePopups.removeAt(index);

        if (_canExpandMorePopups) {
          // Se ainda tem espaço para expandir, apenas expande
          _activePopups.add(popup.copyWith(
            hasUnreadMessage: false,
            isMinimized: false,
          ));
        } else {
          // Se já tem 2 expandidos, troca com o mais antigo
          final oldestExpanded = _expandedPopups.first;
          final oldestIndex = _activePopups.indexWhere((p) =>
          p.chatId == oldestExpanded.chatId);

          if (oldestIndex >= 0) {
            // Minimiza o mais antigo
            _activePopups[oldestIndex] =
                oldestExpanded.copyWith(isMinimized: true);
            // Expande o novo
            _activePopups.add(popup.copyWith(
              hasUnreadMessage: false,
              isMinimized: false,
            ));
          }
        }
      }
    });
  }




  @override
  void dispose() {
    _newMessageSubscription?.cancel();
    _visibilityService.isCentralPanelVisible.removeListener(
        _onCentralPanelVisibilityChanged);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final expandedPopups = _expandedPopups;
    final minimizedPopups = _minimizedPopups;

    return Stack(
      children: [
        widget.child,

        // ✅ POPUPS EXPANDIDOS (máximo 2) - ORGANIZAÇÃO HORIZONTAL
        if (expandedPopups.isNotEmpty) ...[
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery
                    .of(context)
                    .size
                    .height * 0.8,
              ),
              child: Wrap(
                direction: Axis.horizontal,
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: 8,
                children: [
                  for (int i = 0; i < expandedPopups.length; i++)
                    ChatPopupWidget(
                      key: ValueKey(expandedPopups[i].chatId),
                      popup: expandedPopups[i],
                      width: _popupWidth,
                      expandedHeight: _popupHeight,
                      minimizedHeight: _minimizedHeight,
                      onMinimize: _minimizeChat,
                      onClose: _closeChat,
                      onTap: _bringToFront,
                      isTopmost: i == expandedPopups.length - 1,
                    ),
                ],
              ),
            ),
          ),
        ],

        // ✅ POPUPS MINIMIZADOS (bolinhas) - ORGANIZAÇÃO VERTICAL
        if (minimizedPopups.isNotEmpty) ...[
          Positioned(
            bottom: expandedPopups.isNotEmpty ? _popupHeight + 16 : 0,
            right: 8,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery
                    .of(context)
                    .size
                    .height * 0.6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < minimizedPopups.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _MinimizedChatHead(
                        popup: minimizedPopups[i],
                        onTap: _bringToFront,
                        onClose: _closeChat,
                      ),
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



class _MinimizedChatHead extends StatefulWidget {
  final ChatPopup popup;
  final Function(String) onTap;
  final Function(String) onClose;

  const _MinimizedChatHead({
    required this.popup,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<_MinimizedChatHead> createState() => _MinimizedChatHeadState();
}

class _MinimizedChatHeadState extends State<_MinimizedChatHead> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onTap(widget.popup.chatId),
        child: Stack(
          children: [
            // Bolinha do chat minimizado
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: widget.popup.hasUnreadMessage ? Colors.red : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.popup.customerName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),

                  // Badge de mensagens não lidas
                  if (widget.popup.hasUnreadMessage)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Botão de fechar (aparece no hover)
            if (_isHovered)
              Positioned(
                top: -5,
                right: -5,
                child: GestureDetector(
                  onTap: () => widget.onClose(widget.popup.chatId),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}