import 'dart:io';

import 'package:equatable/equatable.dart';


enum MessageStatus { sending, sent, failed }


class ChatbotMessage extends Equatable {
  final int id;
  final int storeId;
  final String messageUid;
  final String chatId;
  final String senderId;
  final String contentType;
  final String? textContent;
  final String? mediaUrl;
  final String? mediaMimeType;
  final bool isFromMe;
  final DateTime timestamp;
  final String? customerName; // ✅ CAMPO ADICIONADO
  // ✅ 3. Adicione os novos campos opcionais
  final MessageStatus? status;
  final File? localFile; // Para guardar o arquivo local durante o upload

  const ChatbotMessage({
    required this.id,
    required this.storeId,
    required this.messageUid,
    required this.chatId,
    required this.senderId,
    required this.contentType,
    this.textContent,
    this.mediaUrl,
    this.mediaMimeType,
    required this.isFromMe,
    required this.timestamp,
    this.customerName, // ✅ CAMPO ADICIONADO
    this.status = MessageStatus.sent, // Define 'sent' como padrão
    this.localFile,
  });

  factory ChatbotMessage.fromJson(Map<String, dynamic> json) {
    return ChatbotMessage(
      id: json['id'],
      storeId: json['store_id'],
      messageUid: json['message_uid'],
      chatId: json['chat_id'],
      senderId: json['sender_id'],
      contentType: json['content_type'],
      textContent: json['text_content'],
      mediaUrl: json['media_url'],
      mediaMimeType: json['media_mime_type'],
      isFromMe: json['is_from_me'],
      timestamp: DateTime.parse(json['timestamp']),
      customerName: json['customer_name'], // ✅ CAMPO ADICIONADO
    );
  }

  @override
  List<Object?> get props => [id, messageUid];
}