// lib/pages/analytics/view/product_analytics_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/models/product_analytics_data.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Adicione esta dependência

import '../cubits/product_analytics_cubit.dart';

class ProductAnalyticsView extends StatelessWidget {
  const ProductAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    // Dispara o carregamento dos dados, se necessário
 //   context.read<ProductAnalyticsCubit>().fetchAnalyticsIfNeeded();

    return BlocBuilder<ProductAnalyticsCubit, ProductAnalyticsState>(
      builder: (context, state) {
        if (state is ProductAnalyticsLoaded) {
          final analytics = state.analyticsData;
          return ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              _SectionWidget(
                title: 'Top 10 Produtos Mais Vendidos',
                child: _TopProductsList(items: analytics.topProducts),
              ),
              const SizedBox(height: 32),
              _AlertsSection(
                lowStockItems: analytics.lowStockItems,
                lowTurnoverItems: analytics.lowTurnoverItems,
              ),
              const SizedBox(height: 32),
              _SectionWidget(
                title: 'Curva ABC de Faturamento',
                subtitle: 'Classificação de produtos pela sua importância no faturamento.',
                child: _AbcAnalysisView(analysis: analytics.abcAnalysis),
              ),
            ],
          );
        }

        if (state is ProductAnalyticsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: (){},
                  child: const Text('Tentar Novamente'),
                )
              ],
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

// --- WIDGETS DE SEÇÃO E COMPONENTES ---

// Widget base para uma seção com título
class _SectionWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionWidget({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
        ],
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

// Lista horizontal para os produtos mais vendidos
class _TopProductsList extends StatelessWidget {
  final List<TopProductItem> items;
  const _TopProductsList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyState(message: 'Não há dados de vendas suficientes para mostrar os produtos mais vendidos.');
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _TopProductCard(item: items[index]);
        },
      ),
    );
  }
}

// Card para um produto da lista de mais vendidos
class _TopProductCard extends StatelessWidget {
  final TopProductItem item;
  const _TopProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return SizedBox(
      width: 180,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator.adaptive()),
                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '${item.unitsSold} vendidos',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    currencyFormat.format(item.revenue / 100),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Seção que agrupa os alertas de estoque e baixo giro
class _AlertsSection extends StatelessWidget {
  final List<LowStockItem> lowStockItems;
  final List<LowTurnoverItem> lowTurnoverItems;

  const _AlertsSection({required this.lowStockItems, required this.lowTurnoverItems});

  @override
  Widget build(BuildContext context) {
    // Layout responsivo para os alertas
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 800) {
          // Em telas pequenas, um abaixo do outro
          return Column(
            children: [
              _AlertCard(
                title: 'Estoque Baixo',
                icon: Icons.inventory_2_outlined,
                color: Colors.orange,
                items: lowStockItems,
                itemBuilder: (item) => Text('${(item as LowStockItem).name}: ${item.stockQuantity} em estoque (mín. ${item.minimumStockLevel})'),
              ),
              const SizedBox(height: 16),
              _AlertCard(
                title: 'Baixo Giro',
                icon: Icons.trending_down,
                color: Colors.blueGrey,
                items: lowTurnoverItems,
                itemBuilder: (item) => Text('${(item as LowTurnoverItem).name}: ${item.daysSinceLastSale} dias sem vender'),
              ),
            ],
          );
        } else {
          // Em telas largas, lado a lado
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _AlertCard(
                  title: 'Estoque Baixo',
                  icon: Icons.inventory_2_outlined,
                  color: Colors.orange,
                  items: lowStockItems,
                  itemBuilder: (item) => Text('${(item as LowStockItem).name}: ${item.stockQuantity} em estoque (mín. ${item.minimumStockLevel})'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _AlertCard(
                  title: 'Baixo Giro',
                  icon: Icons.trending_down,
                  color: Colors.blueGrey,
                  items: lowTurnoverItems,
                  itemBuilder: (item) => Text('${(item as LowTurnoverItem).name}: ${item.daysSinceLastSale} dias sem vender'),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

// Card genérico para exibir uma lista de alertas
class _AlertCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<dynamic> items;
  final Widget Function(dynamic item) itemBuilder;

  const _AlertCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                Chip(label: Text(items.length.toString())),
              ],
            ),
            const Divider(height: 24),
            if (items.isEmpty)
              const _EmptyState(message: 'Nenhum alerta para exibir.')
            else
              ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: itemBuilder(item),
              )),
          ],
        ),
      ),
    );
  }
}

// Widget para exibir a análise da Curva ABC
class _AbcAnalysisView extends StatelessWidget {
  final AbcAnalysis analysis;
  const _AbcAnalysisView({required this.analysis});

  @override
  Widget build(BuildContext context) {
    if (analysis.classAItems.isEmpty && analysis.classBItems.isEmpty && analysis.classCItems.isEmpty) {
      return const _EmptyState(message: 'Não há dados de faturamento para gerar a Curva ABC.');
    }

    return Column(
      children: [
        _AbcExpansionTile(
          title: 'Classe A',
          subtitle: 'Os mais importantes (~80% do faturamento)',
          items: analysis.classAItems,
          color: Colors.green,
        ),
        const SizedBox(height: 8),
        _AbcExpansionTile(
          title: 'Classe B',
          subtitle: 'Importância intermediária (~15% do faturamento)',
          items: analysis.classBItems,
          color: Colors.orange,
        ),
        const SizedBox(height: 8),
        _AbcExpansionTile(
          title: 'Classe C',
          subtitle: 'Menos importantes (~5% do faturamento)',
          items: analysis.classCItems,
          color: Colors.red,
        ),
      ],
    );
  }
}

// Painel expansível para cada classe da Curva ABC
class _AbcExpansionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<AbcItem> items;
  final Color color;

  const _AbcExpansionTile({
    required this.title,
    required this.subtitle,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        leading: CircleAvatar(backgroundColor: color, child: Text(title[title.length - 1], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        children: [
          const Divider(height: 1),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Nenhum produto nesta classe.'),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                // Tabela para telas largas
                if (constraints.maxWidth > 500) {
                  return DataTable(
                    columns: const [
                      DataColumn(label: Text('Produto')),
                      DataColumn(label: Text('Faturamento'), numeric: true),
                      DataColumn(label: Text('Contribuição'), numeric: true),
                    ],
                    rows: items.map((item) => DataRow(cells: [
                      DataCell(Text(item.name)),
                      DataCell(Text(currencyFormat.format(item.revenue / 100))),
                      DataCell(Text('${item.contributionPercentage.toStringAsFixed(2)}%')),
                    ])).toList(),
                  );
                } else {
                  // Lista para telas pequenas
                  return Column(
                    children: items.map((item) => ListTile(
                      title: Text(item.name),
                      subtitle: Text('Contribuição: ${item.contributionPercentage.toStringAsFixed(2)}%'),
                      trailing: Text(currencyFormat.format(item.revenue / 100)),
                    )).toList(),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}

// Widget para exibir um estado vazio de forma consistente
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }
}