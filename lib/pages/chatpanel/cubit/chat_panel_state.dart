// lib/cubits/chat/chat_panel_state.dart
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/chatbot_message.dart';
import 'package:totem_pro_admin/models/order_details.dart';

abstract class ChatPanelState extends Equatable {
  const ChatPanelState();
  @override
  List<Object?> get props => [];
}

class ChatPanelInitial extends ChatPanelState {}
class ChatPanelLoading extends ChatPanelState {}

class ChatPanelError extends ChatPanelState {
  final String message;
  const ChatPanelError(this.message);
  @override
  List<Object?> get props => [message];
}

class ChatPanelLoaded extends ChatPanelState {
  final List<ChatbotMessage> messages;
  final OrderDetails? activeOrder;

  const ChatPanelLoaded({required this.messages, this.activeOrder});

  @override
  List<Object?> get props => [messages, activeOrder];

  ChatPanelLoaded copyWith({
    List<ChatbotMessage>? messages,
    OrderDetails? activeOrder,
  }) {
    return ChatPanelLoaded(
      messages: messages ?? this.messages,
      activeOrder: activeOrder ?? this.activeOrder,
    );
  }
}