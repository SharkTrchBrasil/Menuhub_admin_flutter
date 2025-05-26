import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/pages/chatbot/widgets/button_connect.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/chatbot_config_provider.dart';


class ChatBotConfigPage extends StatefulWidget {
  final int storeId;

  const ChatBotConfigPage({super.key, required this.storeId});

  @override
  State<ChatBotConfigPage> createState() => _ChatBotConfigPageState();
}

class _ChatBotConfigPageState extends State<ChatBotConfigPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ChatBotConfigController>().init(widget.storeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatBotConfigController>();

    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }


    if (controller.config?.connectionStatus == 'connected') {
      return Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          Text('Conectado como: ${controller.config?.whatsappName}'),
        ],
      );
    }else {
      return Container(
      color: Colors.yellow.withOpacity(0.5), // Cor temporária

      child: Column(
        children: [
          const Text('Escaneie o QR Code para conectar seu WhatsApp'),
          const SizedBox(height: 16),
          ConnectWhatsAppButton(storeId: widget.storeId),
          const SizedBox(height: 24),
          if (controller.qrCode != null)
            QrImageView(
              data: controller.qrCode!,
              version: QrVersions.auto,
              size: 200.0,
            )
          else
            const CircularProgressIndicator(),
        ],
      ),
    );
    }

  }
}
