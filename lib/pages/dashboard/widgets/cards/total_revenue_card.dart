// lib/widgets/dashboard/total_revenue_card.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/models/dashboard_data.dart';

class TotalRevenueCardSmall extends StatelessWidget {
  final double totalRevenue;
  final double percentageChange;
  final List<SalesDataPoint> salesOverTime;

  const TotalRevenueCardSmall({
    super.key,
    required this.totalRevenue,
    required this.percentageChange,
    required this.salesOverTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isUp = percentageChange >= 0;
    final Color trendColor = isUp ? Colors.green : Colors.red;
    final IconData trendIcon = isUp ? Icons.trending_up : Icons.trending_down;
    final currencyFormat =
    NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final String displayRevenue = currencyFormat.format(totalRevenue);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Receita Total', style: theme.textTheme.titleMedium),
                const Icon(Icons.more_vert, size: 18, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge de tendência
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(percentageChange * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                            fontSize: 12,
                            color: trendColor,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 2),
                      Icon(trendIcon, size: 14, color: trendColor),
                    ],
                  ),
                ),
                // Valor Principal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      displayRevenue,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'no último mês',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(), // Ocupa o espaço do meio para empurrar o gráfico para baixo
            // Gráfico de Linha (Sparkline)
            SizedBox(
              height: 40, // Altura do gráfico
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: salesOverTime.asMap().entries.map((e) {
                        // Converte os dados de vendas em pontos no gráfico
                        return FlSpot(e.key.toDouble(), e.value.revenue);
                      }).toList(),
                      isCurved: true,
                      color: trendColor,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: trendColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}