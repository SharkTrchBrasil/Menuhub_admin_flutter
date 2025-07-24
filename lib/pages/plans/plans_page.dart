import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart'; // Para o .toPrice()

// Seus imports
import 'package:totem_pro_admin/models/available_plan.dart';
import 'package:totem_pro_admin/pages/plans/edit_subscription_page_controller.dart';
import 'package:totem_pro_admin/pages/new_subscription/new_subscription_dialog.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_secondary_button.dart';

class EditSubscriptionPage extends StatelessWidget {
  final int storeId;

  const EditSubscriptionPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    // Usamos o mesmo Provider e Controller da página anterior
    return ChangeNotifierProvider(
      create: (_) => EditSubscriptionPageController(storeId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nossos Planos'),
        ),
        body: Consumer<EditSubscriptionPageController>(
          builder: (_, controller, __) {
            // O AppPageStatusBuilder lida com os estados de loading e erro
            return AppPageStatusBuilder<List<AvailablePlan>>(
              status: controller.status,
              successBuilder: (availablePlans) {
                // Corpo da página em caso de sucesso
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Escolha o plano que melhor atende suas necessidades',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // A lista horizontal de cards
                      SizedBox(
                        height: 420, // Altura fixa para a lista
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: availablePlans.length,
                          itemBuilder: (context, index) {
                            final plan = availablePlans[index];
                            // Chama o widget de card para cada plano
                            return _PlanCard(
                              availablePlan: plan,
                              onSubscribePressed: () async {
                                await showDialog(
                                  context: context,
                                  builder: (_) => NewSubscriptionDialog(
                                    storeId: storeId,
                                    plan: plan.plan,
                                  ),
                                );
                                controller.reload();
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// Widget interno para desenhar cada card de plano.
class _PlanCard extends StatelessWidget {
  final AvailablePlan availablePlan;
  final VoidCallback onSubscribePressed;

  const _PlanCard({
    required this.availablePlan,
    required this.onSubscribePressed,
  });

  @override
  Widget build(BuildContext context) {
    final plan = availablePlan.plan;
    final isCurrent = availablePlan.isCurrent;
    final theme = Theme.of(context);

    return Card(
      elevation: isCurrent ? 8.0 : 4.0,
      margin: const EdgeInsets.only(right: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCurrent ? theme.colorScheme.primary : Colors.grey.shade300,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Container(
        width: 280, // Largura fixa para cada card
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Nome do Plano e Selo "Atual")
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.planName,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (isCurrent)
                  Chip(
                    label: const Text('Atual'),
                    backgroundColor: theme.colorScheme.primary,
                    labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Preço
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: plan.price.toPrice(),
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' / mês',
                    style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(),
            ),

            // Lista de Features
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: plan.features.length,
                itemBuilder: (context, index) {
                  final feature = plan.features[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check, color: theme.colorScheme.primary, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature.name, // Usando o nome amigável da feature
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Botão de Ação
            SizedBox(
              width: double.infinity,
              child: isCurrent
                  ? AppPrimaryButton(
                label: 'Seu Plano Atual',
                onPressed: null, // Desabilita o botão para o plano atual
              )
                  : AppSecondaryButton(
                label: 'Assinar este Plano',
                onPressed: onSubscribePressed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}







class PlanFeature {
  final IconData icon;
  final String title;
  final String description;

  const PlanFeature({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class Plan {
  final String planName;
  final String description;
  final int price; // Preço principal em centavos
  final int? originalPrice; // Preço antigo (para o "de/por"), em centavos
  final String? promotionDuration; // Ex: "por 3 meses"
  final List<PlanFeature> features;

  const Plan({
    required this.planName,
    required this.description,
    required this.price,
    this.originalPrice,
    this.promotionDuration,
    required this.features,
  });
}



