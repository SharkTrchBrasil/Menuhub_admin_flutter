import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/category_wizard_cubit.dart';

class PricingModelSelectionScreen extends StatelessWidget {
  const PricingModelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryWizardCubit>();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Como os preços funcionarão?",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),

              _buildChoiceCard(
                context: context,
                title: "O preço é definido por Tamanho",
                subtitle: "Ideal para Pizzas, Açaís, Marmitas. Você define um preço para cada sabor em cada tamanho (P, M, G). Os outros grupos (ex: bordas, frutas) podem adicionar valor.",
                iconData: Icons.straighten_outlined,
                onTap: () => cubit.setPricingModel(variesBySize: true),
              ),
              const SizedBox(height: 16),
              _buildChoiceCard(
                context: context,
                title: "O preço é a Soma das Opções",
                subtitle: "Ideal para Lanches Montáveis ou Saladas. O item tem um preço base e cada opção escolhida pelo cliente soma ao valor final.",
                iconData: Icons.calculate_outlined,
                onTap: () => cubit.setPricingModel(variesBySize: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget de card reutilizável
  Widget _buildChoiceCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData iconData,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(iconData, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}