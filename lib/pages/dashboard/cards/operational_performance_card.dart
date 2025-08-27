// lib/pages/dashboard/widgets/gold_cards/operational_performance_card.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/dashboard_data.dart';

class OperationalPerformanceCard extends StatelessWidget {
  final DashboardData dashboardData;

  const OperationalPerformanceCard({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kpis = dashboardData.kpis;
    final distribution = dashboardData.orderTypeDistribution;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Operação', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '${kpis.transactionCount} pedidos totais',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            // Gráfico de Pizza
            Expanded(
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: List.generate(distribution.length, (i) {
                    final item = distribution[i];
                    final colors = [Colors.blue, Colors.orange, Colors.purple, Colors.teal];
                    return PieChartSectionData(
                      color: colors[i % colors.length],
                      value: item.count.toDouble(),
                      title: '${item.count}',
                      radius: 30,
                      titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  }),
                ),
              ),
            ),
            const Divider(),
            // Legenda
            Wrap(
              spacing: 16,
              runSpacing: 4,
              children: List.generate(distribution.length, (i) {
                final item = distribution[i];
                final colors = [Colors.blue, Colors.orange, Colors.purple, Colors.teal];
                return _buildLegend(colors[i % colors.length], item.orderType);
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}