// lib/pages/performance/widgets/top_selling_products_list.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/performance_data.dart';

class TopSellingProductsList extends StatelessWidget {
  /// A lista de produtos mais vendidos recebida da API.
  final List<TopSellingProduct> products;

  const TopSellingProductsList({super.key, required this.products});

  /// Helper para formatar valores monetários.
  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título da seção
            Text(
              "Produtos Mais Vendidos",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Lógica para tratar o caso de não haver produtos vendidos
            if (products.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text("Nenhum produto vendido neste dia."),
                ),
              )
            else
            // Mapeia cada produto da lista para um ListTile
              ...products.map(
                    (p) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  // Círculo com o ranking do produto
                  leading: CircleAvatar(
                    child: Text('${products.indexOf(p) + 1}'),
                  ),
                  // Nome do produto
                  title: Text(p.productName),
                  // Subtítulo com a quantidade vendida
                  subtitle: Text('${p.quantitySold} unidades'),
                  // Valor total gerado pelo produto
                  trailing: Text(
                    _formatCurrency(p.totalValue),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}