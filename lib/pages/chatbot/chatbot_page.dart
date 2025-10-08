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
  final String phoneStore;
  const ChatbotPage({super.key, required this.storeId, required this.phoneStore});

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

          if (state is ChatbotConnected) {
            return ChatbotConnectedScreen(storeId: storeId); //
          }

          if (state is ChatbotInitial) {
            return const Center(child: DotLoading()); //
          }

          return ChatbotEmpty(storeId: storeId, phoneStore: phoneStore,); //
        },
      ),
    );
  }
}