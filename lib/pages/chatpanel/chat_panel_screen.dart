import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/pages/chatpanel/widgets/chat_input_field.dart';
import 'package:totem_pro_admin/pages/chatpanel/widgets/message_list.dart';
import 'package:totem_pro_admin/pages/chatpanel/widgets/order_context_panel.dart';

import 'package:totem_pro_admin/repositories/chat_repository.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';

import 'cubit/chat_panel_cubit.dart';
import 'cubit/chat_panel_state.dart';

class ChatPanelScreen extends StatelessWidget {
  final int storeId;
  final String chatId;
  final String customerName;

  const ChatPanelScreen({
    Key? key,
    required this.storeId,
    required this.chatId,
    required this.customerName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatPanelCubit(
        storeId: storeId,
        chatId: chatId,
        chatRepository: GetIt.I<ChatRepository>(),
        realtimeRepository: GetIt.I<RealtimeRepository>(),
      )..initialize(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Conversa com $customerName'),
        ),
        body: BlocBuilder<ChatPanelCubit, ChatPanelState>(
          builder: (context, state) {
            if (state is ChatPanelLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ChatPanelError) {
              return Center(child: Text('Erro: ${state.message}'));
            }
            if (state is ChatPanelLoaded) {
              return Column(
                children: [
                  OrderContextPanel(order: state.activeOrder),
                  Expanded(child: MessageList(messages: state.messages)),
                  ChatInputField(),
                ],
              );
            }
            return const Center(child: Text('Iniciando chat...'));
          },
        ),
      ),
    );
  }
}