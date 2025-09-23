import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/store_chatbot_message.dart';
import '../../../widgets/ds_primary_button.dart';
import '../cubit/chatbot_cubit.dart';




class EditMessageBottomSheet extends StatefulWidget {
  const EditMessageBottomSheet({
    super.key,
    required this.message,
    required this.onSave,
  });

  final StoreChatbotMessage message;
  final void Function(String newContent) onSave;

  @override
  State<EditMessageBottomSheet> createState() => _EditMessageBottomSheetState();
}

class _EditMessageBottomSheetState extends State<EditMessageBottomSheet> {
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.message.finalContent);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
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


  @override
  Widget build(BuildContext context) {
    // Este `context` é o do BottomSheet, que não precisa saber sobre o Cubit.
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
         // borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child:  Column(
          mainAxisSize: MainAxisSize.min, // Essencial para o sheet não ocupar a tela toda
          children: [
            // Handle (a barrinha cinza no topo)
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.message.template.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Conteúdo rolável
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.message.template.description != null) ...[
                      Text(widget.message.template.description!, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _textEditingController,
                      maxLines: 8,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.grey[50],
                        hintText: 'Digite a mensagem...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.restart_alt),
                          tooltip: 'Restaurar padrão',
                          onPressed: () => _textEditingController.text = widget.message.template.defaultContent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Variáveis disponíveis:', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700], fontSize: 14)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.message.template.availableVariables.map((variable) => GestureDetector(
                        onTap: () => _insertVariable(variable),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('{$variable}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: DsButton(
                            onPressed: () => Navigator.pop(context),
                            style: DsButtonStyle.secondary,
                            requiresConnection: false,
                            label: 'Cancelar',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DsButton(
                            onPressed: () {
                              // ✅ CORREÇÃO FINAL: Apenas chama o callback!
                              // O BottomSheet não sabe o que acontece, ele apenas envia os dados para o pai.
                              widget.onSave(_textEditingController.text);
                            },
                            label: 'Salvar',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

      ),
    );
  }
}