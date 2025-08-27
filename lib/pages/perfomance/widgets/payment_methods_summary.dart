// lib/pages/performance/widgets/payment_methods_summary.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../models/performance_data.dart';

class PaymentMethodsSummary extends StatelessWidget {
  final List<PaymentMethodSummary> paymentData;
  const PaymentMethodsSummary({super.key, required this.paymentData});

  String _formatCurrency(double value) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total por Forma de Pagamento", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),

            if (paymentData.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(16), child: Text("Nenhuma venda registrada no período.")))
            else
              _buildChartAndLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildChartAndLegend(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gráfico de Rosca (Doughnut Chart)
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 200,
            child: SfCircularChart(
              legend: Legend(isVisible: false), // A legenda será nossa lista customizada
              series: <CircularSeries>[
                DoughnutSeries<PaymentMethodSummary, String>(
                  dataSource: paymentData,
                  xValueMapper: (data, _) => data.methodName,
                  yValueMapper: (data, _) => data.totalValue,
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                  ),
                  enableTooltip: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Lista detalhada (servindo como legenda)
        Expanded(
          flex: 3,
          child: Column(
            children: paymentData.map((p) => ListTile(
              leading: _buildPaymentIcon(p.methodIcon),
              title: Text(p.methodName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${p.transactionCount} vendas'),
              trailing: Text(_formatCurrency(p.totalValue)),
              dense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
            )).toList(),
          ),
        ),
      ],
    );
  }

  // Helper para construir o ícone (o mesmo que já usamos antes)
  Widget _buildPaymentIcon(String? iconKey) {
    if (iconKey != null && iconKey.isNotEmpty) {
      final String assetPath = 'assets/icons/$iconKey';
      return SizedBox(
        width: 24,
        height: 24,
        child: SvgPicture.asset(
          assetPath,
          placeholderBuilder: (context) => const Icon(Icons.credit_card, size: 24),
        ),
      );
    }
    return const Icon(Icons.payment, size: 24);
  }
}