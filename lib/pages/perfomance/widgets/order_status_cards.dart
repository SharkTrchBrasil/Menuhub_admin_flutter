// lib/pages/performance/widgets/order_status_cards.dart

import 'package:flutter/material.dart';
import '../../../models/performance_data.dart';

class OrderStatusCards extends StatelessWidget {
  final OrderStatusCounts counts;

  const OrderStatusCards({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    // Usando um Card para agrupar visualmente as contagens
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Row(
          children: [
            _buildStatusCard(
              context,
              title: 'Concluídos',
              count: counts.concluidos,
              color: Colors.green.shade600,
              icon: Icons.check_circle_outline,
            ),
            _buildStatusCard(
              context,
              title: 'Pendentes',
              count: counts.pendentes,
              color: Colors.orange.shade700,
              icon: Icons.pending_outlined,
            ),
            _buildStatusCard(
              context,
              title: 'Cancelados',
              count: counts.cancelados,
              color: Colors.red.shade700,
              icon: Icons.highlight_off,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, {
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    // Widget interno para cada status individual
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}