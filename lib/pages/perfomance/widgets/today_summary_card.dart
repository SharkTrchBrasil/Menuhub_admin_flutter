// lib/pages/performance/widgets/today_metrics_card.dart
// (Substitua o conteúdo do antigo TodaySummaryCard)

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/today_summary.dart';

class TodayMetricsCard extends StatelessWidget {
  final TodaySummary? summary;

  const TodayMetricsCard({super.key, this.summary});

  String _formatCurrency(double value) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);

  @override
  Widget build(BuildContext context) {
    // O widget agora é apenas o Card com as métricas
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 8.0),
        child: summary == null
            ? const Center(child: CircularProgressIndicator())
            : Row(
          children: [
            _buildMetric(
              context,
              title: "Vendas concluídas",
              value: summary!.completedSales.toString(),
            ),
            _buildDivider(),
            _buildMetric(
              context,
              title: "Valor total",
              value: _formatCurrency(summary!.totalValue),
            ),
            _buildDivider(),
            _buildMetric(
              context,
              title: "Ticket médio",
              value: _formatCurrency(summary!.averageTicket),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói uma única métrica (título + valor).
  Widget _buildMetric(BuildContext context, {required String title, required String value}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith( fontWeight: FontWeight.w400),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// Constrói um divisor vertical sutil entre as métricas.
  Widget _buildDivider() {
    return Container(
      height: 50,
      width: 1,
      color: Colors.grey.shade200,
    );
  }
}