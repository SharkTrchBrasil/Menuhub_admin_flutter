// lib/features/chat/widgets/conversations_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';

import 'package:totem_pro_admin/models/chatbot_conversation.dart';

import '../../../cubits/store_manager_state.dart';

// Este é o callback que será chamado quando o usuário tocar em uma conversa.
// Ele passará a conversa selecionada para o widget pai.
typedef OnConversationSelected = void Function(ChatbotConversation conversation);

class ConversationsList extends StatelessWidget {
  final OnConversationSelected onConversationSelected;
  final ChatbotConversation? selectedConversation;

  const ConversationsList({
    Key? key,
    required this.onConversationSelected,
    this.selectedConversation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ouve o StoreManagerCubit para obter a lista de conversas
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          // Mostra um indicador de carregamento se o estado principal não estiver carregado
          return const Center(child: CircularProgressIndicator());
        }

        final conversations = state.conversations;

        if (conversations.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Nenhuma conversa recente encontrada.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // Constrói a lista
        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final convo = conversations[index];

            // ✅ LÓGICA ROBUSTA PARA EVITAR OS "PONTOS"
            // Garante que a prévia nunca seja nula e tenha um fallback.
            final preview = convo.lastMessagePreview?.isNotEmpty == true
                ? convo.lastMessagePreview!
                : '(Sem prévia)';

            return ListTile(
              selected: selectedConversation?.chatId == convo.chatId,
              selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
            leading: CircleAvatar(
            // ✅ LÓGICA ATUALIZADA
            backgroundImage: convo.profilePicUrl != null
            ? NetworkImage(convo.profilePicUrl!)
                : null,
            child: convo.profilePicUrl == null
            ? Text((convo.customerName ?? '?')[0].toUpperCase())
                : null,
            ),
              title: Text(convo.customerName ?? 'Cliente Desconhecido'),
              subtitle: Text(
                preview,
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // Garante os "..." para textos longos
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(DateFormat('HH:mm').format(convo.lastMessageTimestamp.toLocal())),
                  const SizedBox(height: 4),
                  if (convo.unreadCount > 0)
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        '${convo.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
              onTap: () => onConversationSelected(convo),
            );
          },
        );
      },
    );
  }
}