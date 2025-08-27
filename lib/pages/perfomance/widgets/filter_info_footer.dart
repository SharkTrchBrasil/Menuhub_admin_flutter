// lib/pages/performance/widgets/filter_info_footer.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterInfoFooter extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const FilterInfoFooter({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    // Formatação para o dia e mês (ex: 23/08)
    final dateFormat = DateFormat('dd/MM');

    // O período de vendas do iFood geralmente termina no dia seguinte às 04:59
    final visualEndDate = endDate.add(const Duration(days: 1));

    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        alignment: Alignment.center,
        child: Text.rich(
          TextSpan(
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey.shade600),
            children: [
              const TextSpan(text: 'Dados das vendas concluídas entre o dia '),
              TextSpan(
                text: dateFormat.format(startDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' às 05:00 e '),
              TextSpan(
                text: dateFormat.format(visualEndDate),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const TextSpan(text: ' às 04:59'),
            ],
          ),
          textAlign: TextAlign.center,
          softWrap: true,
          overflow: TextOverflow.ellipsis, // 🔹 mostra "..." se passar do limite
          maxLines: 2, // 🔹 limita a 2 linhas no mobile
        ),
      ),
    );

  }
}