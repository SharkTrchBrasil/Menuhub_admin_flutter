import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/create_complement_cbit.dart';

// Enum para controlar a opção selecionada
enum AddGroupOption { create, copy }

class AddGroupPanel extends StatefulWidget {
  const AddGroupPanel({super.key,});


  @override
  State<AddGroupPanel> createState() => _AddGroupPanelState();
}

class _AddGroupPanelState extends State<AddGroupPanel> {
  // Estado para controlar qual radio button está selecionado
  AddGroupOption _selectedOption = AddGroupOption.create;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24.0),
      // Usamos uma Column para empilhar todo o conteúdo
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- CABEÇALHO ---
          const Text(
            "Grupo de complementos",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Crie um novo grupo de complementos ou copie um que já existe no seu cardápio",
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // --- OPÇÕES SELECIONÁVEIS ---
          _buildOptionCard(
            title: "Criar novo grupo",
            subtitle: "Você cria um grupo novo, definindo informações gerais e quais serão os complementos.",
            icon: Icons.add_circle_outline,
            value: AddGroupOption.create,
          ),
          const SizedBox(height: 16),
          _buildOptionCard(
            title: "Copiar grupo",
            subtitle: "Você reaproveita um grupo que já possui em seu cardápio e a gestão fica mais fácil!",
            icon: Icons.link,
            value: AddGroupOption.copy,
            tag: _buildTag(), // Tag "mais prático"
          ),

          // Espaçador para empurrar o botão para o final
          const Spacer(),

          // --- BOTÃO DE AÇÃO NO FINAL ---
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final cubit = context.read<CreateComplementGroupCubit>();

                // ✅ Lógica finalizada e correta
                if (_selectedOption == AddGroupOption.create) {
                  // Inicia o fluxo de criação (indo para o Passo 1: Selecionar Tipo)
                  cubit.startCreateNewFlow();
                } else {
                  // Inicia o fluxo de cópia
                  cubit.startCopyExistingFlow();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text("Continuar"),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget auxiliar para criar o Tag "mais prático"
  Widget _buildTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "mais prático",
        style: TextStyle(
          color: Colors.green.shade800,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Widget auxiliar e reutilizável para criar os cartões de opção
  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required AddGroupOption value,
    Widget? tag,
  }) {
    final bool isSelected = _selectedOption == value;

    return InkWell(
      onTap: () => setState(() => _selectedOption = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.grey.shade700, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      if (tag != null) tag,
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            Radio<AddGroupOption>(
              value: value,
              groupValue: _selectedOption,
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() => _selectedOption = newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}