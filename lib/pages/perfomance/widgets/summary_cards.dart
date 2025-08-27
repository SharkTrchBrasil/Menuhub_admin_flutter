// lib/pages/performance/widgets/summary_cards.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/performance_data.dart';
import 'comparative_card.dart'; // Importe o widget que criamos

class SummaryCards extends StatelessWidget {
  final DailySummary summary;

  const SummaryCards({
    super.key,
    required this.summary,
  });

  // Helper para formatação de moeda
  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  @override
  Widget build(BuildContext context) {
    // Agora, em vez de construir cards simples, nós usamos
    // uma Row com os nossos novos e poderosos ComparativeCards.
    return Row(
      children: [
        ComparativeCard(
          title: "Vendas Concluídas",
          metric: summary.completedSales,
          // Formata o valor 'current' da métrica como um inteiro
          formatter: (value) => value.toInt().toString(),
        ),
        const SizedBox(width: 16),
        ComparativeCard(
          title: "Faturamento",
          metric: summary.totalValue,
          // Formata o valor 'current' como moeda
          formatter: _formatCurrency,
        ),
        const SizedBox(width: 16),
        ComparativeCard(
          title: "Ticket Médio",
          metric: summary.averageTicket,
          // Formata o valor 'current' como moeda
          formatter: _formatCurrency,
        ),
      ],
    );
  }
}