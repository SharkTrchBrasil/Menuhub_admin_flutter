import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import '../models/billing_preview.dart';

class BillingPreviewCard extends StatelessWidget {
  final BillingPreview preview;
  final VoidCallback onTap;

  const BillingPreviewCard({
    super.key,
    required this.preview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM');
    final period = '${dateFormat.format(preview.periodStart)} a ${dateFormat.format(preview.periodEnd)}';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardHeader(title: 'Resumo do Ciclo', subtitle: period),
              const Divider(height: 24, thickness: 1, indent: 8, endIndent: 8),
              _InfoRow(
                label: 'Faturamento até hoje',
                value: currencyFormat.format(preview.revenueSoFar),
                isHighlight: true,
              ),
              _InfoRow(
                label: 'Taxa do Sistema (atual)',
                value: currencyFormat.format(preview.feeSoFar),
              ),
              _InfoRow(
                label: 'Total de Pedidos',
                value: preview.ordersSoFar.toString(),
              ),
              const SizedBox(height: 16),
              _ProjectionSection(
                projectedRevenue: currencyFormat.format(preview.projectedRevenue),
                projectedFee: currencyFormat.format(preview.projectedFee),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _CardHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF333333))),
        Row(
          children: [
            Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  const _InfoRow({required this.label, required this.value, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 15)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              fontSize: isHighlight ? 16 : 15,
              color: isHighlight ? Theme.of(context).colorScheme.primary : const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectionSection extends StatelessWidget {
  final String projectedRevenue;
  final String projectedFee;
  const _ProjectionSection({required this.projectedRevenue, required this.projectedFee});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph, size: 16, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 8),
              Text(
                'Projeção para o fim do ciclo',
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _InfoRow(label: 'Faturamento Projetado', value: projectedRevenue),
          _InfoRow(label: 'Taxa Sistema (Projetada)', value: projectedFee),
        ],
      ),
    );
  }
}