import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/responsive_builder.dart';
import '../cubit/create_complement_cubit.dart';
import '../widgets/wizard_footer.dart';

// Enum continua útil para os valores dos RadioButtons
enum AddGroupOption { create, copy }

// ✅ 1. Convertido para StatelessWidget
class Step0InitialChoice extends StatelessWidget {
  const Step0InitialChoice({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 2. Lemos o estado usando `context.watch`
    final cubit = context.watch<CreateComplementGroupCubit>();
    final state = cubit.state;

    // Derivamos qual opção está selecionada a partir do booleano `isCopyFlow`
    final AddGroupOption selectedOption = state.isCopyFlow ? AddGroupOption.copy : AddGroupOption.create;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOptionCard(
              context: context,
              title: "Criar novo grupo",
              subtitle: "Você cria um grupo novo, definindo informações gerais...",
              icon: Icons.add_circle_outline,
              value: AddGroupOption.create,
              groupValue: selectedOption, // Passa a seleção
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context: context,
              title: "Copiar grupo",
              subtitle: "Você reaproveita um grupo que já possui em seu cardápio...",
              icon: Icons.link_outlined,
              value: AddGroupOption.copy,
              groupValue: selectedOption, // Passa a seleção
              tag: _buildTag(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: WizardFooter(
        showBackButton: false,
        onContinue: () {
          // ✅ 3. A ação de continuar agora usa o valor que já está no Cubit
          context.read<CreateComplementGroupCubit>().startFlow(state.isCopyFlow);
        },
      ),
    );
  }

  Widget _buildTag() {
    // ... (este widget auxiliar não muda)
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text("mais prático", style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.w500, fontSize: 12)));
  }

  // ✅ 4. O widget de card foi atualizado para ser mais "burro"
  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required AddGroupOption value,
    required AddGroupOption groupValue, // Recebe o valor do grupo
    Widget? tag,
  }) {
    final bool isSelected = value == groupValue;

    return InkWell(
      // ✅ 5. `onTap` agora chama o método do Cubit
      onTap: () => context.read<CreateComplementGroupCubit>().setFlowType(value == AddGroupOption.copy),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.grey.shade700, size: 28),
            const SizedBox(width: 16),
            Flexible(
              child: Column(
                // ... (o conteúdo do card não muda)
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
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, height: 1.4)),
                ],
              ),
            ),
            Radio<AddGroupOption>(
              value: value,
              groupValue: groupValue, // Lê o valor do grupo
              // ✅ 6. `onChanged` também chama o método do Cubit
              onChanged: (newValue) {
                if (newValue != null) {
                  context.read<CreateComplementGroupCubit>().setFlowType(newValue == AddGroupOption.copy);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}