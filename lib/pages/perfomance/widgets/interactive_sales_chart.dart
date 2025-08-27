// lib/pages/performance/widgets/interactive_sales_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../../models/performance_data.dart';
import '../cubit/performance_cubit.dart';

class InteractiveSalesChart extends StatelessWidget {
  final List<DailyTrendPoint> trendData;
  const InteractiveSalesChart({super.key, required this.trendData});

  @override
  Widget build(BuildContext context) {
    // ✅ CORREÇÃO: Tornamos a seleção do estado segura.
    final selectedMetric = context.select((PerformanceCubit cubit) {
      final state = cubit.state;
      // Se o estado for 'PerformanceLoaded', nós pegamos a métrica selecionada.
      if (state is PerformanceLoaded) {
        return state.selectedChartMetric;
      }
      // Caso contrário (ex: durante o Loading), retornamos um valor padrão.
      // Isso evita o erro de cast, pois o gráfico não estará visível de qualquer forma.
      return ChartMetric.sales;
    });

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Seletor de Métricas
            _buildMetricSelector(context, selectedMetric),
            const SizedBox(height: 24),
            // Gráfico
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(dateFormat: DateFormat.Md('pt_BR')),
                primaryYAxis: NumericAxis(
                  numberFormat: (selectedMetric == ChartMetric.value || selectedMetric == ChartMetric.ticket)
                      ? NumberFormat.compactSimpleCurrency(locale: 'pt_BR')
                      : null,
                ),
                series: <CartesianSeries<DailyTrendPoint, DateTime>>[
                  LineSeries<DailyTrendPoint, DateTime>(
                    dataSource: trendData,
                    xValueMapper: (point, _) => point.date,
                    yValueMapper: (point, _) {
                      switch (selectedMetric) {
                        case ChartMetric.sales:
                          return point.salesCount;
                        case ChartMetric.value:
                          return point.totalValue;
                        case ChartMetric.ticket:
                          return point.averageTicket;
                        case ChartMetric.newCustomers:
                          return point.newCustomers;
                      }
                    },
                    markerSettings: const MarkerSettings(isVisible: true),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSelector(BuildContext context, ChartMetric selectedMetric) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('Total de Vendas'),
          selected: selectedMetric == ChartMetric.sales,
          onSelected: (_) => context.read<PerformanceCubit>().changeChartMetric(ChartMetric.sales),
        ),
        ChoiceChip(
          label: const Text('Valor das Vendas'),
          selected: selectedMetric == ChartMetric.value,
          onSelected: (_) => context.read<PerformanceCubit>().changeChartMetric(ChartMetric.value),
        ),
        ChoiceChip(
          label: const Text('Ticket Médio'),
          selected: selectedMetric == ChartMetric.ticket,
          onSelected: (_) => context.read<PerformanceCubit>().changeChartMetric(ChartMetric.ticket),
        ),
        ChoiceChip(
          label: const Text('Novos Clientes'),
          selected: selectedMetric == ChartMetric.newCustomers,
          onSelected: (_) => context.read<PerformanceCubit>().changeChartMetric(ChartMetric.newCustomers),
        ),
      ],
    );
  }
}