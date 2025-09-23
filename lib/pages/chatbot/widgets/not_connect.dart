import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubits/store_manager_cubit.dart';
import '../cubit/chatbot_cubit.dart';
import '../cubit/chatbot_state.dart';
import 'dialog_cconnect.dart';



// lib/pages/chatbot/widgets/not_connect.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';

class ChatbotEmpty extends StatelessWidget {
  const ChatbotEmpty({super.key, required this.storeId});

  final int storeId;

  @override
  Widget build(BuildContext context) {
    // ✅ O WIDGET AGORA OUVE O ESTADO COM UM BLOCBUILDER
    return BlocBuilder<ChatbotCubit, ChatbotState>(
      builder: (context, state) {
        // ✅ 3. A lógica para extrair status e qrCode fica muito mais limpa
        String status = 'disconnected';
        String? qrCode;

        if (state is ChatbotAwaitingQr) {
          status = 'awaiting_qr';
          qrCode = state.qrCode;
        } else if (state is ChatbotLoading) {
          status = 'pending';
        } else if (state is ChatbotError) {
          status = 'error';
        }


        return Scaffold(
          backgroundColor: const Color(0xFFF0F0F0),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final bool isMobile = constraints.maxWidth < 600;
              final bool isTablet = constraints.maxWidth < 900;

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16.0 : 24.0, vertical: isMobile ? 8.0 : 16.0),
                  child: Column(
                    children: [
                      SizedBox(height: isMobile ? 8 : 16),
                      // Passamos o status para a seção principal, que decidirá o que mostrar
                      _buildMainSection(isMobile, isTablet, context, status, qrCode),
                      SizedBox(height: isMobile ? 16 : 24),
                      _buildStepsSection(isMobile, isTablet),
                      SizedBox(height: isMobile ? 16 : 24),
                      _buildMessagesSection(isMobile),
                      SizedBox(height: isMobile ? 16 : 24),
                      _buildFAQSection(isMobile),
                      SizedBox(height: isMobile ? 16 : 32),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ✅ A SEÇÃO PRINCIPAL AGORA RECEBE O STATUS E O QRCODE
  Widget _buildMainSection(bool isMobile, bool isTablet, BuildContext context, String status, String? qrCode) {
    bool isConnecting = status == 'pending' || status == 'awaiting_qr' || status == 'error';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: isMobile
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMainContent(context, status, qrCode), // Passa os dados para o conteúdo
            SizedBox(height: isMobile ? 16 : 24),
            _buildMainImage(isMobile), // A imagem continua no mobile
          ],
        )
            : Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isTablet ? 1 : 2,
              child: _buildMainContent(context, status, qrCode), // Lado esquerdo com o conteúdo
            ),
            SizedBox(width: isTablet ? 16 : 24),
            Expanded(
              flex: isTablet ? 1 : 2,
              // ✅ LÓGICA CONDICIONAL: Mostra a imagem OU o QR Code no desktop
              child: isConnecting
                  ? _buildQRCodeDisplay(context, status, qrCode)
                  : _buildMainImage(isMobile),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ O CONTEÚDO PRINCIPAL AGORA MOSTRA O BOTÃO OU O QRCODE NO MOBILE
  Widget _buildMainContent(BuildContext context, String status, String? qrCode) {
    bool isConnecting = status == 'pending' || status == 'awaiting_qr' || status == 'error';
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chatbot WhatsApp da OlaClick', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('Uma ferramenta poderosa para vender e responder...', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 16),
        _buildFeatureRow('Mensagens automáticas totalmente editáveis.'),
        _buildFeatureRow('Respostas instantâneas e inteligentes...'),
        _buildFeatureRow('Informações chave do seu negócio 24/7...'),
        const SizedBox(height: 32),

        // ✅ LÓGICA CONDICIONAL: Mostra o botão OU o QR Code/Loading
        if (isMobile && isConnecting)
          _buildQRCodeDisplay(context, status, qrCode) // No mobile, o QR Code aparece aqui
        else if (!isConnecting)
          SizedBox( // No desktop, ou se não estiver conectando, mostra o botão
            width: 300,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<ChatbotCubit>().connectWhatsApp();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF28B84F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.chat, size: 20),
              label: const Text('Vincular Chatbot do WhatsApp', style: TextStyle(fontSize: 16)),
            ),
          ),
      ],
    );
  }

  // ✅ NOVO WIDGET REUTILIZÁVEL PARA MOSTRAR O QR CODE / LOADING / ERRO
  Widget _buildQRCodeDisplay(BuildContext context, String status, String? qrCode) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _getTitleForStatus(status),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 200,
          height: 200,
          child: _buildContentForStatus(context, status, qrCode),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () =>  context.read<ChatbotCubit>().disconnectChatbot(),
          icon: const Icon(Icons.cancel_outlined, color: Colors.grey),
          label: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
        )
      ],
    );
  }

  String _getTitleForStatus(String status) {
    switch (status) {
      case 'awaiting_qr': return 'Escaneie para conectar';
      case 'error': return 'Falha na Conexão';
      default: return 'Iniciando conexão...';
    }
  }

  Widget _buildContentForStatus(BuildContext context, String status, String? qrCode) {
    switch (status) {
      case 'awaiting_qr':
        if (qrCode != null && qrCode.isNotEmpty) {
          return QrImageView(data: qrCode, version: QrVersions.auto, size: 200);
        }
        return const Center(child: DotLoading());
      case 'error':
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text('Não foi possível conectar.', textAlign: TextAlign.center),
          ],
        );
      default:
        return const Center(child: DotLoading());
    }
  }


  Widget _buildMainImage(bool isMobile) {
    return Stack(
      children: [
        Container(
          height: isMobile ? 200 : 300,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              Icons.image,
              size: 50,
              color: Colors.grey[600],
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '+2,000 😍',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text('Clientes felizes'),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '4.8 to 5 ⭐',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text('Avaliações'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFCCE1FF),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.check,
              size: 16,
              color: Color(0xFF0A131F),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsSection(bool isMobile, bool isTablet) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: isMobile
            ? Column(
          children: [
            _buildStep(
              Icons.settings,
              '1.',
              'Vincule seu Chatbot ao WhatsApp',
              'De maneira fácil e rápida',
              isMobile,
            ),
            SizedBox(height: isMobile ? 24 : 32),
            _buildStep(
              Icons.chat_bubble,
              '2.',
              'Responda automaticamente aos seus clientes',
              'Economize tempo! O Chatbot faz isso por você.',
              isMobile,
            ),
            SizedBox(height: isMobile ? 24 : 32),
            _buildStep(
              Icons.trending_up,
              '3.',
              'Aumente suas vendas',
              'Ganhe até 5 vezes mais!',
              isMobile,
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildStep(
                Icons.settings,
                '1.',
                'Vincule seu Chatbot ao WhatsApp',
                'De maneira fácil e rápida',
                isMobile,
              ),
            ),
            SizedBox(width: isTablet ? 16 : 24),
            Expanded(
              child: _buildStep(
                Icons.chat_bubble,
                '2.',
                'Responda automaticamente aos seus clientes',
                'Economize tempo! O Chatbot faz isso por você.',
                isMobile,
              ),
            ),
            SizedBox(width: isTablet ? 16 : 24),
            Expanded(
              child: _buildStep(
                Icons.trending_up,
                '3.',
                'Aumente suas vendas',
                'Ganhe até 5 vezes mais!',
                isMobile,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(IconData icon, String number, String title, String subtitle, bool isMobile) {
    return Column(
      children: [
        Container(
          width: isMobile ? 70 : 84,
          height: isMobile ? 70 : 84,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: isMobile ? 30 : 40, color: Colors.blue),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: isMobile ? 4 : 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: isMobile ? 12 : 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessagesSection(bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mensagens automáticas do Chatbot',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 12),
            Text(
              'Com seu complemento ativado, você poderá personalizar essas mensagens automáticas de acordo com suas necessidades.',
              style: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
            SizedBox(height: isMobile ? 16 : 24),
            // Categorias de mensagens
            _buildMessageCategory(
              'Recuperador de Vendas',
              [
                'Carrinho abandonado',
                'Desconto para novos clientes',
              ],
              isMobile,
            ),
            _buildMessageCategory(
              'Resolva as perguntas dos seus clientes',
              [
                'Mensagem de boas-vindas',
                'Mensagem de ausência',
                'Mensagem para fazer um pedido',
                'Mensagem de promoções',
                'Mensagem de informação',
                'Mensagem de horário de funcionamento',
              ],
              isMobile,
            ),
            _buildMessageCategory(
              'Obtenha avaliações dos seus clientes',
              [
                'Solicitar uma avaliação',
              ],
              isMobile,
            ),
            _buildMessageCategory(
              'Ative seu programa de fidelidade',
              [
                'Mensagem do Programa de Fidelidade',
              ],
              isMobile,
            ),
            _buildMessageCategory(
              'Envie atualizações automáticas do pedido',
              [
                'Pedido recebido',
                'Pedido aceito',
                'Pedido pronto',
                'Pedido a caminho',
                'Pedido chegou',
                'Pedido entregue',
                'Pedido finalizado',
                'Pedido cancelado',
              ],
              isMobile,
            ),
            Center(
              child: TextButton(
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver mais mensagens',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, size: isMobile ? 20 : 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCategory(String title, List<String> messages, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: isMobile ? 12.0 : 16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...messages.map((message) => _buildMessageItem(message, isMobile)).toList(),
      ],
    );
  }

  Widget _buildMessageItem(String title, bool isMobile) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: isMobile ? 14 : 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.arrow_drop_down, color: Colors.blue),
      contentPadding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 8),
    );
  }

  Widget _buildFAQSection(bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
            child: Text(
              'Perguntas Frequentes',
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildFAQItem(
            'O que é um Chatbot do WhatsApp?',
            Icons.help_outline,
            'Um chatbot do WhatsApp é uma IA que simula conversas reais, permitindo respostas automáticas e oportunas aos seus clientes através de texto, a qualquer momento.',
            isMobile,
          ),
          _buildFAQItem(
            'Como funciona o Chatbot do WhatsApp?',
            Icons.settings,
            'Quando um cliente envia uma mensagem pelo WhatsApp, o chatbot responde automaticamente com mensagens de boas-vindas ou ausência, oferecendo informações sobre seu negócio e permitindo contato direto.',
            isMobile,
          ),
          _buildFAQItem(
            'Por que usar um Chatbot do WhatsApp?',
            Icons.thumb_up,
            'Os chatbots do WhatsApp automatizam respostas, imitam o comportamento humano e economizam tempo, permitindo interações rápidas e eficientes com seus clientes.',
            isMobile,
          ),
          _buildFAQItem(
            'Posso usar meu próprio número de telefone com o Chatbot do WhatsApp?',
            Icons.phone,
            'Sim, você pode usar seu número de telefone atual. Não é necessário obter outro número.',
            isMobile,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String title, IconData icon, String description, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 8 : 16),
              Icon(icon, size: isMobile ? 32 : 40, color: Colors.blue),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            description,
            style: TextStyle(fontSize: isMobile ? 13 : 15),
          ),
        ],
      ),
    );
  }
}