// lib/features/chat/widgets/chat_heads_manager.dart
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/chatbot_conversation.dart';

class ChatHeadsManager extends StatefulWidget {
  final Widget child;
  final List<ChatbotConversation> activeConversations;
  final Function(ChatbotConversation) onChatHeadTapped;

  const ChatHeadsManager({
    Key? key,
    required this.child,
    required this.activeConversations,
    required this.onChatHeadTapped,
  }) : super(key: key);

  @override
  State<ChatHeadsManager> createState() => _ChatHeadsManagerState();
}

class _ChatHeadsManagerState extends State<ChatHeadsManager> {
  final List<String> _closedChats = [];

  bool _isChatClosed(String chatId) {
    return _closedChats.contains(chatId);
  }

  void _onChatHeadClosed(String chatId) {
    setState(() {
      _closedChats.add(chatId);
    });
  }

  void _onChatHeadTapped(ChatbotConversation conversation) {
    widget.onChatHeadTapped(conversation);
    // Remove do closed se foi reaberto
    setState(() {
      _closedChats.remove(conversation.chatId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleConversations = widget.activeConversations
        .where((convo) => !_isChatClosed(convo.chatId))
        .toList();

    return Stack(
      children: [
        widget.child,
        // Chat Heads no canto superior direito
        if (visibleConversations.isNotEmpty)
          Positioned(
            top: 80,
            right: 20,
            child: Column(
              children: [
                for (final convo in visibleConversations)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ChatHead(
                      conversation: convo,
                      onTap: () => _onChatHeadTapped(convo),
                      onClose: () => _onChatHeadClosed(convo.chatId),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class ChatHead extends StatefulWidget {
  final ChatbotConversation conversation;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const ChatHead({
    Key? key,
    required this.conversation,
    required this.onTap,
    required this.onClose,
  }) : super(key: key);

  @override
  State<ChatHead> createState() => _ChatHeadState();
}

class _ChatHeadState extends State<ChatHead> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          children: [
            Container(
              width: 60,
              height: 60,
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
                  color: widget.conversation.unreadCount > 0
                      ? Colors.red
                      : Colors.white,
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: widget.conversation.profilePicUrl != null
                        ? NetworkImage(widget.conversation.profilePicUrl!)
                        : null,
                    child: widget.conversation.profilePicUrl == null
                        ? Text(
                      (widget.conversation.customerName ?? '?')[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                        : null,
                  ),
                  // Badge de mensagens não lidas
                  if (widget.conversation.unreadCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          widget.conversation.unreadCount > 9
                              ? '9+'
                              : widget.conversation.unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
                  onTap: widget.onClose,
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