// lib/pages/performance/tabs/sales_tab_view.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/pages/perfomance/widgets/payment_methods_summary.dart';
import '../../../models/performance_data.dart';
import '../widgets/comparative_card.dart';
import '../widgets/order_status_cards.dart';
import 'interactive_sales_chart.dart';

class SalesTabView extends StatelessWidget {
  final StorePerformance data;
  const SalesTabView({super.key, required this.data});

  String _formatCurrency(double value) =>
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBuilder.isMobile(context);

    // 🔹 RESPONSIVE: Use Wrap for cards, which automatically breaks lines on smaller screens.
    final summaryCards = [
      ComparativeCard(title: "Faturamento", metric: data.summary.totalValue, formatter: _formatCurrency),
      ComparativeCard(title: "Lucro Bruto", metric: data.grossProfit, formatter: _formatCurrency),
      ComparativeCard(title: "Ticket Médio", metric: data.summary.averageTicket, formatter: _formatCurrency),
      ComparativeCard(title: "Vendas Concluídas", metric: data.summary.completedSales, formatter: (v) => v.toInt().toString()),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: ListView(
      //  crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Resumo de Vendas vs. Período Anterior",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // 🔹 RESPONSIVE: Wrap is a great way to handle a variable number of cards.
          Wrap(
            spacing: 16.0, // Horizontal space between cards
            runSpacing: 16.0, // Vertical space between cards when they wrap
            children: summaryCards.map((card) {
              // On desktop, give each card a flexible width. On mobile, let them take full width.
              if (isMobile) return card;
              return ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 250), // Minimum width for desktop cards
                child: IntrinsicWidth(child: card),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          OrderStatusCards(counts: data.orderStatusCounts),
          const SizedBox(height: 24),
          // ✅ ADICIONE O NOVO WIDGET AQUI
          PaymentMethodsSummary(paymentData: data.paymentMethods),
          const SizedBox(height: 24),
          InteractiveSalesChart(trendData: data.dailyTrend),
        ],
      ),
    );
  }
}