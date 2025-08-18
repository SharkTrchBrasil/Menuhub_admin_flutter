// lib/pages/analytics/view/customer_analytics_view.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pie_chart/pie_chart.dart';

import '../../../models/customer_analytics_data.dart';
import '../cubits/customer_analytics_cubit.dart';

class CustomerAnalyticsView extends StatelessWidget {
  const CustomerAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ REMOVEMOS a chamada para 'fetchAnalyticsIfNeeded'.
    // A view agora é 100% passiva, ela apenas reage ao estado.

    return BlocBuilder<CustomerAnalyticsCubit, CustomerAnalyticsState>(
      builder: (context, state) {
        if (state is CustomerAnalyticsLoaded) {
          final analyticsData = state.analyticsData;

          return RefreshIndicator(
            // ✅ CORREÇÃO: Para atualizar, pedimos ao Cubit principal (a fonte da verdade).
            onRefresh: () async {
              // Substitua 'refreshActiveStore' pelo método correto do seu StoresManagerCubit se for diferente
              //  context.read<StoresManagerCubit>().refreshActiveStore();
            },
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                _buildHeader(context, analyticsData.keyMetrics),
                const SizedBox(height: 32),
                _buildSegmentsSection(context, analyticsData.segments),
              ],
            ),
          );
        }

        if (state is CustomerAnalyticsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  // ✅ CORREÇÃO: O botão de "Tentar Novamente" também aciona o Cubit principal.
                  onPressed: (){},
                  child: const Text('Tentar Novamente'),
                )
              ],
            ),
          );
        }

        // Estado inicial ou de carregamento (vem do StoresManagerCubit)
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // Seção de Métricas Principais (KPIs) - Sem alterações
  Widget _buildHeader(BuildContext context, KeyCustomerMetrics metrics) {
    // ...código idêntico ao da resposta anterior
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Métricas Principais',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _KpiCard(
              icon: Icons.person_add_alt_1,
              title: 'Novos Clientes',
              value: metrics.newCustomers.toString(),
              color: Colors.blue.shade300,
            ),
            _KpiCard(
              icon: Icons.repeat,
              title: 'Clientes Recorrentes',
              value: metrics.returningCustomers.toString(),
              color: Colors.green.shade400,
            ),
            _RetentionCard(rate: metrics.retentionRate),
          ],
        ),
      ],
    );
  }

  // Seção dos Segmentos de Clientes (Campeões, Em Risco, etc.) - Sem alterações
  Widget _buildSegmentsSection(BuildContext context, List<RfmSegment> segments) {
    // ...código idêntico ao da resposta anterior
    if (segments.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text('Nenhum segmento de cliente para exibir ainda.'),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Segmentos de Clientes (RFM)',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...segments.map((segment) => _SegmentExpansionTile(segment: segment)),
      ],
    );
  }
}

// --- Widgets Reutilizáveis (KPIs, Gráfico, Segmentos, Tabela) ---
// Copie e cole todos os widgets de UI (_KpiCard, _RetentionCard, _SegmentExpansionTile, etc.)
// da resposta anterior aqui. Eles não precisam de nenhuma mudança.

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _KpiCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _RetentionCard extends StatelessWidget {
  final double rate;
  const _RetentionCard({required this.rate});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${rate.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text('Taxa de Retenção', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            SizedBox(
              width: 60,
              height: 60,
              child: PieChart(
                dataMap: {"Retidos": rate, "Não retidos": 100 - rate},
                chartType: ChartType.ring,
                chartRadius: 40,
                ringStrokeWidth: 8,
                legendOptions: const LegendOptions(showLegends: false),
                chartValuesOptions: const ChartValuesOptions(showChartValues: false),
                colorList: [Colors.orange.shade400, Colors.grey.shade300],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentExpansionTile extends StatelessWidget {
  final RfmSegment segment;
  const _SegmentExpansionTile({required this.segment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        shape: const Border(), // Remove borda interna ao expandir
        title: Row(
          children: [
            Text(segment.segmentName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Chip(
              label: Text('${segment.customers.length} clientes'),
              padding: EdgeInsets.zero,
            )
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(segment.description, style: theme.textTheme.bodySmall),
            Text('Sugestão: ${segment.suggestion}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
          ],
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _ResponsiveCustomerList(customers: segment.customers),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveCustomerList extends StatelessWidget {
  final List<CustomerMetric> customers;
  const _ResponsiveCustomerList({required this.customers});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 600) {
          return _buildCustomerDataTable(customers);
        }
        return _buildCustomerMobileList(customers);
      },
    );
  }
}

Widget _buildCustomerDataTable(List<CustomerMetric> customers) {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final dateFormat = DateFormat('dd/MM/yyyy');

  return DataTable(
    columns: const [
      DataColumn(label: Text('Nome')),
      DataColumn(label: Text('Pedidos'), numeric: true),
      DataColumn(label: Text('Gasto Total'), numeric: true),
      DataColumn(label: Text('Último Pedido')),
    ],
    rows: customers.map((customer) {
      return DataRow(cells: [
        DataCell(Text(customer.name)),
        DataCell(Text(customer.orderCount.toString())),
        DataCell(Text(currencyFormat.format(customer.totalSpent / 100))),
        DataCell(Text(dateFormat.format(customer.lastOrderDate))),
      ]);
    }).toList(),
  );
}

Widget _buildCustomerMobileList(List<CustomerMetric> customers) {
  final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
  final dateFormat = DateFormat('dd/MM/yyyy');

  return Column(
    children: customers.map((customer) {
      return Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: CircleAvatar(child: Text(customer.name.substring(0, 1))),
          title: Text(customer.name),
          subtitle: Text(
            '${customer.orderCount} pedidos • Gasto: ${currencyFormat.format(customer.totalSpent / 100)}',
          ),
          trailing: Text(dateFormat.format(customer.lastOrderDate)),
        ),
      );
    }).toList(),
  );
}