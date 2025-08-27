// lib/widgets/dashboard/customer_satisfaction_card.dart

import 'package:flutter/material.dart';

class CustomerSatisfactionCard extends StatelessWidget {
  // ✅ DADOS REAIS: Recebe o mapa com a contagem de cada estrela
  final Map<int, int> ratingsDistribution;
  final int totalRatings;
  final double percentageChange;

  const CustomerSatisfactionCard({
    super.key,
    required this.ratingsDistribution,
    required this.totalRatings,
    required this.percentageChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isUp = percentageChange >= 0;
    final Color trendColor = isUp ? Colors.green : Colors.blue.shade700;
    final IconData trendIcon = isUp ? Icons.trending_up : Icons.trending_down;

    // ✅ CÁLCULO REAL DA SATISFAÇÃO
    // Média ponderada: (5*count5 + 4*count4 + ...) / (total_ratings * 5)
    double weightedTotal = 0;
    ratingsDistribution.forEach((star, count) {
      weightedTotal += star * count;
    });
    // O valor máximo possível seria se todas as avaliações fossem 5 estrelas
    final double maxPossibleScore = totalRatings * 5.0;
    // A taxa de satisfação é a pontuação real dividida pela máxima possível
    final double satisfactionRate = maxPossibleScore > 0 ? (weightedTotal / maxPossibleScore) : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Satisfação', style: theme.textTheme.titleMedium),
                const Icon(Icons.more_vert, size: 18, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge de tendência
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: trendColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(percentageChange * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                            fontSize: 12,
                            color: trendColor,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 2),
                      Icon(trendIcon, size: 14, color: trendColor),
                    ],
                  ),
                ),
                // Valor Principal
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(satisfactionRate * 100).toStringAsFixed(1)}%',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'no último mês',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(), // Ocupa o espaço do meio
            // Barra de Progresso
            LinearProgressIndicator(
              value: satisfactionRate, // Usa a taxa de satisfação real
              backgroundColor: Colors.grey[200],
              color: Colors.blue.shade700,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      ),
    );
  }
}