import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';

import '../../../models/store_chatbot_message.dart';
import '../../../widgets/ds_primary_button.dart';
import '../cubit/chatbot_cubit.dart';
import '../cubit/chatbot_state.dart';
import 'edit_message_bottom_sheet.dart';

class ChatbotConnectedScreen extends StatefulWidget {
  const ChatbotConnectedScreen({super.key, required this.storeId});
  final int storeId;

  @override
  State<ChatbotConnectedScreen> createState() => _ChatbotConnectedScreenState();
}

class _ChatbotConnectedScreenState extends State<ChatbotConnectedScreen> {
  StoreChatbotMessage? _selectedMessage;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }


  // ✅ CORREÇÃO: A lógica do BottomSheet agora usa um Widget dedicado com um callback.
  void _openEditBottomSheet(StoreChatbotMessage message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        // O builder agora simplesmente retorna o nosso novo widget.
        return EditMessageBottomSheet(
          message: message,
          // E aqui definimos a AÇÃO que o botão Salvar vai executar.
          // Esta função tem acesso ao `context` correto da página.
          onSave: (String newContent) {
            context.read<ChatbotCubit>().updateMessageContent(
              message.templateKey,
              newContent,
            );
            Navigator.pop(context); // Fecha o BottomSheet
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mensagem salva com sucesso!')),
            );
          },
        );
      },
    );
  }











  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: BlocBuilder<ChatbotCubit, ChatbotState>(
        builder: (context, state) {
          if (state is! ChatbotConnected) {
            return const Center(
              child: DotLoading(

              ),
            );
          }

          final chatbotMessages = state.messages;
          if (chatbotMessages.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.message, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'Nenhuma mensagem configurada',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final messageGroups = groupBy(
            chatbotMessages,
                (StoreChatbotMessage msg) => msg.template.messageGroup,
          );



          if (_selectedMessage != null) {
            _selectedMessage = chatbotMessages.firstWhereOrNull(
                  (m) => m.templateKey == _selectedMessage!.templateKey,
            );
          }

          // Lógica de seleção inicial (continua ótima)
          _selectedMessage ??= chatbotMessages.firstWhereOrNull(
                (msg) => msg.templateKey == 'welcome_message',
          ) ?? chatbotMessages.first;



          final bool isMobile = MediaQuery.of(context).size.width < 768;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header estilo iFood
                  _buildHeader(isMobile),
                  const SizedBox(height: 24),

                  // Conteúdo principal
                  Expanded(
                    child: isMobile
                        ? _buildMobileLayout(messageGroups, context)
                        : _buildDesktopLayout(messageGroups),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chatbot WhatsApp',
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Gerencie as mensagens automáticas',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (!isMobile) _buildDisconnectButton(),
          ],
        ),
        if (isMobile) ...[
          const SizedBox(height: 16),
          _buildDisconnectButton(),
        ],
      ],
    );
  }

  Widget _buildDisconnectButton() {
    return SizedBox(
      height: 40,
      child: FilledButton.icon(
        onPressed: () => context.read<ChatbotCubit>().disconnectChatbot(),
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red[700],
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        icon: const Icon(Icons.link_off, size: 16),
        label: const Text('Desvincular'),
      ),
    );
  }

  Widget _buildDesktopLayout(Map<String, List<StoreChatbotMessage>> messageGroups) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lista de templates
        Expanded(
          flex: 2,
          child: _buildMessageList(messageGroups, null),
        ),
        const SizedBox(width: 20),

        // Preview/Edição
        Expanded(
          flex: 3,
          child: _buildMessagePreview(),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Map<String, List<StoreChatbotMessage>> messageGroups, BuildContext context) {
    return _buildMessageList(messageGroups, context);
  }

  Widget _buildMessageList(Map<String, List<StoreChatbotMessage>> messageGroups, BuildContext? mobileContext) {
    return ListView(
      children: [
        ...messageGroups.entries.map((entry) {
          return _buildMessageGroupCard(entry.key, entry.value, mobileContext);
        }).toList(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMessageGroupCard(String title, List<StoreChatbotMessage> messages, BuildContext? mobileContext) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade300, // Mais claro e sutil
          width: 0.5, // Linha bem fina
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(),

              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,

                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de mensagens
          ...messages.map((message) => _buildMessageItem(message, mobileContext)),
        ],
      ),
    );
  }

  Widget _buildMessageItem(StoreChatbotMessage message, BuildContext? mobileContext) {
    final bool isSelected = _selectedMessage?.templateKey == message.templateKey;
    final bool isMobile = mobileContext != null;

    return Container(
      decoration: BoxDecoration(
        border: isSelected && !isMobile
            ? Border(left: BorderSide(color: Theme.of(context).primaryColor , width: 4))
            : null,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          child: Icon(
            _getMessageIcon(message.templateKey),
            size: 20,
            color: isSelected && !isMobile ? Colors.black : Colors.grey[600],
          ),
        ),
        title: Text(
          message.template.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color:Colors.black87,
            fontSize: 15,
          ),
        ),
        subtitle: message.template.description != null
            ? Text(
          message.template.description!,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        )
            : null,
        trailing: Switch(
          value: message.isActive,
          onChanged: (newValue) {
            context.read<ChatbotCubit>().toggleMessageActive(
              message.templateKey,
              newValue,
            );
          },

        ),
        onTap: () {
          if (isMobile) {
            _openEditBottomSheet(message); // Apenas chama a função
          } else {
            setState(() {
              _selectedMessage = message;
              // ✅ A atualização do controller acontece aqui, em resposta a um evento.
              _textEditingController.text = message.finalContent;
            });
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }

  // ✅ AJUSTE 3: Adicionado um `default` para segurança
  IconData _getMessageIcon(String templateKey) {
    switch (templateKey) {
      case 'welcome_message':
        return Icons.waving_hand_outlined;
      case 'absence_message': // Nome antigo era out_of_business_hours
        return Icons.access_time_rounded;
      case 'order_received':
      case 'order_accepted':
      case 'order_ready':
      case 'order_on_route':
      case 'order_arrived':
      case 'order_delivered':
      case 'order_finalized':
      case 'order_cancelled':
        return Icons.receipt_long_outlined;
      case 'request_review':
        return Icons.star_outline_rounded;
      case 'abandoned_cart':
        return Icons.shopping_cart_checkout_rounded;
      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }


  Widget _buildMessagePreview() {
    if (_selectedMessage == null) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.message, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Selecione uma mensagem para editar',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final message = _selectedMessage!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300, // Mais claro e sutil
          width: 0.5, // Linha bem fina
        ),

      ),









      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),

                  child: const Icon(Icons.edit, color: Colors.black, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Editando: ${message.template.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Descrição
            if (message.template.description != null) ...[
              Text(
                message.template.description!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Campo de edição
            TextFormField(
              controller: _textEditingController,
              maxLines: 6,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                hintText: 'Digite a mensagem...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.restart_alt),
                  tooltip: 'Restaurar padrão',
                  onPressed: () {
                    setState(() {
                      _textEditingController.text = message.template.defaultContent;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Variáveis disponíveis
            Text(
              'Variáveis disponíveis:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: message.template.availableVariables.map((variable) {
                return GestureDetector(
                  onTap: () => _insertVariable(variable),
                  child: Container(
               //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(

                      border: Border.all(
                        color: Colors.grey.shade300, // Mais claro e sutil
                        width: 0.5, // Linha bem fina
                      ),

                      borderRadius: BorderRadius.circular(8),

                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '{$variable}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Botão de salvar
            Align(
              alignment: Alignment.centerRight,
              child: DsButton(
                onPressed: () {
                  context.read<ChatbotCubit>().updateMessageContent(
                    message.templateKey,
                    _textEditingController.text,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Mensagem salva com sucesso!'),
                      backgroundColor: const Color(0xFF2E7D32),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },

                label: 'Salvar Alterações',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _insertVariable(String variable) {
    final text = _textEditingController.text;
    final selection = _textEditingController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      '{$variable}',
    );
    _textEditingController.text = newText;
    _textEditingController.selection = TextSelection.collapsed(
      offset: selection.start + variable.length + 2,
    );
  }

}