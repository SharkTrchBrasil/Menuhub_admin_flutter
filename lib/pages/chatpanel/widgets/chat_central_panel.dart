// lib/features/chat/widgets/chat_central_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart'; // ✅ Adicione a importação do GetIt
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/chatbot_conversation.dart';
import 'package:totem_pro_admin/repositories/chat_repository.dart'; // ✅ Adicione a importação do repositório

import '../chat_panel_screen.dart';
import 'chat_pop/chat_popup_manager.dart';
import 'conversations_list.dart'; // ✅ Adicione a importação do novo widget

class ChatCentralPanel extends StatefulWidget {
  const ChatCentralPanel({Key? key}) : super(key: key);

  @override
  State<ChatCentralPanel> createState() => _ChatCentralPanelState();
}

class _ChatCentralPanelState extends State<ChatCentralPanel> {
  ChatbotConversation? _selectedConversation;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          return const Center(child: Text('Carregando conversas...'));
        }

        final storeId = state.activeStoreId;

        return Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias, // Garante que o conteúdo respeite as bordas arredondadas
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Row(
              children: [
                // Lado Esquerdo: Lista de Conversas
                SizedBox(
                  width: 320, // Aumentei um pouco a largura para melhor visualização
                  child: ConversationsList( // ✅ SUBSTITUÍMOS O ListView.builder AQUI
                    selectedConversation: _selectedConversation,

                    // // No arquivo chat_central_panel.dart - ATUALIZAR o onConversationSelected
                    // onConversationSelected: (conversation) {
                    //   // Abre no popup em vez de no painel principal
                    //   ChatPopupManager.of(context)?.openChat(
                    //     storeId: storeId,
                    //     chatId: conversation.chatId,
                    //     customerName: conversation.customerName ?? 'Cliente',
                    //   );
                    //
                    //   // Marca como lida
                    //   if (conversation.unreadCount > 0) {
                    //     GetIt.I<ChatRepository>().markAsRead(
                    //       storeId: storeId,
                    //       chatId: conversation.chatId,
                    //     );
                    //     context.read<StoresManagerCubit>().clearUnreadCount(conversation.chatId);
                    //   }
                    // },




                    onConversationSelected: (conversation) {
                      setState(() => _selectedConversation = conversation);
                      // Ao selecionar, marca a conversa como lida
                      if (conversation.unreadCount > 0) {
                        GetIt.I<ChatRepository>().markAsRead(
                          storeId: storeId,
                          chatId: conversation.chatId,
                        );
                        // Opcional: Atualizar o estado no cubit para zerar o contador imediatamente
                        context.read<StoresManagerCubit>().clearUnreadCount(conversation.chatId);
                      }
                    },
                  ),
                ),
                const VerticalDivider(width: 1, thickness: 1),
                // Lado Direito: Conteúdo do Chat
                Expanded(
                  child: _selectedConversation == null
                      ? const Center(child: Text('Selecione uma conversa para começar'))
                      : ChatPanelScreen(
                    key: ValueKey(_selectedConversation!.chatId),
                    storeId: storeId,
                    chatId: _selectedConversation!.chatId,
                    customerName: _selectedConversation!.customerName ?? 'Cliente',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}