// lib/pages/create_store/widgets/plans_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/create_store/cubit/store_setup_cubit.dart';
import 'package:totem_pro_admin/pages/create_store/cubit/store_setup-state.dart';

class PlansStep extends StatelessWidget {
  const PlansStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoreSetupCubit, StoreSetupState>(
      builder: (context, state) {
        // A lógica de carregamento e erro pode ser mantida para robustez,
        // mas o conteúdo principal agora é estático.

        return ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Text(
              "Você está quase lá!",
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "Ao concluir, sua loja será criada com 30 dias de acesso total ao nosso plano Pro, sem custos e sem necessidade de cartão.",
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildFeatureRow(
                      context: context,
                      icon: Icons.card_giftcard,
                      title: '30 Dias de Teste Gratuito',
                      subtitle: 'Aproveite todas as funcionalidades sem compromisso.',
                      iconColor: Colors.green.shade600,
                    ),
                    const Divider(height: 32),
                    _buildFeatureRow(
                      context: context,
                      icon: Icons.credit_card_off,
                      title: 'Sem Cartão de Crédito',
                      subtitle: 'Ative sua loja agora mesmo. Você só precisará adicionar um pagamento se decidir continuar após o teste.',
                      iconColor: Colors.blue.shade700,
                    ),
                    const Divider(height: 32),
                    _buildFeatureRow(
                      context: context,
                      icon: Icons.cancel_outlined,
                      title: 'Cancele a Qualquer Momento',
                      subtitle: 'Sem fidelidade ou taxas ocultas. Você no controle.',
                      iconColor: Colors.red.shade700,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Clique em 'Finalizar' para lançar sua loja e começar a vender!",
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            )
          ],
        );
      },
    );
  }

  Widget _buildFeatureRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 32, color: iconColor),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black54)),
            ],
          ),
        ),
      ],
    );
  }
}