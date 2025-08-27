// lib/pages/dashboard/widgets/gold_cards/reputation_summary_card.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/dashboard_data.dart';
import 'package:totem_pro_admin/models/rating.dart';

import '../../../models/rating_summary.dart';

class ReputationSummaryCard extends StatelessWidget {
  final RatingsSummary ratings;
  final TopItem? topProductByRevenue;

  const ReputationSummaryCard({
    super.key,
    required this.ratings,
    this.topProductByRevenue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reputação e Destaques', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Text(
                  '${ratings.averageRating.toStringAsFixed(1)} (${ratings.totalRatings} avaliações)',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Gráfico de distribuição de avaliações
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starCount = 5 - index;
                  final count = ratings.distribution[starCount.toString()] ?? 0;
                  final percentage = ratings.totalRatings > 0 ? count / ratings.totalRatings : 0.0;
                  return _buildRatingRow('$starCount ★', percentage);
                }),
              ),
            ),
            if (topProductByRevenue != null) ...[
              const Divider(),
              Text('Produto de Maior Renda', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                topProductByRevenue!.name,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(String label, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text(label, style: const TextStyle(fontSize: 12))),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              color: Colors.amber,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}