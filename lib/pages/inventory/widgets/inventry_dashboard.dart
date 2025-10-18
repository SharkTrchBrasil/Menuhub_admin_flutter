// inventry_dashboard.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/responsive_builder.dart';

class InventoryDashboard extends StatelessWidget {
  final int inStockCount, lowStockCount, outOfStockCount;
  const InventoryDashboard({
    required this.inStockCount,
    required this.lowStockCount,
    required this.outOfStockCount,
  });

  @override
  Widget build(BuildContext context) {
    final totalItems = inStockCount + lowStockCount + outOfStockCount;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ResponsiveBuilder(
          desktopBuilder: (context, constraints) => Row(
            children: [
              Expanded(flex: 2, child: _buildStats(context, totalItems)),
              if (totalItems > 0) ...[
                const SizedBox(width: 40),
                Expanded(flex: 1, child: _buildChart()),
              ],
            ],
          ),
          mobileBuilder: (context, constraints) => Column(
            children: [
              _buildStats(context, totalItems),
              if (totalItems > 0) ...[
                const SizedBox(height: 24),
                _buildChart(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, int totalItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.analytics_outlined,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Visão Geral do Estoque',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _StatTile(
          color: Colors.green,
          icon: Icons.check_circle_outline,
          label: 'Em Estoque',
          value: inStockCount,
          percentage: totalItems > 0 ? (inStockCount / totalItems * 100) : 0,
        ),
        const SizedBox(height: 16),
        _StatTile(
          color: Colors.orange,
          icon: Icons.warning_amber_outlined,
          label: 'Estoque Baixo',
          value: lowStockCount,
          percentage: totalItems > 0 ? (lowStockCount / totalItems * 100) : 0,
        ),
        const SizedBox(height: 16),
        _StatTile(
          color: Colors.red,
          icon: Icons.error_outline,
          label: 'Esgotado',
          value: outOfStockCount,
          percentage: totalItems > 0 ? (outOfStockCount / totalItems * 100) : 0,
        ),
      ],
    );
  }

  Widget _buildChart() {
    final total = inStockCount + lowStockCount + outOfStockCount;
    if (total == 0) {
      return Container(
        height: 160,
        child: Center(
          child: Text(
            'Sem dados',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                  value: inStockCount.toDouble(),
                  color: Colors.green,
                  title: '${(inStockCount / total * 100).toStringAsFixed(0)}%',
                  radius: 25,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                PieChartSectionData(
                  value: lowStockCount.toDouble(),
                  color: Colors.orange,
                  title: '${(lowStockCount / total * 100).toStringAsFixed(0)}%',
                  radius: 25,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                PieChartSectionData(
                  value: outOfStockCount.toDouble(),
                  color: Colors.red,
                  title: '${(outOfStockCount / total * 100).toStringAsFixed(0)}%',
                  radius: 25,
                  titleStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Distribuição do Estoque',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final int value;
  final double percentage;

  const _StatTile({
    required this.color,
    required this.icon,
    required this.label,
    required this.value,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}