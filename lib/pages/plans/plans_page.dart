import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/core/extensions/extensions.dart';
import 'package:totem_pro_admin/models/plans/available_plan.dart';
import 'package:totem_pro_admin/pages/plans/edit_subscription_page_controller.dart';
import 'package:totem_pro_admin/pages/new_subscription/new_subscription_dialog.dart';
import 'package:totem_pro_admin/widgets/app_page_status_builder.dart';
import 'package:totem_pro_admin/models/plans/plans.dart';

import '../../core/responsive_builder.dart';
import '../../cubits/store_manager_cubit.dart';
import '../../cubits/store_manager_state.dart';


class EditSubscriptionPage extends StatefulWidget {
  final int storeId;

  const EditSubscriptionPage({super.key, required this.storeId});

  @override
  State<EditSubscriptionPage> createState() => _EditSubscriptionPageState();
}

class _EditSubscriptionPageState extends State<EditSubscriptionPage> {
  @override
  void initState() {
    super.initState();

    // ✅ ESCUTA MUDANÇAS NO CUBIT
    final cubit = GetIt.I<StoresManagerCubit>();
    cubit.stream.listen((state) {
      if (!mounted) return;

      if (state is StoresManagerLoaded) {
        final subscription = state.activeStore?.relations.subscription;

        // ✅ SE ASSINATURA FOI ATIVADA, VOLTA PARA O DASHBOARD
        if (subscription != null &&
            !subscription.isBlocked &&
            subscription.hasPaymentMethod == true) {
          debugPrint(
              '✅ [PlansPage] Assinatura ativada! Navegando para dashboard...');

          // ✅ VOLTA PARA O DASHBOARD
          context.go('/stores/${widget.storeId}/dashboard');

          // ✅ MOSTRA MENSAGEM DE SUCESSO
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎉 Assinatura ativada com sucesso!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EditSubscriptionPageController(widget.storeId),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<EditSubscriptionPageController>(
          builder: (_, controller, __) {
            return AppPageStatusBuilder<List<AvailablePlan>>(
              status: controller.status,
              successBuilder: (availablePlans) {
                if (availablePlans.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum plano disponível.',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                final plan = availablePlans.first;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 768;

                    if (isDesktop) {
                      return _DesktopLayout(
                        plan: plan,
                        storeId: widget.storeId,
                        controller: controller,
                      );
                    } else {
                      return _MobileLayout(
                        plan: plan,
                        storeId: widget.storeId,
                        controller: controller,
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  final AvailablePlan plan;
  final int storeId;
  final EditSubscriptionPageController controller;

  const _DesktopLayout({
    required this.plan,
    required this.storeId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          // Header
          _buildHeader(context, plan),
          const SizedBox(height: 40),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card Principal com Calculadora
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    child: _PricingCalculatorCard(plan: plan.plan),
                  ),
                ),
                const SizedBox(width: 32),

                // Sidebar com Benefícios e CTA
                Expanded(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildBenefitsCard(context, plan.plan),
                        const SizedBox(height: 24),
                        _buildCtaCard(context, plan, controller),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileLayout extends StatelessWidget {
  final AvailablePlan plan;
  final int storeId;
  final EditSubscriptionPageController controller;

  const _MobileLayout({
    required this.plan,
    required this.storeId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding:  EdgeInsets.symmetric(horizontal: ResponsiveBuilder.isMobile(context) ?  14 : 24), // Reduzido o padding

      child: Column(
        children: [
          const SizedBox(height: 14),
          // Header
          _buildHeader(context, plan),
          const SizedBox(height: 32),

          // Calculadora
          _PricingCalculatorCard(plan: plan.plan),
          const SizedBox(height: 24),

          // Benefícios
          _buildBenefitsCard(context, plan.plan),
          const SizedBox(height: 24),

          // CTA
          _buildCtaCard(context, plan, controller),
          const SizedBox(height: 42),
        ],
      ),
    );
  }
}

Widget _buildHeader(BuildContext context, AvailablePlan availablePlan) {
  final statusText = availablePlan.isCurrent
      ? 'Seu plano está ativo. Veja como sua cobrança funciona.'
      : 'Seu período de teste de 30 dias está ativo!';

  return Column(
    children: [
      Text(
        'Transparência e Preço Justo',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      Text(
        statusText,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.black54,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget _buildBenefitsCard(BuildContext context, Plans plan) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Benefícios Inclusos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 20),
        _buildBenefitItem(
          Icons.card_giftcard_rounded,
          '1º Mês Grátis',
          'Comece a vender sem custo algum no primeiro mês',
          Colors.green,
        ),
        const SizedBox(height: 16),
        _buildBenefitItem(
          Icons.trending_down_rounded,
          'Descontos Progressivos',
          'Pague 50% no 2º mês e 25% no 3º mês',
          Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildBenefitItem(
          Icons.support_agent_rounded,
          'Suporte Prioritário',
          'Acesso direto ao nosso time via WhatsApp',
          Colors.purple,
        ),
      ],
    ),
  );
}

Widget _buildBenefitItem(IconData icon, String title, String subtitle, Color color) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildCtaCard(BuildContext context, AvailablePlan plan, EditSubscriptionPageController controller) {

  final storesManagerCubit = GetIt.I<StoresManagerCubit>();
  final activeStoreId = (storesManagerCubit.state as StoresManagerLoaded?)
      ?.activeStore?.core.id;



  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          plan.isCurrent ? 'Plano Ativo' : 'Pronto para Começar?',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: plan.isCurrent || activeStoreId == null
                ? null
                : () async {
              await showDialog(
                context: context,
                builder: (_) => NewSubscriptionDialog(
                  storeId: activeStoreId!,  // ✅ USA A LOJA ATIVA
                  plan: plan.plan,
                ),
              );
              controller.reload();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3C76E8),
              disabledBackgroundColor: Colors.green.shade100,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              plan.isCurrent ? 'PLANO ATIVO' : 'ADICIONAR PAGAMENTO',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Cancele a qualquer momento. Sem fidelidade.',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}

// Widget da Calculadora Interativa - Corrigido para evitar overflow
class _PricingCalculatorCard extends StatefulWidget {
  final Plans plan;
  const _PricingCalculatorCard({required this.plan});

  @override
  State<_PricingCalculatorCard> createState() => _PricingCalculatorCardState();
}

class _PricingCalculatorCardState extends State<_PricingCalculatorCard> {
  double _currentRevenue = 3000.0;
  double _calculatedFee = 0;
  int _activeTier = 1;

  @override
  void initState() {
    super.initState();
    _calculateFee();
  }

  void _calculateFee() {
    final plan = widget.plan;

    // ✅ CONVERSÃO CORRETA: Centavos → Reais
    final minFee = plan.minimumFeeReais;      // R$ 39,90
    final capFee = plan.revenueCapFeeReais;   // R$ 240,00
    final tierStart = plan.percentageTierStartReais; // R$ 2.500,00
    final tierEnd = plan.percentageTierEndReais;     // R$ 15.000,00

    double fee;

    // ✅ TIER 1: Até R$ 2.500 (EXCLUSIVO)
    if (_currentRevenue < tierStart) {
      fee = minFee;
      _activeTier = 1;
    }
    // ✅ TIER 2: R$ 2.500 - R$ 14.999,99 (EXCLUSIVO NO FIM)
    else if (_currentRevenue < tierEnd) {
      fee = _currentRevenue * plan.revenuePercentage;

      // Garante mínimo de R$ 45,00 no Tier 2
      if (fee < 45.0) fee = 45.0;

      _activeTier = 2;
    }
    // ✅ TIER 3: R$ 15.000 ou mais (INCLUSIVO)
    else {
      fee = capFee;
      _activeTier = 3;
    }

    setState(() {
      _calculatedFee = fee;
    });
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    return Container(
      padding: const EdgeInsets.all(24), // Reduzido o padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Importante: não expande além do necessário
        children: [
          const Text(
            'Simule sua mensalidade',
            style: TextStyle(
              fontSize: 18, // Reduzido
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Arraste para ver quanto você pagaria com base no seu faturamento mensal.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Display do Faturamento
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16), // Reduzido
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Text(
                  'Faturamento Mensal',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentRevenue.toCurrency(),
                  style: const TextStyle(
                    fontSize: 24, // Reduzido
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 10, // Reduzido
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: const Color(0xFF3C76E8),
              inactiveTrackColor: Colors.grey.shade300,
              thumbColor: const Color(0xFF3C76E8),
            ),
            child: Slider(
              value: _currentRevenue,
              min: 0,
              max: 15000,
              divisions: 150,
              label: _currentRevenue.toInt().toCurrency(),
              onChanged: (value) {
                setState(() {
                  _currentRevenue = value;
                  _calculateFee();
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('R\$ 0', style: TextStyle(color: Colors.grey.shade600)),
              Text('R\$ 15.000', style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),

          const SizedBox(height: 24),
       //   const Divider(color: Colors.grey, height: 1),
          const SizedBox(height: 24),

          // Resultado
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20), // Reduzido
            decoration: BoxDecoration(
              color: const Color(0xFF3C76E8).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3C76E8).withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Text(
                  'Sua mensalidade seria:',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _calculatedFee.toInt().toCurrency(),
                  style: const TextStyle(
                    color: Color(0xFF3C76E8),
                    fontSize: 28, // Reduzido
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '/mês',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Explicação das faixas de preço
          const Text(
            'Como funciona o cálculo:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Lista de tiers com altura fixa para evitar overflow
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250), // Limite de altura
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTierInfo(
                    isActive: _activeTier == 1,
                    title: 'Até ${((plan.percentageTierStart ?? 0) / 100).toCurrency()}',
                    description: 'Taxa mínima de ${(plan.minimumFee / 100).toCurrency()}',
                  ),
                  const SizedBox(height: 8),
                  _buildTierInfo(
                    isActive: _activeTier == 2,
                    title: 'De ${((plan.percentageTierStart ?? 0) / 100).toCurrency()} a ${((plan.percentageTierEnd ?? 0) / 100).toCurrency()}',
                    description: '${NumberFormat.decimalPercentPattern(decimalDigits: 1).format(plan.revenuePercentage)} do faturamento',
                  ),
                  const SizedBox(height: 8),
                  _buildTierInfo(
                    isActive: _activeTier == 3,
                    title: 'Acima de ${((plan.percentageTierEnd ?? 0) / 100).toCurrency()}',
                    description: 'Taxa fixa de ${((plan.revenueCapFee ?? 0) / 100).toCurrency()}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierInfo({required bool isActive, required String title, required String description}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12), // Reduzido
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3C76E8).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? const Color(0xFF3C76E8) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF3C76E8) : Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isActive ? Colors.black87 : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 14, // Reduzido
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: isActive ? Colors.grey.shade600 : Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}