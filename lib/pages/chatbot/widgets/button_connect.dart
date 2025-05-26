import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/chatbot_config_provider.dart';


class ConnectWhatsAppButton extends StatelessWidget {
  final int storeId;

  const ConnectWhatsAppButton({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final controller = context.read<ChatBotConfigController>();

    return ElevatedButton.icon(
      onPressed: () async {
        await controller.connectWhatsApp(storeId);
      },
      icon: const Icon(Icons.qr_code),
      label: const Text('Conectar WhatsApp'),
    );
  }
}
