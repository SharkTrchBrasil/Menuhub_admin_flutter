// lib/models/chat_panel_initial_state.dart
import 'package:totem_pro_admin/models/order_details.dart';
import 'chatbot_message.dart';

class ChatPanelInitialState {
  final List<ChatbotMessage> messages;
  final OrderDetails? activeOrder;

  ChatPanelInitialState({required this.messages, this.activeOrder});

  factory ChatPanelInitialState.fromJson(Map<String, dynamic> json) {
    return ChatPanelInitialState(
      messages: (json['messages'] as List)
          .map((msg) => ChatbotMessage.fromJson(msg))
          .toList(),
      activeOrder: json['active_order'] != null
          ? OrderDetails.fromJson(json['active_order'])
          : null,
    );
  }
}