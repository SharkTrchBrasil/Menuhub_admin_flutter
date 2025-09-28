import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/chatbot_message.dart';
import 'message_bubble.dart';

class MessageList extends StatelessWidget {
  final List<ChatbotMessage> messages;

  const MessageList({Key? key, required this.messages}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true, // Essencial para o chat
      padding: const EdgeInsets.all(8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        return MessageBubble(message: messages[index]);
      },
    );
  }
}