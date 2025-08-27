// lib/pages/performance/widgets/comparative_card.dart
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/performance_data.dart';

class ComparativeCard extends StatelessWidget {
  final String title;
  final ComparativeMetric metric;
  final String Function(double) formatter;

  const ComparativeCard({
    super.key,
    required this.title,
    required this.metric,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final double? current = metric.current;
    final double? previous = metric.previous;

    // Garante valores válidos
    final safeCurrent = current ?? 0.0;
    final safePrevious = previous ?? 0.0;

    // Calcula a variação
    final change = (previous != null && previous != 0)
        ? ((safeCurrent - safePrevious) / safePrevious) * 100
        : (safeCurrent > 0 ? 100.0 : 0.0);

    final isValidChange = change.isFinite && !change.isNaN;
    final color = change >= 0 ? Colors.green.shade700 : Colors.red.shade700;
    final icon = change >= 0 ? Icons.arrow_upward : Icons.arrow_downward;
    final changeText = '${change.toStringAsFixed(1)}%';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              formatter(safeCurrent),
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (isValidChange) ...[
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    changeText,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  'vs ${formatter(safePrevious)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
