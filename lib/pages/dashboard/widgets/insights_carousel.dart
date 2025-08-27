import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:totem_pro_admin/models/dashboard_insight.dart';

import 'holiday_insight_card.dart';
import 'low_mover_insight_card.dart';
import 'low_stock_insight_card.dart';

class InsightsCarousel extends StatefulWidget {
  final List<DashboardInsight> insights;

  const InsightsCarousel({super.key, required this.insights});

  @override
  State<InsightsCarousel> createState() => _InsightsCarouselState();
}

class _InsightsCarouselState extends State<InsightsCarousel> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.insights.isEmpty) {
      return const SizedBox.shrink(); // Não mostra nada se a lista estiver vazia
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💡 Oportunidades e Alertas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220, // Altura do carrossel
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.insights.length,
            itemBuilder: (context, index) {
              // Adiciona um pouco de padding entre os cards no carrossel
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildInsightCard(context, widget.insights[index]),
              );
            },
          ),
        ),
        if (widget.insights.length > 1) ...[
          const SizedBox(height: 16),
          Center(
            child: SmoothPageIndicator(
              controller: _pageController,
              count: widget.insights.length,
              effect: WormEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // Este método decide qual card construir com base no tipo de insight
  Widget _buildInsightCard(BuildContext context, DashboardInsight insight) {
    switch (insight.insightType) {
      case InsightType.upcomingHoliday:
        return HolidayInsightCard(details: insight.details as HolidayInsightDetails);
      case InsightType.lowStock:
        return LowStockInsightCard(details: insight.details as LowStockInsightDetails);
      case InsightType.lowMoverItem:
        return LowMoverInsightCard(details: insight.details as LowMoverInsightDetails);
      default:
        return const Card(child: Center(child: Text('Insight não reconhecido')));
    }
  }
}