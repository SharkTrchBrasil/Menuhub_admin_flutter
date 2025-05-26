// models/store_chatbot_config.dart
class StoreChatBotConfig {
  final int id;
  final int storeId;
  final String? whatsappNumber;
  final String? whatsappName;
  final String? connectionStatus;
  final String? lastQrCode;
  final DateTime? lastConnectedAt;
  final String? sessionPath;

  StoreChatBotConfig({
    required this.id,
    required this.storeId,
    this.whatsappNumber,
    this.whatsappName,
    this.connectionStatus,
    this.lastQrCode,
    this.lastConnectedAt,
    this.sessionPath,
  });

  factory StoreChatBotConfig.fromJson(Map<String, dynamic> json) {
    return StoreChatBotConfig(
      id: json['id'],
      storeId: json['store_id'],
      whatsappNumber: json['whatsapp_number'],
      whatsappName: json['whatsapp_name'],
      connectionStatus: json['connection_status'],
      lastQrCode: json['last_qr_code'],
      lastConnectedAt: json['last_connected_at'] != null
          ? DateTime.parse(json['last_connected_at'])
          : null,
      sessionPath: json['session_path'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'whatsapp_number': whatsappNumber,
      'whatsapp_name': whatsappName,
      'connection_status': connectionStatus,
      'last_qr_code': lastQrCode,
      'last_connected_at': lastConnectedAt?.toIso8601String(),
      'session_path': sessionPath,
    };
  }
}
