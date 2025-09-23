// lib/pages/chatbot/chatbot_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ✅ 1. Importe o novo cubit e estado

import 'package:totem_pro_admin/pages/chatbot/widgets/connected.dart';
import 'package:totem_pro_admin/pages/chatbot/widgets/dialog_coffirmation.dart';
import 'package:totem_pro_admin/pages/chatbot/widgets/not_connect.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';

import 'cubit/chatbot_cubit.dart';
import 'cubit/chatbot_state.dart';

class ChatbotPage extends StatelessWidget {
  final int storeId;
  const ChatbotPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    // ✅ 2. Ouve o ChatbotCubit
    return BlocListener<ChatbotCubit, ChatbotState>(
      // ✅ 3. A condição fica mais simples e robusta
      listenWhen: (previous, current) {
        // Mostra o diálogo quando o estado muda de "não conectado" para "conectado"
        return previous is! ChatbotConnected && current is ChatbotConnected;
      },
      listener: (context, state) {
        showDialog(
          context: context,
          builder: (_) => const WhatsAppConfirmationDialog(),
        );
      },
      // ✅ 4. Constrói a UI com base no estado do ChatbotCubit
      child: BlocBuilder<ChatbotCubit, ChatbotState>(
        builder: (context, state) {
          // ✅ 5. A lógica de decisão é baseada no TIPO do estado, não em strings
          if (state is ChatbotConnected) {
            return ChatbotConnectedScreen(storeId: storeId);
          }

          if (state is ChatbotInitial || state is ChatbotLoading) {
            return const Center(child: DotLoading());
          }

          // Para os estados ChatbotDisconnected, ChatbotAwaitingQr, ChatbotError
          return ChatbotEmpty(storeId: storeId);
        },
      ),
    );
  }
}