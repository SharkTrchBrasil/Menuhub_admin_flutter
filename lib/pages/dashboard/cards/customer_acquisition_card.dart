// lib/pages/dashboard/widgets/gold_cards/customer_acquisition_card.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/dashboard_data.dart';

class CustomerAcquisitionCard extends StatelessWidget {
  final DashboardData dashboardData;

  const CustomerAcquisitionCard({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kpis = dashboardData.kpis;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Clientes', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              '${kpis.newCustomers} novos clientes',
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Gráfico de Barras
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: dashboardData.newCustomersOverTime.asMap().entries.map((entry) {
                    return BarChartGroupData(x: entry.key, barRods: [
                      BarChartRodData(
                        toY: entry.value.count.toDouble(),
                        color: Colors.amber.shade700,
                        width: 15,
                        borderRadius: const BorderRadius.all(Radius.circular(4)),
                      )
                    ]);
                  }).toList(),
                ),
              ),
            ),
            const Divider(),
            // KPI de Retenção
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Taxa de Retenção', style: TextStyle(color: Colors.grey, fontSize: 12)),
                Text('${kpis.retentionRate.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            )
          ],
        ),
      ),
    );
  }
}