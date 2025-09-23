import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';

// Seus imports
import 'package:totem_pro_admin/models/available_plan.dart';
import 'package:totem_pro_admin/pages/plans/edit_subscription_page_controller.dart';
import 'package:totem_pro_admin/pages/new_subscription/new_subscription_dialog.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/widgets/app_primary_button.dart';
import 'package:totem_pro_admin/widgets/app_secondary_button.dart';

import '../../models/plans.dart';

class EditSubscriptionPage extends StatelessWidget {
  final int storeId;

  const EditSubscriptionPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditSubscriptionPageController(storeId),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Nossos Planos'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onBackground,
        ),
        body: Consumer<EditSubscriptionPageController>(
          builder: (_, controller, __) {
            return AppPageStatusBuilder<List<AvailablePlan>>(
              status: controller.status,
              successBuilder: (availablePlans) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 768;

                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Header
                            _buildHeader(context),
                            const SizedBox(height: 32),

                            // Cards de planos
                            if (isDesktop)
                              _buildDesktopLayout(availablePlans, controller, context)
                            else
                              _buildMobileLayout(availablePlans, controller, context),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            'Escolha o plano perfeito',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Planos flexíveis que crescem com o seu negócio',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
      List<AvailablePlan> plans,
      EditSubscriptionPageController controller,
      BuildContext context,
      ) {
    return SizedBox(
      height: 500, // Altura fixa para a lista horizontal
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: _ModernPlanCard(
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
              cardWidth: 320, // Largura maior para desktop
            ),
          );
        },
      ),
    );
  }

  Widget _buildMobileLayout(
      List<AvailablePlan> plans,
      EditSubscriptionPageController controller,
      BuildContext context,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: plans.map((plan) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: _ModernPlanCard(
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
            cardWidth: double.infinity, // Largura total no mobile
          ),
        )).toList(),
      ),
    );
  }
}

class _ModernPlanCard extends StatelessWidget {
  final AvailablePlan availablePlan;
  final VoidCallback onSubscribePressed;
  final double cardWidth;

  const _ModernPlanCard({
    required this.availablePlan,
    required this.onSubscribePressed,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final plan = availablePlan.plan;
    final isCurrent = availablePlan.isCurrent;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Cores gradientes modernas para cada plano
    final gradientColors = _getPlanGradient(plan.planName, colorScheme);
    final iconData = _getPlanIcon(plan.planName);

    return SizedBox(
      width: cardWidth,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Card(
          elevation: isCurrent ? 12 : 6,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: isCurrent
                  ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradientColors[0].withOpacity(0.05),
                  gradientColors[1].withOpacity(0.1),
                ],
              )
                  : null,
              border: isCurrent
                  ? Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 2,
              )
                  : null,
            ),
            child: Stack(
              children: [
                // Badge "Recomendado" para o plano atual
                if (isCurrent)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: gradientColors),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: gradientColors[0].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'RECOMENDADO',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header com ícone e nome do plano
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: gradientColors),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: gradientColors[0].withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              iconData,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              plan.planName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Descrição do plano



                      // Preço com possível promoção
                      _PriceSection(plan: plan, theme: theme),
                      const SizedBox(height: 24),

                      // Lista de features
                      ...plan.features.take(4).map((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: gradientColors[0],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                feature.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),

                      // Botão de ação
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: isCurrent
                            ? AppPrimaryButton(
                          label: 'Plano Atual',
                          onPressed: null,

                        )
                            : AppSecondaryButton(
                          label: 'Escolher Plano',
                          onPressed: onSubscribePressed,

                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceSection extends StatelessWidget {
  final Plans plan;
  final ThemeData theme;

  const _PriceSection({required this.plan, required this.theme});

  @override
  Widget build(BuildContext context) {
   // final hasDiscount = plan.originalPrice != null && plan.originalPrice! > plan.price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //
        // if (hasDiscount) ...[
        //   Row(
        //     children: [
        //       Text(
        //         'De ${plan.originalPrice!.toPrice()}',
        //         style: theme.textTheme.bodyMedium?.copyWith(
        //           color: Colors.grey.shade500,
        //           decoration: TextDecoration.lineThrough,
        //         ),
        //       ),
        //       const SizedBox(width: 8),
        //       if (plan.promotionDuration != null)
        //         Container(
        //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        //           decoration: BoxDecoration(
        //             color: Colors.orange.shade50,
        //             borderRadius: BorderRadius.circular(6),
        //           ),
        //           child: Text(
        //             plan.promotionDuration!,
        //             style: theme.textTheme.labelSmall?.copyWith(
        //               color: Colors.orange.shade800,
        //               fontWeight: FontWeight.bold,
        //             ),
        //           ),
        //         ),
        //     ],
        //   ),
        //   const SizedBox(height: 4),
        // ],
        //


        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              plan.price.toPrice(),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '/mês',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
        // if (hasDiscount) ...[
        //   const SizedBox(height: 4),
        //   Text(
        //     'Economize ${((plan.originalPrice! - plan.price) / plan.originalPrice! * 100).toStringAsFixed(0)}%',
        //     style: theme.textTheme.bodySmall?.copyWith(
        //       color: Colors.green.shade600,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        // ],


      ],
    );
  }
}

// Funções auxiliares para personalização baseada no nome do plano
List<Color> _getPlanGradient(String planName, ColorScheme colorScheme) {
  switch (planName.toLowerCase()) {
    case 'básico':
      return [Colors.blue.shade400, Colors.blue.shade600];
    case 'premium':
      return [Colors.purple.shade400, Colors.purple.shade600];
    case 'empresarial':
      return [Colors.teal.shade400, Colors.teal.shade600];
    case 'ultimate':
      return [Colors.orange.shade400, Colors.orange.shade600];
    case 'startup':
      return [Colors.green.shade400, Colors.green.shade600];
    case 'professional':
      return [Colors.red.shade400, Colors.red.shade600];
    default:
      return [colorScheme.primary, colorScheme.primary.withOpacity(0.8)];
  }
}

IconData _getPlanIcon(String planName) {
  switch (planName.toLowerCase()) {
    case 'básico':
      return Icons.star_outline;
    case 'premium':
      return Icons.star_half;
    case 'empresarial':
      return Icons.business_center;
    case 'ultimate':
      return Icons.diamond;
    case 'startup':
      return Icons.rocket_launch;
    case 'professional':
      return Icons.work;
    default:
      return Icons.credit_card;
  }
}