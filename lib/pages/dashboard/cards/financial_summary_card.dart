// lib/pages/dashboard/widgets/gold_cards/financial_summary_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:totem_pro_admin/models/dashboard_data.dart';

class FinancialSummaryCard extends StatelessWidget {
  final DashboardData dashboardData;

  const FinancialSummaryCard({super.key, required this.dashboardData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kpis = dashboardData.kpis;
    final isUp = kpis.revenueIsUp;
    final trendColor = isUp ? Colors.green : Colors.red;
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Receita Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 26),


            Row(
              children: [
                Text(
                  currencyFormat.format(kpis.totalRevenue),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                BadgeWidget(
                  percent: kpis.revenueChangePercentage,
                  isPositive: isUp,
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Gráfico de linha com dados reais
            SizedBox(
              height: 100,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(isVisible: false),
                primaryYAxis: NumericAxis(isVisible: false),
                series: <CartesianSeries<SalesData, String>>[
                  LineSeries<SalesData, String>(
                    dataSource: _generateChartData(dashboardData),
                    xValueMapper: (SalesData sales, _) => sales.month,
                    yValueMapper: (SalesData sales, _) => sales.value,
                    color: trendColor,
                    width: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),


            // KPIs secundários
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                _buildKpi(
                    'Ticket Médio',
                    currencyFormat.format(kpis.averageTicket),
                    null
                ),
                // _buildKpi(
                //     'Transações',
                //     kpis.totalTransactions.toString(),
                //     kpis.transactionsIsUp
                // ),
              ],
            )
          ],
        ),
      ),
    );
  }

  List<SalesData> _generateChartData(DashboardData dashboardData) {
    // Converte os dados de salesOverTime para o formato do gráfico
    return dashboardData.salesOverTime.asMap().entries.map((e) {
      final index = e.key;
      final data = e.value;
      return SalesData(
          _getMonthAbbreviation(index),
          data.revenue.toDouble()
      );
    }).toList();
  }

  String _getMonthAbbreviation(int index) {
    final months = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    return months[index % months.length];
  }

  Widget _buildKpi(String label, String value, bool? isUp) {
    Color valueColor = Colors.black87;
    if (isUp != null) {
      valueColor = isUp ? Colors.green : Colors.red;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: valueColor
          ),
        ),
      ],
    );
  }
}

// Widget do badge (importado ou definido aqui)
class BadgeWidget extends StatelessWidget {
  final double percent;
  final bool isPositive;

  const BadgeWidget({
    super.key,
    required this.percent,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: isPositive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 2),
          Text(
            '${percent.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Modelo de dados para o gráfico
class SalesData {
  final String month;
  final double value;

  SalesData(this.month, this.value);
}