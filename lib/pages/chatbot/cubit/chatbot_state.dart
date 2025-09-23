// lib/cubits/chatbot/chatbot_state.dart
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/store_chatbot_config.dart';
import 'package:totem_pro_admin/models/store_chatbot_message.dart';

abstract class ChatbotState extends Equatable {
  const ChatbotState();
  @override
  List<Object?> get props => [];
}

class ChatbotInitial extends ChatbotState {}

class ChatbotLoading extends ChatbotState {}

class ChatbotAwaitingQr extends ChatbotState {
  final String? qrCode;
  const ChatbotAwaitingQr({this.qrCode});
  @override
  List<Object?> get props => [qrCode];
}

// Estado quando está conectado com sucesso
class ChatbotConnected extends ChatbotState {
  final StoreChatbotConfig config;
  final List<StoreChatbotMessage> messages;

  const ChatbotConnected({required this.config, required this.messages});

  @override
  List<Object?> get props => [config, messages];

  // ✅ CORREÇÃO: O método copyWith foi movido para DENTRO da classe.
  ChatbotConnected copyWith({
    StoreChatbotConfig? config,
    List<StoreChatbotMessage>? messages,
  }) {
    return ChatbotConnected(
      config: config ?? this.config,
      messages: messages ?? this.messages,
    );
  }
}

class ChatbotDisconnected extends ChatbotState {}

class ChatbotError extends ChatbotState {
  final String message;
  const ChatbotError(this.message);
  @override
  List<Object?> get props => [message];
}