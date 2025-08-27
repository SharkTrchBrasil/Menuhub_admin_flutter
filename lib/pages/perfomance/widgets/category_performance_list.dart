// lib/pages/performance/widgets/category_performance_list.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/performance_data.dart';

class CategoryPerformanceList extends StatelessWidget {
  final List<CategoryPerformance> categories;
  const CategoryPerformanceList({super.key, required this.categories});

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  @override
  Widget build(BuildContext context) {
    // Calcula o faturamento total para a porcentagem
    final totalRevenue = categories.fold(0.0, (sum, item) => sum + item.totalValue);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Performance por Categoria", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (categories.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: Text("Nenhuma categoria com vendas neste dia.")),
              )
            else
              ...categories.map((cat) {
                final percentageOfRevenue = totalRevenue > 0 ? (cat.totalValue / totalRevenue) : 0.0;
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(cat.categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${cat.itemsSold} itens vendidos | Lucro: ${_formatCurrency(cat.grossProfit)}"),
                  trailing: Text(_formatCurrency(cat.totalValue)),
                  // Adicionando um indicador visual da participação no faturamento
                  leading: SizedBox(
                    width: 50,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${(percentageOfRevenue * 100).toStringAsFixed(0)}%", style: const TextStyle(fontWeight: FontWeight.bold)),
                        LinearProgressIndicator(
                          value: percentageOfRevenue,
                          backgroundColor: Colors.grey.shade300,
                          color: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}