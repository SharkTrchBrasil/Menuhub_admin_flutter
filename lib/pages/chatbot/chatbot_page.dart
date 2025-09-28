// lib/pages/chatbot/chatbot_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    return BlocListener<ChatbotCubit, ChatbotState>(
      listenWhen: (previous, current) {
        return previous is! ChatbotConnected && current is ChatbotConnected;
      },
      listener: (context, state) {
        showDialog(
          context: context,
          builder: (_) => const WhatsAppConfirmationDialog(),
        );
      },
      child: BlocBuilder<ChatbotCubit, ChatbotState>(
        builder: (context, state) {
          // --- LÓGICA CORRIGIDA AQUI ---

          // 1. Se estiver conectado, mostra a tela principal.
          if (state is ChatbotConnected) {
            return ChatbotConnectedScreen(storeId: storeId); //
          }

          // 2. Se for o estado inicial absoluto, mostra um loading central.
          //    Isso acontece apenas uma vez, antes do primeiro estado real ser emitido.
          if (state is ChatbotInitial) {
            return const Center(child: DotLoading()); //
          }

          // 3. PARA TODOS OS OUTROS ESTADOS (Loading/Pending, AwaitingQr, Disconnected, Error)
          //    nós delegamos a responsabilidade para a tela ChatbotEmpty,
          //    que é mais inteligente.
          return ChatbotEmpty(storeId: storeId); //
        },
      ),
    );
  }
}