import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/models/payables_dashboard.dart';

class PayablesSummaryWidget extends StatelessWidget {
  final PayablesDashboardMetrics metrics;

  const PayablesSummaryWidget({super.key, required this.metrics});

  String _formatCurrency(int amountInCents) {
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return format.format(amountInCents / 100);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Título Principal ---
            Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined,
                    color: colorScheme.primary),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Financeiro - Contas a Pagar',
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- KPIs Responsivos ---
            LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 500;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricCard(
                      title: 'Pendentes',
                      value: _formatCurrency(metrics.totalPending),
                      subtitle: '${metrics.pendingCount} conta(s)',
                      color: Colors.orange.shade700,
                      icon: Icons.pending_actions,
                      isFullWidth: isMobile,
                    ),
                    _MetricCard(
                      title: 'Vencidas',
                      value: _formatCurrency(metrics.totalOverdue),
                      subtitle: '${metrics.overdueCount} conta(s)',
                      color: colorScheme.error,
                      icon: Icons.warning_amber_rounded,
                      isFullWidth: isMobile,
                    ),
                    _MetricCard(
                      title: 'Pago no Mês',
                      value: _formatCurrency(metrics.totalPaidMonth),
                      subtitle: 'ref. agosto', // deixar dinâmico depois
                      color: Colors.green.shade700,
                      icon: Icons.check_circle_outline,
                      isFullWidth: isMobile,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 16),

            // --- Próximos Vencimentos ---
            Row(
              children: [
                Icon(Icons.calendar_month, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Próximos Vencimentos',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (metrics.nextDuePayables.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Text(
                    'Nenhuma conta próxima do vencimento.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              )
            else
              Column(
                children: metrics.nextDuePayables.map((payable) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.event_note, size: 28),
                      title: Text(
                        payable.title,
                        style: textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Vence em: ${DateFormat('dd/MM/yyyy').format(payable.dueDate)}',
                      ),
                      trailing: Text(
                        _formatCurrency(payable.finalAmount),
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      dense: true,
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Widget auxiliar para as métricas ---
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
  final bool isFullWidth;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: isFullWidth ? double.infinity : 160,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
