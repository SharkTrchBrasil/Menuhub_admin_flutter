import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';

import '../cubit/chatbot_cubit.dart';
import '../cubit/chatbot_state.dart';

class ChatbotEmpty extends StatelessWidget {
  const ChatbotEmpty({super.key, required this.storeId, required this.phoneStore});

  final int storeId;
  final String phoneStore;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatbotCubit, ChatbotState>(
      builder: (context, state) {
        String status = 'disconnected';
        String? qrCode;
        String? pairingCode;

        if (state is ChatbotAwaitingQr) {
          status = 'awaiting_qr';
          qrCode = state.qrCode;
          pairingCode = state.pairingCode;
        } else if (state is ChatbotLoading) {
          status = 'pending';
        } else if (state is ChatbotError) {
          status = 'error';
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final bool isMobile = constraints.maxWidth < 600;

              return Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: EdgeInsets.all(isMobile ? 20 : 32),
                  child: SingleChildScrollView(

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ícone principal
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat_outlined,
                            size: 40,
                            color: Color(0xFF25D366),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Título
                        Text(
                          'Chatbot WhatsApp',
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),

                        // Descrição
                        Text(
                          'Conecte seu WhatsApp para automatizar atendimentos e aumentar suas vendas',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // AQUI É O LOCAL DA SUBSTITUIÇÃO
                        Builder(builder: (context) {
                          // QR Code, Código de Conexão ou Botão de Conexão
                          if (status == 'awaiting_qr') {
                            if (pairingCode != null) {
                              // Se tiver um código de pareamento, mostra ele
                              return _buildPairingCodeSection(context, pairingCode, isMobile);
                            } else if (qrCode != null) {
                              // Senão, se tiver um QR Code, mostra ele
                              return _buildQRCodeSection(context, qrCode, isMobile);
                            } else {
                              // Fallback para o botão de conectar se não tiver nenhum código
                              return _buildConnectButton(context, isMobile, phoneStore);
                            }
                          } else if (status == 'pending' || status == 'error') {
                            return _buildLoadingOrError(context, status, isMobile);
                          } else {
                            return _buildConnectButton(context, isMobile, phoneStore);
                          }
                        }),

                        const SizedBox(height: 24),

                        // Status indicator
                        _buildStatusIndicator(status, isMobile),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildQRCodeSection(BuildContext context, String qrCode, bool isMobile) {
    return Column(
      children: [
        Text(
          'Escaneie o QR Code',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: QrImageView(
            data: qrCode,
            version: QrVersions.auto,
            size: isMobile ? 200 : 250,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          '1. Abra o WhatsApp\n2. Toque em ⋮ → Dispositivos vinculados\n3. Toque em Vincular um dispositivo',
          style: TextStyle(
            fontSize: isMobile ? 14 : 15,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        TextButton(
          onPressed: () => context.read<ChatbotCubit>().disconnectChatbot(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOrError(BuildContext context, String status, bool isMobile) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: status == 'error'
              ? const Icon(
            Icons.error_outline,
            size: 50,
            color: Colors.red,
          )
              : const DotLoading(),
        ),

        const SizedBox(height: 16),

        Text(
          status == 'error' ? 'Falha na conexão' : 'Conectando...',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: status == 'error' ? Colors.red : Colors.black87,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          status == 'error'
              ? 'Não foi possível conectar. Tente novamente.'
              : 'Preparando conexão com WhatsApp...',
          style: TextStyle(
            fontSize: isMobile ? 14 : 15,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),

        if (status == 'pending') ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.read<ChatbotCubit>().disconnectChatbot(),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],

        if (status == 'error') ...[
          const SizedBox(height: 16),
          _buildConnectButton(context, isMobile, phoneStore),
        ],
      ],
    );
  }


  Widget _buildConnectButton(BuildContext context, bool isMobile, String phoneStore) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Lógica de responsividade para chamar o método correto
          if (isMobile) {
            // Se for mobile, usa o método de pareamento com o número de telefone
            context.read<ChatbotCubit>().connectWhatsApp(
              method: 'pairing',
              phoneNumber: phoneStore,
            );
          } else {
            // Se for desktop, usa o método de QR Code
            context.read<ChatbotCubit>().connectWhatsApp(
              method: 'qr',
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF25D366),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: isMobile ? 16 : 18,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat, size: 20),
            const SizedBox(width: 8),
            Text(
              'Conectar WhatsApp',
              style: TextStyle(
                fontSize: isMobile ? 16 : 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String status, bool isMobile) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'awaiting_qr':
        color = Colors.orange;
        text = 'Aguardando conexão'; // Texto genérico
        icon = Icons.qr_code;
        break;
      case 'pending':
        color = Colors.blue;
        text = 'Conectando...';
        icon = Icons.refresh;
        break;
      case 'error':
        color = Colors.red;
        text = 'Conexão falhou';
        icon = Icons.error_outline;
        break;
      default:
        color = Colors.grey;
        text = 'Não conectado';
        icon = Icons.circle_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPairingCodeSection(BuildContext context, String pairingCode, bool isMobile) {
    // Formata o código para "XXXX-XXXX"
    final formattedCode = pairingCode.length == 8
        ? '${pairingCode.substring(0, 4)}-${pairingCode.substring(4)}'
        : pairingCode;

    return Column(
      children: [
        Text(
          'Conectar com o número de telefone',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'No seu celular, abra o WhatsApp, vá para Dispositivos Vinculados e escolha "Conectar com número de telefone". Depois, insira o código abaixo:',
          style: TextStyle(
            fontSize: isMobile ? 14 : 15,
            color: Colors.grey.shade600,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            formattedCode,
            style: TextStyle(
              fontSize: isMobile ? 28 : 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF25D366),
              letterSpacing: 4,
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => context.read<ChatbotCubit>().disconnectChatbot(),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}