// lib/widgets/subscription_blocked_view.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/models/subscription/subscription.dart';

class SubscriptionBlockedView extends StatelessWidget {
  final Subscription subscription; // ✅ MUDOU: Agora recebe Subscription diretamente
  final int storeId;

  const SubscriptionBlockedView({
    super.key,
    required this.subscription,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final endDate = subscription.currentPeriodEnd;
    final daysRemaining = endDate != null && now.isBefore(endDate)
        ? endDate.difference(now).inDays
        : 0;

    // ✅ DETERMINA SE AINDA TEM DIAS PAGOS
    final hasRemainingDays = daysRemaining > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ═══════════════════════════════════════════════════════════
                // ÍCONE
                // ═══════════════════════════════════════════════════════════
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade100,
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.pause_circle_outline,
                    size: 64,
                    color: Colors.orange.shade700,
                  ),
                ),

                const SizedBox(height: 32),

                // ═══════════════════════════════════════════════════════════
                // TÍTULO DINÂMICO
                // ═══════════════════════════════════════════════════════════
                Text(
                  _getTitleForStatus(subscription.status),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // ═══════════════════════════════════════════════════════════
                // MENSAGEM DE AVISO
                // ═══════════════════════════════════════════════════════════
                if (subscription.warningMessage != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscription.warningMessage!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        // ✅ SE AINDA TEM DIAS PAGOS, MOSTRA
                        if (hasRemainingDays) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Você ainda tem $daysRemaining dias pagos até ${_formatDate(endDate!)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // ═══════════════════════════════════════════════════════════
                // CARD DE BENEFÍCIOS
                // ═══════════════════════════════════════════════════════════
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasRemainingDays
                            ? 'Ao reativar agora (grátis):'
                            : 'Ao reativar sua assinatura:',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildBenefitItem(
                        Icons.smart_toy,
                        'Chatbot volta a funcionar',
                        'Receba pedidos automaticamente',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        Icons.store,
                        'Loja reabre para clientes',
                        'Seus clientes poderão fazer pedidos',
                      ),
                      const SizedBox(height: 12),
                      _buildBenefitItem(
                        Icons.dashboard,
                        'Acesso total ao painel',
                        'Gerencie pedidos e relatórios',
                      ),
                      if (hasRemainingDays) ...[
                        const SizedBox(height: 12),
                        _buildBenefitItem(
                          Icons.money_off,
                          'Sem cobrança adicional',
                          'Você já pagou até ${_formatDate(endDate!)}',
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ═══════════════════════════════════════════════════════════
                // BOTÃO DE REATIVAÇÃO
                // ═══════════════════════════════════════════════════════════
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // ✅ ROTA CORRETA:
                      context.go('/stores/$storeId/subscription/reactivate');
                    },
                    icon: const Icon(Icons.replay, size: 20),
                    label: Text(
                      hasRemainingDays
                          ? 'Reativar Agora (Grátis)'
                          : 'Reativar Assinatura',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ═══════════════════════════════════════════════════════════
                // LINK PARA SUPORTE
                // ═══════════════════════════════════════════════════════════
                TextButton.icon(
                  onPressed: () {
                    // TODO: Abrir WhatsApp ou email de suporte
                    // launchUrl(Uri.parse('https://wa.me/5511999999999'));
                  },
                  icon: Icon(
                    Icons.support_agent,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  label: Text(
                    'Precisa de ajuda? Fale com nosso suporte',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════

  String _getTitleForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'canceled':
        return 'Assinatura Cancelada';
      case 'expired':
        return 'Assinatura Expirada';
      case 'past_due':
        return 'Pagamento Pendente';
      default:
        return 'Assinatura Bloqueada';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildBenefitItem(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}