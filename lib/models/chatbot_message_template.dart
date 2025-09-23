// lib/models/chatbot_message_template.dart

class ChatbotMessageTemplate {
  final String messageKey;
  final String name;
  final String? description;
  final String messageGroup;
  final String defaultContent;
  final List<String> availableVariables;

  ChatbotMessageTemplate({
    required this.messageKey,
    required this.name,
    this.description,
    required this.messageGroup,
    required this.defaultContent,
    this.availableVariables = const [],
  });

  factory ChatbotMessageTemplate.fromJson(Map<String, dynamic> json) {
    return ChatbotMessageTemplate(
      messageKey: json['message_key'],
      name: json['name'],
      description: json['description'],
      messageGroup: json['message_group'],
      defaultContent: json['default_content'],
      availableVariables: List<String>.from(json['available_variables'] ?? []),
    );
  }
}