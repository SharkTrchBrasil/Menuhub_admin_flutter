// Em lib/pages/dashboard/dashboard_cards_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/dashboard/cards/reputation_summary_card.dart';

import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';
import 'customer_acquisition_card.dart';
import 'financial_summary_card.dart';
import 'operational_performance_card.dart';
class DashboardCardsScreen extends StatelessWidget {
  const DashboardCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<StoresManagerCubit, StoresManagerState, StoresManagerLoaded?>(
      selector: (state) => state is StoresManagerLoaded ? state : null,
      builder: (context, loadedState) {
        if (loadedState == null || loadedState.dashboardData == null || loadedState.activeStore == null ) {
          return const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()));
        }

        final dashboard = loadedState.dashboardData!;
      //  final ratings = loadedState.activeStore!.relations.ratingsSummary!;

        final cards = [
          FinancialSummaryCard(dashboardData: dashboard),
          CustomerAcquisitionCard(dashboardData: dashboard),
          OperationalPerformanceCard(dashboardData: dashboard),
          // ReputationSummaryCard(
          //   ratings: ratings,
          //   topProductByRevenue: dashboard.topProductByRevenue,
          // ),
        ];

        return Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          children: cards.map((card) {
            return LayoutBuilder(
              builder: (context, constraints) {
                // ... sua lógica de largura responsiva
                double cardWidth;
                if (constraints.maxWidth > 1200) {
                  cardWidth = (constraints.maxWidth - 48) / 4;
                } else if (constraints.maxWidth > 900) {
                  cardWidth = (constraints.maxWidth - 32) / 3;
                } else if (constraints.maxWidth > 600) {
                  cardWidth = (constraints.maxWidth - 16) / 2;
                } else {
                  cardWidth = constraints.maxWidth;
                }

                return SizedBox(
                  width: cardWidth,
                  height: 280, // Aumentamos um pouco a altura para o novo conteúdo
                  child: card,
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}