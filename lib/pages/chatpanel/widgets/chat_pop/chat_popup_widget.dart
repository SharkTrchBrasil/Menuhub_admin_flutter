// lib/features/chat/widgets/chat_popup_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/pages/chatpanel/chat_panel_screen.dart';
import 'package:totem_pro_admin/pages/chatpanel/widgets/order_context_panel.dart';

import '../../../../repositories/chat_repository.dart';
import '../../../../repositories/realtime_repository.dart';
import '../../cubit/chat_panel_cubit.dart';
import '../../cubit/chat_panel_state.dart';
import '../chat_input_field.dart';
import '../message_list.dart';
import 'chat_popup_manager.dart';

class ChatPopupWidget extends StatefulWidget {
  final ChatPopup popup;
  final double width;
  final double expandedHeight;
  final double minimizedHeight;
  final Function(String) onMinimize;
  final Function(String) onClose;
  final Function(String) onTap;
  final bool isTopmost;

  const ChatPopupWidget({
    Key? key,
    required this.popup,
    required this.width,
    required this.expandedHeight,
    required this.minimizedHeight,
    required this.onMinimize,
    required this.onClose,
    required this.onTap,
    required this.isTopmost,
  }) : super(key: key);

  @override
  State<ChatPopupWidget> createState() => _ChatPopupWidgetState();
}

class _ChatPopupWidgetState extends State<ChatPopupWidget> {
  bool _isHovered = false;
  bool _showOrderMenu = false;

  @override
  Widget build(BuildContext context) {
    // ✅ 1. Crie o Cubit aqui para que todo o widget possa acessá-lo
    return Material(

      child: BlocProvider(
        create: (context) => ChatPanelCubit(
          storeId: widget.popup.storeId,
          chatId: widget.popup.chatId,
          chatRepository: GetIt.I<ChatRepository>(),
          realtimeRepository: GetIt.I<RealtimeRepository>(),
        )..initialize(),
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedContainer(
              // ... (seu AnimatedContainer)
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: widget.width,
              height: widget.popup.isMinimized
                  ? widget.minimizedHeight
                  : widget.expandedHeight,
              // ... (decoração)
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // ✅ 2. Use um BlocBuilder para construir a UI com base no estado
                child: BlocBuilder<ChatPanelCubit, ChatPanelState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        // Cabeçalho agora pode receber o estado
                        _buildHeader(state),
                        // Mostra o painel do pedido apenas se expandido e se houver um pedido
                        if (!widget.popup.isMinimized &&
                            state is ChatPanelLoaded &&
                            state.activeOrder != null)
                          OrderContextPanel(order: state.activeOrder),
                        // Conteúdo principal
                        if (!widget.popup.isMinimized)
                          Expanded(
                            // O ChatPanelScreen agora pode ser mais simples,
                            // apenas a lista de mensagens e o input.
                            child: _buildChatBody(state),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }





  Widget _buildHeader(ChatPanelState state) {

    String subtitle = 'Carregando...';
    if (state is ChatPanelLoaded && state.activeOrder != null) {
      subtitle = 'Pedido #${state.activeOrder!.publicId}';
    } else if (state is ChatPanelLoaded) {
      subtitle = 'Nenhum pedido ativo';
    }



    return Material(
      type: MaterialType.transparency,
      child: Container(
        height: 48,
        color: Theme.of(context).primaryColor,
        child: Row(
          children: [
            // Avatar e nome - AGORA É CLICÁVEL PARA RESTAURAR

            Expanded(
              child: InkWell(
                onTap: () {
                  if (widget.popup.isMinimized) {
                    // Se estiver minimizado, restaura ao clicar no cabeçalho
                    widget.onTap(widget.popup.chatId);
                  } else {
                    // Se estiver expandido, alterna o menu de pedido
                    setState(() => _showOrderMenu = !_showOrderMenu);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      // Indicador de mensagem não lida
                      if (widget.popup.hasUnreadMessage) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Text(
                          widget.popup.customerName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.popup.customerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!widget.popup.isMinimized)
                              Text(
                                'Toque para ver pedido',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Botões de controle

            if (_isHovered || widget.isTopmost) ...[
              IconButton(
                icon: Icon(
                  // ✅ CORREÇÃO: Ícones invertidos para a lógica correta
                  widget.popup.isMinimized ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: () {
                  if (widget.popup.isMinimized) {
                    // Se minimizado, chama onTap (que agora é _bringToFront e restaura)
                    widget.onTap(widget.popup.chatId);
                  } else {
                    // Se expandido, chama onMinimize
                    widget.onMinimize(widget.popup.chatId);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 18),
                onPressed: () => widget.onClose(widget.popup.chatId),
              ),
            ],
          ],
        ),
      ),
    );
  }


  // ✅ 4. O corpo do chat
  Widget _buildChatBody(ChatPanelState state) {
    if (state is ChatPanelLoaded) {
      // Reutilize seus widgets aqui
      return Column(
        children: [
          Expanded(child: MessageList(messages: state.messages)),
          ChatInputField(),
        ],
      );
    }
    if (state is ChatPanelError) return Center(child: Text(state.message));
    return const Center(child: CircularProgressIndicator());
  }



  Widget _buildOrderMenu() {
    // Simulação de dados do pedido - você precisará integrar com seu cubit real
    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pedido Ativo: #12345',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text('Status: Preparando', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: const Text('Ver Pedido'),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: const Text('Marcar Pronto'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}