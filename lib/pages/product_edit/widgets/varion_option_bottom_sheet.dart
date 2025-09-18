import 'package:flutter/material.dart';
import 'package:totem_pro_admin/pages/product_edit/widgets/variant_callbacks.dart';
import 'package:totem_pro_admin/pages/product_edit/widgets/variant_link_card.dart';

import '../../../models/variant_option.dart';
import 'edit_option_form.dart';


class OptionActionsBottomSheet extends StatefulWidget {
  final VariantOption option;
  final OnOptionUpdated onUpdated;
  final OnOptionRemoved onRemoved;

  const OptionActionsBottomSheet({super.key,
    required this.option,
    required this.onUpdated,
    required this.onRemoved,
  });

  @override
  State<OptionActionsBottomSheet> createState() => OptionActionsBottomSheetState();
}

class OptionActionsBottomSheetState extends State<OptionActionsBottomSheet> {
  bool _isEditing = false;

  void _handleRemove() {
    Navigator.of(context).pop(); // Fecha o bottom sheet
    widget.onRemoved(widget.option); // Chama o callback de remoção
  }

  void _handleUpdate(VariantOption updatedOption) {
    Navigator.of(context).pop(); // Fecha o bottom sheet
    widget.onUpdated(updatedOption); // Chama o callback de atualização
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        // Padding para o teclado não cobrir os campos
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isEditing
              ? EditOptionForm(
            key: const ValueKey('edit_form'),
            option: widget.option,
            onConfirm: _handleUpdate,
            onCancel: () => setState(() => _isEditing = false),
          )
              : _buildActionsMenu(key: const ValueKey('actions_menu')),
        ),
      ),
    );
  }

  Widget _buildActionsMenu({Key? key}) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.edit_outlined),
          title: const Text('Editar complemento'),
          onTap: () => setState(() => _isEditing = true),
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.red),
          title: const Text('Remover do grupo', style: TextStyle(color: Colors.red)),
          onTap: _handleRemove,
        ),
      ],
    );
  }
}
