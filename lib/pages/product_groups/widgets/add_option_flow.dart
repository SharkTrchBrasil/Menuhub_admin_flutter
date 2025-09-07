// lib/pages/product_groups/widgets/add_option_flow.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import '../cubit/create_complement_cubit.dart';
import 'complement_copy_list.dart';
import 'complement_creation_form.dart';

// Enum para controlar o modo interno
enum AddOptionMode { choice, create, copy }

class AddOptionFlow extends StatefulWidget {
  // Callbacks para comunicar o resultado para quem o chamou
  final Function(VariantOption) onOptionCreated;
  final VoidCallback onCancel;

  const AddOptionFlow({
    super.key,
    required this.onOptionCreated,
    required this.onCancel,
  });

  @override
  State<AddOptionFlow> createState() => _AddOptionFlowState();
}

class _AddOptionFlowState extends State<AddOptionFlow> {
  AddOptionMode _mode = AddOptionMode.choice;

  void _changeMode(AddOptionMode newMode) {
    setState(() => _mode = newMode);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _buildPanelBody(),
    );
  }

  Widget _buildPanelBody() {
    switch (_mode) {
      case AddOptionMode.choice:
        return _buildChoiceUI();
      case AddOptionMode.create:
        return ComplementCreationForm(
          onCancel: () => _changeMode(AddOptionMode.choice),
          onOptionCreated: widget.onOptionCreated,
        );
      case AddOptionMode.copy:
        return ComplementCopyList(
          onBack: () => _changeMode(AddOptionMode.choice),
          // A lógica de adicionar os itens copiados já está no Cubit e no botão do ComplementCopyList
        );
    }
  }

  Widget _buildChoiceUI() {
    return Column(
      key: const ValueKey('choice'),
      children: [
        _buildChoiceCard(
          context: context,
          title: "Criar novo complemento",
          subtitle: "Crie um item do zero, definindo nome, preço e foto.",
          icon: Icons.add_circle_outline,
          onTap: () => _changeMode(AddOptionMode.create),
        ),
        const SizedBox(height: 16),
        _buildChoiceCard(
          context: context,
          title: "Copiar complemento existente",
          subtitle: "Reaproveite produtos ou itens que já existem no seu cardápio.",
          icon: Icons.copy_all_outlined,
          onTap: () => _changeMode(AddOptionMode.copy),
        ),
      ],
    );
  }

  // Widget auxiliar para os cards de escolha
  Widget _buildChoiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}