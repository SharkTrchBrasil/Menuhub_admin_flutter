// lib/features/chat/widgets/chat_popup_widget.dart
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/pages/chatpanel/chat_panel_screen.dart';

import 'chat_popup_manager.dart';

class ChatPopupWidget extends StatefulWidget {
  final ChatPopup popup;
  final double width;
  final double expandedHeight;
  final double minimizedHeight;
  final Function(String) onMinimize;
  final Function(String) onClose;
  final Function(String) onTap;
  final bool isTopmost;

  const ChatPopupWidget({
    Key? key,
    required this.popup,
    required this.width,
    required this.expandedHeight,
    required this.minimizedHeight,
    required this.onMinimize,
    required this.onClose,
    required this.onTap,
    required this.isTopmost,
  }) : super(key: key);

  @override
  State<ChatPopupWidget> createState() => _ChatPopupWidgetState();
}

class _ChatPopupWidgetState extends State<ChatPopupWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: widget.width,
          height: widget.popup.isMinimized ? widget.minimizedHeight : widget.expandedHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: widget.popup.hasUnreadMessage
                  ? Colors.red
                  : (widget.isTopmost ? Colors.blue : Colors.grey.shade300),
              width: widget.popup.hasUnreadMessage ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              children: [
                // Cabeçalho do chat
                _buildHeader(),
                // Conteúdo (expandido ou minimizado)
                if (!widget.popup.isMinimized)
                  Expanded(
                    child: ChatPanelScreen(
                      key: ValueKey(widget.popup.chatId),
                      storeId: widget.popup.storeId,
                      chatId: widget.popup.chatId,
                      customerName: widget.popup.customerName,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: 48,
        color: Theme.of(context).primaryColor,
        child: Row(
          children: [
            // Avatar e nome
            Expanded(
              child: InkWell(
                onTap: () => widget.onTap(widget.popup.chatId),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      // Indicador de mensagem não lida
                      if (widget.popup.hasUnreadMessage) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Text(
                          widget.popup.customerName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.popup.customerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Botões de controle
            if (_isHovered || widget.isTopmost) ...[
              IconButton(
                icon: Icon(
                  widget.popup.isMinimized ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () {
                  if (widget.popup.isMinimized) {
                    widget.onTap(widget.popup.chatId);
                  } else {
                    widget.onMinimize(widget.popup.chatId);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                onPressed: () => widget.onClose(widget.popup.chatId),
              ),
            ],
          ],
        ),
      ),
    );
  }
}