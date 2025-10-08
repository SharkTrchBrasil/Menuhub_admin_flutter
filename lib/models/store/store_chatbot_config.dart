import 'package:equatable/equatable.dart';

class StoreChatbotConfig extends Equatable {
  final String? whatsappName;
  final String? connectionStatus;
  final String? qrCode;
  final String? pairingCode;
  final bool isActive;

  const StoreChatbotConfig({
    this.whatsappName,
    this.connectionStatus,
    this.qrCode,
    this.pairingCode,
    required this.isActive,
  });

  factory StoreChatbotConfig.fromJson(Map<String, dynamic> json) {
    return StoreChatbotConfig(
      whatsappName: json['whatsapp_name'],
      connectionStatus: json['connection_status'],
      qrCode: json['qrCode'] ?? json['last_qr_code'],
      pairingCode: json['pairingCode'] ?? json['last_connection_code'],
      isActive: json['is_active'] ?? false,
    );
  }

  // ✅ MÉTODO COPYWITH ADICIONADO
  StoreChatbotConfig copyWith({
    String? whatsappName,
    String? connectionStatus,
    String? qrCode,
    String? pairingCode,
    bool? isActive,
  }) {
    return StoreChatbotConfig(
      whatsappName: whatsappName ?? this.whatsappName,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      qrCode: qrCode ?? this.qrCode,
      pairingCode: pairingCode ?? this.pairingCode,
      isActive: isActive ?? this.isActive,
    );
  }


  @override
  List<Object?> get props => [whatsappName, connectionStatus, qrCode, pairingCode, isActive];
}