// lib/models/store_chatbot_config.dart

import 'dart:developer';

class StoreChatbotConfig {
  final String? whatsappName;
  final String? connectionStatus;
  final String? qrCode; // ✅ CAMPO ADICIONADO

  StoreChatbotConfig({
    this.whatsappName,
    this.connectionStatus,
    this.qrCode, // ✅ CAMPO ADICIONADO
  });



// store_chatbot_config.dart - Corrigir o nome do campo
  factory StoreChatbotConfig.fromJson(Map<String, dynamic> json) {
    // Tentar ambos os nomes de campo para compatibilidade
    final qrCodeValue = json['qrCode'] ?? json['last_qr_code'];
    return StoreChatbotConfig(
      whatsappName: json['whatsapp_name'],
      connectionStatus: json['connection_status'],
      qrCode: qrCodeValue,
    );
  }
}