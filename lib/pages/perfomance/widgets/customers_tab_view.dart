// lib/pages/performance/tabs/customers_tab_view.dart
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import '../../../models/performance_data.dart';
import '../widgets/comparative_card.dart';
import '../widgets/orders_section.dart';

class CustomersTabView extends StatelessWidget {
  final StorePerformance data;
  const CustomersTabView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // ✅ Começa com um ListView, NUNCA um Scaffold.
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      children: [
        Text(
          "Análise de Aquisição e Retenção",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (ResponsiveBuilder.isMobile(context)) {
              return Column(
                children: [
                  ComparativeCard(title: "Novos Clientes", metric: data.customerAnalytics.newCustomers, formatter: (v) => v.toInt().toString()),
                  const SizedBox(height: 16),
                  ComparativeCard(title: "Clientes Recorrentes", metric: data.customerAnalytics.returningCustomers, formatter: (v) => v.toInt().toString()),
                ],
              );
            }
            return Row(children: [
              Expanded(child: ComparativeCard(title: "Novos Clientes", metric: data.customerAnalytics.newCustomers, formatter: (v) => v.toInt().toString())),
              const SizedBox(width: 16),
              Expanded(child: ComparativeCard(title: "Clientes Recorrentes", metric: data.customerAnalytics.returningCustomers, formatter: (v) => v.toInt().toString())),
            ]);
          },
        ),

      ],
    );
  }
}