// lib/pages/subscriptions/manage_subscription_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/pages/plans/update_card_dialog.dart';
import 'package:totem_pro_admin/models/subscription/details/billing_history_item.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';

class ManageSubscriptionPage extends StatelessWidget {
  final int storeId;

  const ManageSubscriptionPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        // ═══════════════════════════════════════════════════════════
        // VALIDAÇÕES DE ESTADO
        // ═══════════════════════════════════════════════════════════

        if (state is! StoresManagerLoaded) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.activeStoreId != storeId) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sync_problem, size: 64, color: Colors.orange),
                  SizedBox(height: 16),
                  Text('Sincronizando dados da loja...'),
                ],
              ),
            ),
          );
        }

        final activeStore = state.activeStore;
        if (activeStore == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text('Erro: Loja não encontrada'),
            ),
          );
        }

        final subscription = activeStore.relations.subscription;
        if (subscription == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Nenhuma assinatura ativa encontrada'),
                ],
              ),
            ),
          );
        }

        final billingPreview = subscription.billingPreview;
        if (billingPreview == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text('Erro: Dados de faturamento não disponíveis'),
            ),
          );
        }

        // ═══════════════════════════════════════════════════════════
        // RENDERIZAÇÃO DA UI
        // ═══════════════════════════════════════════════════════════

        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, subscription),
                const SizedBox(height: 32),

                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 768) {
                      // LAYOUT DESKTOP
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildCurrentPeriodCard(context, subscription),
                                const SizedBox(height: 24),
                                _buildBillingPreviewCard(context, billingPreview),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: [
                                _buildPlanCard(context, subscription),
                                const SizedBox(height: 24),
                                if (subscription.cardInfo != null)
                                  _buildCardInfoCard(context, subscription),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      // LAYOUT MOBILE
                      return Column(
                        children: [
                          _buildCurrentPeriodCard(context, subscription),
                          const SizedBox(height: 24),
                          _buildPlanCard(context, subscription),
                          const SizedBox(height: 24),
                          _buildBillingPreviewCard(context, billingPreview),
                          const SizedBox(height: 24),
                          if (subscription.cardInfo != null)
                            _buildCardInfoCard(context, subscription),
                        ],
                      );
                    }
                  },
                ),

                const SizedBox(height: 32),

                if (subscription.billingHistory.isNotEmpty)
                  _buildBillingHistoryCard(context, subscription.billingHistory),

                const SizedBox(height: 32),

                _buildDangerZone(context, subscription),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context, dynamic subscription) {
    final statusText = subscription.isActive
        ? 'Assinatura Ativa'
        : subscription.isTrialing
        ? 'Período de Teste'
        : 'Assinatura';

    final statusColor = subscription.isActive
        ? Colors.green
        : subscription.isTrialing
        ? Colors.blue
        : Colors.orange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              subscription.isActive || subscription.isTrialing
                  ? Icons.check_circle
                  : Icons.warning_amber_rounded,
              color: statusColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              statusText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subscription.warningMessage ??
              'Gerencie sua assinatura e veja detalhes de faturamento',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CARD DE PERÍODO ATUAL
  // ═══════════════════════════════════════════════════════════

  Widget _buildCurrentPeriodCard(BuildContext context, dynamic subscription) {
    final daysRemaining = subscription.daysUntilExpiration;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3C76E8), Color(0xFF5B8FFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3C76E8).withOpacity(0.3),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Período Atual',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Válido até ${_formatDate(subscription.currentPeriodEnd)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$daysRemaining dias restantes',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CARD DO PLANO
  // ═══════════════════════════════════════════════════════════

  Widget _buildPlanCard(BuildContext context, dynamic subscription) {
    final plan = subscription.plan;
    if (plan == null) return SizedBox.shrink();

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
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seu Plano',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            plan.planName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3C76E8),
            ),
          ),
          const SizedBox(height: 12),
          _buildPlanDetail(
            Icons.arrow_downward,
            'Taxa mínima',
            'R\$ ${(plan.minimumFee / 100).toStringAsFixed(2)}',
          ),
          _buildPlanDetail(
            Icons.percent,
            'Percentual',
            '${(plan.revenuePercentage * 100).toStringAsFixed(1)}%',
          ),
          if (plan.revenueCapFee != null)
            _buildPlanDetail(
              Icons.arrow_upward,
              'Teto máximo',
              'R\$ ${(plan.revenueCapFee! / 100).toStringAsFixed(2)}',
            ),
        ],
      ),
    );
  }

  Widget _buildPlanDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CARD DE BILLING PREVIEW
  // ═══════════════════════════════════════════════════════════

  Widget _buildBillingPreviewCard(BuildContext context, dynamic preview) {
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
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Faturamento Atual',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildBillingMetric(
            'Receita até agora',
            'R\$ ${preview.revenueSoFar.toStringAsFixed(2)}',
            Colors.green,
          ),
          _buildBillingMetric(
            'Taxa até agora',
            'R\$ ${preview.feeSoFar.toStringAsFixed(2)}',
            Colors.orange,
          ),
          const Divider(height: 24),
          _buildBillingMetric(
            'Receita projetada',
            'R\$ ${preview.projectedRevenue.toStringAsFixed(2)}',
            Colors.blue,
          ),
          _buildBillingMetric(
            'Taxa projetada',
            'R\$ ${preview.projectedFee.toStringAsFixed(2)}',
            Color(0xFF3C76E8),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingMetric(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CARD DE CARTÃO
  // ═══════════════════════════════════════════════════════════

  Widget _buildCardInfoCard(BuildContext context, dynamic subscription) {
    final card = subscription.cardInfo;
    if (card == null) return SizedBox.shrink();

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
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cartão Cadastrado',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.credit_card, color: Color(0xFF3C76E8), size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.maskedNumber,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      card.brand,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => UpdateCardDialog(storeId: storeId),
                );
              },
              icon: Icon(Icons.edit, size: 16),
              label: Text('Atualizar Cartão'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF3C76E8),
                side: BorderSide(color: Color(0xFF3C76E8)),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // CARD DE HISTÓRICO DE COBRANÇAS
  // ═══════════════════════════════════════════════════════════

  Widget _buildBillingHistoryCard(
      BuildContext context, List<BillingHistoryItem> history) {
    if (history.isEmpty) return SizedBox.shrink();

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
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Histórico de Cobranças',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (_, __) => Divider(height: 24),
            itemBuilder: (context, index) {
              final charge = history[index];
              return _buildChargeItem(charge);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChargeItem(BillingHistoryItem charge) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getStatusColor(charge.status).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getStatusIcon(charge.status),
            color: _getStatusColor(charge.status),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                charge.period,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Receita: R\$ ${charge.revenue.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'R\$ ${charge.fee.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Text(
              _getStatusLabel(charge.status),
              style: TextStyle(
                color: _getStatusColor(charge.status),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ZONA DE PERIGO
  // ═══════════════════════════════════════════════════════════

  Widget _buildDangerZone(BuildContext context, dynamic subscription) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Text(
                'Zona de Perigo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ao cancelar sua assinatura:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildWarningItem('Você perderá acesso a todas as funcionalidades'),
          _buildWarningItem('Sua loja será bloqueada para novos pedidos'),
          _buildWarningItem('O acesso permanece até o fim do período pago'),
          _buildWarningItem('Você pode reativar a qualquer momento'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: subscription.canCancel
                  ? () => _showCancelDialog(context)
                  : null,
              icon: Icon(Icons.cancel, size: 20),
              label: Text('Cancelar Assinatura'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade700),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.close, size: 16, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DIALOG DE CANCELAMENTO
  // ═══════════════════════════════════════════════════════════

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Cancelar Assinatura?'),
        content: Text(
          'Tem certeza que deseja cancelar? Você manterá acesso até o fim do período pago.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              final subscriptionRepo = GetIt.I<StoreRepository>();
              final result = await subscriptionRepo.cancelSubscription(storeId);

              result.fold(
                    (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erro: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                    (_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Assinatura cancelada com sucesso'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Confirmar Cancelamento'),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // UTILITÁRIOS
  // ═══════════════════════════════════════════════════════════

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Pago';
      case 'pending':
        return 'Pendente';
      case 'failed':
        return 'Falhou';
      default:
        return status;
    }
  }
}