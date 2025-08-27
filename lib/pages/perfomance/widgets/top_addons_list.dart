import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/performance_data.dart';

class TopAddonsList extends StatelessWidget {
  final List<TopAddon> addons;
  const TopAddonsList({super.key, required this.addons});

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
            Text("Complementos Mais Vendidos", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (addons.isEmpty)
              const Text("Nenhum complemento vendido neste dia.")
            else
              ...addons.map((addon) => ListTile(
                title: Text(addon.addonName),
                subtitle: Text('${addon.quantitySold} unidades'),
                trailing: Text(_formatCurrency(addon.totalValue)),
              )),
          ],
        ),
      ),
    );
  }
}