import 'package:flutter/material.dart';

import '../../../widgets/confirmation_bottomsheet.dart';


class FilterAndActionsBar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final Set<int> selectedIds;
  final bool isAllSelected;
  final VoidCallback onToggleSelectAll;
  final VoidCallback onActivate;
  final VoidCallback onPause;
  final VoidCallback onDelete;
  final bool isLoading;

  const FilterAndActionsBar({
    required this.onSearchChanged,
    required this.selectedIds,
    required this.isAllSelected,
    required this.onToggleSelectAll,
    required this.onActivate,
    required this.onPause,
    required this.onDelete,
    required this.isLoading,
  });



  // ✅ 1. O MÉTODO AGORA É `async` E ESPERA UM RESULTADO
  Future<void> _showConfirmationAndDelete(BuildContext context) async {
    // `showModalBottomSheet` retorna um `Future` com o valor que passamos no `pop()`
    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) { // Renomeado para `_` para evitar warning
        final count = selectedIds.length;
        return ConfirmationBottomSheet(
          title: 'Remover ${count > 1 ? "$count grupos" : "1 grupo"}',
          message: 'Esta ação não pode ser desfeita. Você tem certeza que deseja remover ${count > 1 ? "os grupos selecionados" : "este grupo"}?',
          cancelButtonText: 'Cancelar',
          confirmButtonText: 'Sim, remover',
        );
      },
    );

    // ✅ 2. SÓ EXECUTA `onDelete` SE O USUÁRIO CONFIRMOU (retornou true)
    if (confirmed == true) {
      onDelete();
    }
  }



  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedIds.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14,),
      child: Column(
        children: [
          SizedBox(height: 24,),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: onSearchChanged, // Não precisamos mais de um controller
                  decoration: InputDecoration(
                    hintText: 'Buscar grupos de complementos',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                ),
              ),

            ],
          ),
          SizedBox(height: 14,),
          if (hasSelection)
            Column(
              children: [
                Row(children:
                _buildActionButtons(context)
                  ,),

                Row(
                  children: [
                    Checkbox(value: isAllSelected, onChanged: (_) => onToggleSelectAll()),
                    const Text('Selecionar todos'),
                  ],
                ),
              ],
            )

        ],
      ),
    );
  }

  // ✅ 7. Botões agora chamam as funções corretas.
  List<Widget> _buildActionButtons(BuildContext context) {
    return [
      TextButton.icon(
        onPressed: onPause,
        icon: const Icon(Icons.pause, color: Colors.orange),
        label: const Text('Pausar', style: TextStyle(color: Colors.orange)),
      ),
      TextButton.icon(
        onPressed: onActivate,
        icon: const Icon(Icons.play_arrow, color: Colors.green),
        label: const Text('Ativar', style: TextStyle(color: Colors.green)),
      ),
      TextButton.icon(
        onPressed: () => _showConfirmationAndDelete(context),
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        label: const Text('Remover', style: TextStyle(color: Colors.red)),
      ),


    ];
  }
}

