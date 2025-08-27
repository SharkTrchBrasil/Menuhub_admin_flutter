import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/responsive_builder.dart';




class InventoryDashboard extends StatelessWidget {
  final int inStockCount, lowStockCount, outOfStockCount;
  const InventoryDashboard({required this.inStockCount, required this.lowStockCount, required this.outOfStockCount});

  @override
  Widget build(BuildContext context) {
    final totalItems = inStockCount + lowStockCount + outOfStockCount;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300)
      ),
      child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ResponsiveBuilder(

            desktopBuilder: (BuildContext context, BoxConstraints constraints) { return    Row(
              children: [
                Expanded(flex: 2, child: _buildStats(context)),
                if (totalItems > 0) Expanded(flex: 1, child: _buildChart()),
              ],
            ); }, mobileBuilder: (BuildContext context, BoxConstraints constraints) {
            return  Column(
              children: [
                _buildStats(context),
                if (totalItems > 0) ...[const SizedBox(height: 20), _buildChart()],
              ],
            );
          },
          )
      ),
    );
  }

  Widget _buildStats(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumo do Estoque', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _StatTile(color: Colors.green, label: 'Em Estoque', value: inStockCount),
        const SizedBox(height: 8),
        _StatTile(color: Colors.orange, label: 'Estoque Baixo', value: lowStockCount),
        const SizedBox(height: 8),
        _StatTile(color: Colors.red, label: 'Esgotado', value: outOfStockCount),
      ],
    );
  }

  Widget _buildChart() {
    return SizedBox(
      height: 120,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 30,
          sections: [
            PieChartSectionData(value: inStockCount.toDouble(), color: Colors.green, title: '', radius: 25),
            PieChartSectionData(value: lowStockCount.toDouble(), color: Colors.orange, title: '', radius: 25),
            PieChartSectionData(value: outOfStockCount.toDouble(), color: Colors.red, title: '', radius: 25),
          ],
        ),
      ),
    );
  }

}
class _StatTile extends StatelessWidget {
  final Color color;
  final String label;
  final int value;
  const _StatTile({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text('$label:', style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text('$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
