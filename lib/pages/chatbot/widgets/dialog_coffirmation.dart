import 'package:flutter/material.dart';


class WhatsAppConfirmationDialog extends StatelessWidget {
  const WhatsAppConfirmationDialog({super.key});

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
              height: 48,
              color: Colors.white,
              child: Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.black,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Conteúdo principal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Cabeçalho do conteúdo
                  _buildContentHeader(),
                  const SizedBox(height: 16),

                  // Descrição
                  _buildDescription(),
                  const SizedBox(height: 16),

                  // Botões de ação
                  _buildActionButtons(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentHeader() {
    return const Column(
      children: [
        Text(
          'Sua conta do WhatsApp foi vinculada corretamente',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        // Ícone (substitua pelo caminho real da sua imagem)
        Icon(
          Icons.check_circle,
          size: 64,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return const Column(
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Seu Chatbot está ativo. ',
                style: TextStyle(fontSize: 16),
              ),
              TextSpan(
                text: 'Também ativamos para você uma mensagem automática com um cupom de ',
                style: TextStyle(fontSize: 16),
              ),
              TextSpan(
                text: '10% de desconto ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(
                text: 'para aqueles que já fizeram seu primeiro pedido.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Text(
          'Assim, incentivamos que seus clientes voltem a comprar sem que você precise fazer nada.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [

        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006AFF),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Ir para o Chatbot'),
        ),
      ],
    );
  }
}