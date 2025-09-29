// lib/models/store_chatbot_message.dart



import '../chatbot_message_template.dart';

class StoreChatbotMessage {
  final String templateKey;
  final bool isActive;
  final String finalContent; // Conteúdo final a ser usado
  final ChatbotMessageTemplate template;
  final String? customContent; // ✅ CAMPO ADICIONADO

  StoreChatbotMessage({
    required this.templateKey,
    required this.isActive,
    required this.finalContent,
    required this.template,
    this.customContent, // ✅ CAMPO ADICIONADO
  });

  factory StoreChatbotMessage.fromJson(Map<String, dynamic> json) {
    return StoreChatbotMessage(
      templateKey: json['template_key'],
      isActive: json['is_active'],
      finalContent: json['final_content'],
      template: ChatbotMessageTemplate.fromJson(json['template']),
      customContent: json['custom_content'], // ✅ CAMPO ADICIONADO
    );
  }

  // ✅ MÉTODO copyWith ADICIONADO
  /// Cria uma cópia deste objeto, permitindo a substituição de alguns campos.
  StoreChatbotMessage copyWith({
    String? templateKey,
    bool? isActive,
    String? finalContent,
    ChatbotMessageTemplate? template,
    String? customContent,
  }) {
    return StoreChatbotMessage(
      templateKey: templateKey ?? this.templateKey,
      isActive: isActive ?? this.isActive,
      finalContent: finalContent ?? this.finalContent,
      template: template ?? this.template,
      customContent: customContent ?? this.customContent,
    );
  }
}