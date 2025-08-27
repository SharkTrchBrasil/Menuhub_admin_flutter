import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/performance_data.dart';

class ProductFunnelList extends StatelessWidget {
  final List<ProductFunnel> funnelData;
  const ProductFunnelList({super.key, required this.funnelData});

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
            Text("Funil de Vendas de Produtos", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text("Mostra a conversão de visualizações em vendas.", style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            if (funnelData.isEmpty) const Center(child: Padding(padding: EdgeInsets.all(16), child: Text("Nenhum dado de funil para este dia.")))
            else DataTable(
              columns: const [
                DataColumn(label: Text('Produto')),
                DataColumn(label: Text('Visualizações'), numeric: true),
                DataColumn(label: Text('Vendas'), numeric: true),
                DataColumn(label: Text('Conversão'), numeric: true),
              ],
              rows: funnelData.map((item) => DataRow(
                cells: [
                  DataCell(Text(item.productName)),
                  DataCell(Text(item.viewCount.toString())),
                  DataCell(Text(item.salesCount.toString())),
                  DataCell(
                      Text('${item.conversionRate.toStringAsFixed(1)}%',
                        style: TextStyle(fontWeight: FontWeight.bold, color: item.conversionRate > 5 ? Colors.green : (item.conversionRate > 1 ? Colors.orange : Colors.red)),
                      )),
                ],
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}