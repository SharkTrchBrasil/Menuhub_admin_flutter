import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/models/chatbot_message.dart';
import 'package:totem_pro_admin/pages/chatpanel/widgets/pdf_thumbnail.dart';
import 'package:totem_pro_admin/pages/chatpanel/widgets/pdf_viewer_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'audio_player_bubble.dart';

class MessageBubble extends StatelessWidget {
  final ChatbotMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isFromMe = message.isFromMe;
    final alignment = isFromMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = isFromMe
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary.withOpacity(0.2);
    final textColor = isFromMe ? Colors.white : Colors.black;

    return Align(
      alignment: alignment,
      child: Container(
        constraints:
        BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ CORREÇÃO 1: Passamos 'isFromMe' como parâmetro aqui.
            _buildMessageContent(context, textColor, isFromMe),
            const SizedBox(height: 4),
            Text(
              DateFormat('HH:mm').format(message.timestamp.toLocal()),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: textColor.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }


// Dentro da classe MessageBubble
  Widget _buildMessageContent(BuildContext context, Color textColor, bool isFromMe) {

    Widget mediaWidget; // Widget para a miniatura

    switch (message.contentType) {

      case 'image':
      // Se a mensagem tiver um status 'sending' e um arquivo local
        if (message.status == MessageStatus.sending && message.localFile != null) {
          mediaWidget = _buildSendingImagePlaceholder(message.localFile!);
        } else {
          mediaWidget = CachedNetworkImage(
            imageUrl: message.mediaUrl!,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
          break;
        }

      case 'sticker': // Adicione este case
        mediaWidget = CachedNetworkImage(
          imageUrl: message.mediaUrl!,
          width: 150, // Tamanho fixo para figurinhas
          height: 150,
        );
        break;

      case 'document':
        mediaWidget = PdfThumbnail(pdfUrl: message.mediaUrl!);
        break;
      case 'audio':
        return AudioPlayerBubble(url: message.mediaUrl!, isFromMe: isFromMe);
      case 'text':
      default:
        return Text(message.textContent ?? '', style: TextStyle(color: textColor));
    }

    // ✅ LÓGICA ATUALIZADA:
    // Envolve a miniatura da mídia em um container clicável
    return InkWell(
      onTap: () {
        if (message.contentType == 'document') {
          // Para PDFs, abre a tela de visualização completa que já tínhamos
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => PdfViewerScreen(pdfUrl: message.mediaUrl!),
          ));
        } else if (message.contentType == 'image') {
          // Para imagens, abre um Dialog para visualização ampliada
          showDialog(
            context: context,
            builder: (_) => Dialog(
              child: InteractiveViewer( // Permite zoom e pan
                child: CachedNetworkImage(imageUrl: message.mediaUrl!),
              ),
            ),
          );
        }
      },
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 250, // Limita a altura da miniatura
        ),
        child: ClipRRect( // Adiciona bordas arredondadas
            borderRadius: BorderRadius.circular(8),
            child: mediaWidget
        ),
      ),
    );
  }












// Adicione um novo widget para o estado de envio de imagem
  Widget _buildSendingImagePlaceholder(File imageFile) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Mostra a imagem local com opacidade
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            imageFile,
            fit: BoxFit.cover,
            color: Colors.white.withOpacity(0.5), // Efeito de "carregando"
            colorBlendMode: BlendMode.dstATop,
          ),
        ),
        // Coloca um indicador de progresso sobre a imagem
        const CircularProgressIndicator(),
      ],
    );
  }





}