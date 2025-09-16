import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/responsive_builder.dart';
import '../cubit/create_complement_cubit.dart';
import '../widgets/wizard_footer.dart';

// ✅ 1. Convertido para StatelessWidget
class Step1GroupType extends StatelessWidget {
  const Step1GroupType({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 2. Usamos `context.watch` para ler o estado atual e reconstruir a UI quando ele mudar
    final cubit = context.watch<CreateComplementGroupCubit>();
    final state = cubit.state;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Primeiro, defina o tipo do grupo",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _buildOptionCard(
              context: context, // Passa o context
              title: "Ingredientes",
              subtitle: "Dê a opção do cliente remover e adicionar ingredientes...",
              icon: Icons.restaurant_menu_outlined,
              value: GroupType.ingredients,
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              context: context,
              title: "Especificações",
              subtitle: "Faça perguntas para que o cliente defina melhor o produto...",
              icon: Icons.help_outline,
              value: GroupType.specifications,
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              context: context,
              title: "Cross-sell",
              subtitle: "Aproveite para sugerir outros produtos e aumentar o valor do pedido.",
              icon: Icons.add_shopping_cart_outlined,
              value: GroupType.crossSell,
            ),
            const SizedBox(height: 12),
            _buildOptionCard(
              context: context,
              title: "Descartáveis",
              subtitle: "Ao invés de enviar por padrão, economize...",
              icon: Icons.restaurant_outlined,
              value: GroupType.disposables,
            ),
          ],
        ),
      ),
      bottomNavigationBar: WizardFooter(
        onBack: () => context.read<CreateComplementGroupCubit>().goBack(),
        // ✅ 3. O botão "Continuar" agora usa o valor que já está salvo no Cubit
        onContinue: () => context.read<CreateComplementGroupCubit>().selectGroupType(state.groupType!),
      ),
    );
  }

  // ✅ 4. O método _buildOptionCard agora é estático e recebe o context
  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required GroupType value,
  }) {
    // Lê o tipo selecionado diretamente do estado do Cubit
    final selectedType = context.watch<CreateComplementGroupCubit>().state.groupType;
    final bool isSelected = selectedType == value;

    return InkWell(
      // ✅ 5. `onTap` agora chama o método do Cubit para salvar a nova seleção
      onTap: () => context.read<CreateComplementGroupCubit>().groupTypeChanged(value),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, height: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Radio<GroupType>(
              value: value,
              // ✅ `groupValue` agora lê o valor do Cubit
              groupValue: selectedType,
              // ✅ `onChanged` também chama o método do Cubit
              onChanged: (newValue) {
                if (newValue != null) {
                  context.read<CreateComplementGroupCubit>().groupTypeChanged(newValue);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}