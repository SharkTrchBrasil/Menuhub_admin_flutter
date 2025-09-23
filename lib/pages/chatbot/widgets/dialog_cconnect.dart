// lib/pages/chatbot/dialog_cconnect.dart

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';

class WhatsAppConnectionDialog extends StatelessWidget {
  final int storeId;
  final String? initialQrCode; // Recebemos o QR code inicial para evitar um piscar na tela

  const WhatsAppConnectionDialog({super.key, required this.storeId, this.initialQrCode});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cabeçalho da toolbar
            Container(
              height: 40,
              color: Colors.white,
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    color: const Color(0xFF0A131F),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
              ),
            ),

            // Conteúdo principal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Conecte o Chatbot do WhatsApp a partir de um computador',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInstructionList(),
                  const SizedBox(height: 32),
                  // Seção do QR Code agora é dinâmica
                  _buildQRCodeSection(),
                  const SizedBox(height: 24),
                  _buildNoteSection(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildQRCodeSection() {
    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: BlocBuilder<StoresManagerCubit, StoresManagerState>(
          builder: (context, state) {
            if (state is! StoresManagerLoaded) {
              return const CircularProgressIndicator();
            }

            final config = state.activeStore?.relations.chatbotConfig;
            final qrCode = config?.qrCode;

            // ✅ PONTO DE PROVA D
            log("🕵️‍♂️ PONTO D: LEITURA NA UI - Status: ${config?.connectionStatus}, QR Code: $qrCode");

            if (qrCode != null && qrCode.isNotEmpty) {
              log("✅ PONTO D: SUCESSO! Renderizando QrImageView.");
              return QrImageView(
                data: qrCode,
                version: QrVersions.auto,
                size: 200.0,
              );
            } else {
              log("❌ PONTO D: FALHA! QR Code nulo ou vazio. Mostrando loading.");
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }



  Widget _buildInstructionList() {
    // Estilo de texto para manter a consistência
    const textStyle = TextStyle(fontSize: 14, color: Colors.black, height: 1.5);
    const boldStyle = TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.bold);

    // Widget para os ícones, para evitar repetição
    Widget iconContainer(IconData icon) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Instrução 1
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('1. ', style: textStyle),
            const Expanded(
              child: Text(
                'Abra o WhatsApp no seu telefone',
                style: textStyle,
              ),
            ),
            // Use um asset local ou um ícone, Image.network pode ser instável em rebuilds rápidos
            const Icon(Icons.phone_android, size: 24),
          ],
        ),
        const SizedBox(height: 12),

        // Instrução 2 (Refatorada com Wrap para segurança)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('2. ', style: textStyle),
            Expanded(
              child: Wrap( // Usamos Wrap para quebrar a linha se não couber
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4.0, // Espaçamento horizontal
                runSpacing: 4.0, // Espaçamento vertical
                children: [
                  const Text('Clique em', style: textStyle),
                  const Text('menu', style: boldStyle),
                  iconContainer(Icons.more_vert),
                  const Text('ou em', style: textStyle),
                  const Text('Setting', style: boldStyle),
                  iconContainer(Icons.settings_outlined),
                  const Text(', selecione', style: textStyle),
                  const Text('dispositivos conectados', style: boldStyle),
                  const Text('e clique em', style: textStyle),
                  const Text('conectar dispositivos.', style: boldStyle),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Instrução 3
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('3. ', style: textStyle),
            const Expanded(
              child: Text(
                'Quando a câmera estiver ativada, aponte o celular para esta tela para escanear o QR Code',
                style: textStyle,
              ),
            ),
          ],
        ),
      ],
    );
  }




  Widget _buildNoteSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Observação:',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'você pode desconectar o chatbot pelo celular. Para conectá-lo, você vai escanear um QR Code e precisará de outro dispositivo para realizar esta ação (computador ou celular).',
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}