// lib/models/chatbot_conversation.dart

import 'package:equatable/equatable.dart';

class ChatbotConversation extends Equatable {
  final String chatId;
  final int storeId;
  final String? customerName;
  final String? lastMessagePreview;
  final DateTime lastMessageTimestamp;
  final int unreadCount;
  final String? profilePicUrl;

  const ChatbotConversation({
    required this.chatId,
    required this.storeId,
    this.customerName,
    this.lastMessagePreview,
    required this.lastMessageTimestamp,
    required this.unreadCount,
    this.profilePicUrl,
  });

  factory ChatbotConversation.fromJson(Map<String, dynamic> json) {
    return ChatbotConversation(
      chatId: json['chat_id'],
      storeId: json['store_id'],
      customerName: json['customer_name'],
      lastMessagePreview: json['last_message_preview'],
      // ✅ Proteção para timestamp: usa a data atual como fallback se for nulo
      lastMessageTimestamp: json['last_message_timestamp'] != null
          ? DateTime.parse(json['last_message_timestamp'])
          : DateTime.now(),
      unreadCount: json['unread_count'] ?? 0,
      profilePicUrl: json['customer_profile_pic_url'], //
    );
  }

  // O copyWith é muito útil para atualizar o estado no Cubit
  ChatbotConversation copyWith({
    String? chatId,
    int? storeId,
    String? customerName,
    String? lastMessagePreview,
    DateTime? lastMessageTimestamp,
    int? unreadCount,
  }) {
    return ChatbotConversation(
      chatId: chatId ?? this.chatId,
      storeId: storeId ?? this.storeId,
      customerName: customerName ?? this.customerName,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
    chatId,
    storeId,
    customerName,
    lastMessagePreview,
    lastMessageTimestamp,
    unreadCount,
  ];
}