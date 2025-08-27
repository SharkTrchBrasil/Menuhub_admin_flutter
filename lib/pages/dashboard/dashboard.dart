import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/pages/dashboard/widgets/cards/temps.dart';


import 'package:totem_pro_admin/pages/dashboard/widgets/insights_carousel.dart';
import 'package:totem_pro_admin/pages/dashboard/widgets/payables_summary_widget.dart';
import 'package:totem_pro_admin/pages/dashboard/widgets/top_items_section.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';

import '../../ConstData/colorprovider.dart';
import '../../ConstData/staticdata.dart';


import '../../ConstData/typography.dart';
import '../../core/di.dart';
import '../../core/enums/dashboard_status.dart';
import '../../cubits/store_manager_cubit.dart';
import '../../cubits/store_manager_state.dart';
import '../../models/dashboard_data.dart';

import '../../repositories/dashboard_repository.dart';

import 'cards/DashboardCardsScreen.dart';
import 'cubit/dashboard_cubit.dart';
import 'cubit/dashboard_state.dart';
import 'widgets/dashboard_widget.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, storeState) {
        if (storeState is! StoresManagerLoaded) {
          return const Scaffold(
            body: Center(
              child: DotLoading(), // ou widget "Selecione uma loja"
            ),
          );
        }

        return BlocProvider(
          create: (context) => DashboardCubit(
            dashboardRepository: getIt<DashboardRepository>(),
            storesManagerCubit: context.read<StoresManagerCubit>(),
            realtimeRepository: getIt<RealtimeRepository>(),
          ),
          child: const _DashboardView(),
        );


      },
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
   // final notifire = Provider.of<ColorNotifire>(context); // ✅ correção

    return Scaffold(
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          switch (state.status) {
            case DashboardStatus.initial:
            case DashboardStatus.loading:
              return const Center(child: DotLoading());

            case DashboardStatus.error:
              return Center(child: Text(state.errorMessage ?? 'Erro'));

            case DashboardStatus.success:
              final dashboardData = state.data;
              if (dashboardData == null) {
                return const Center(child: Text('Dados não encontrados.'));
              }




              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        AcmePlusCard(),
                        SizedBox(height: 16),
                        AcmeAdvancedCard(),
                        SizedBox(height: 16),
                        AcmeProfessionalCard(),



                        // Seu cabeçalho aqui (se houver, como "Dashboard")
                        Text('Resumo do Mês', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 24),

                        // ✅ AQUI É ONDE OS CARDS SÃO CONSTRUÍDOS
                        const DashboardCardsScreen(),

                        const SizedBox(height: 24),




                        if (state.payablesMetrics != null)
                          Column(
                            children: [
                              if (state.insights.isNotEmpty) ...[
                                InsightsCarousel(insights: state.insights),
                                const SizedBox(height: 24),
                              ],
                              PayablesSummaryWidget(
                                metrics: state.payablesMetrics!,
                              ),
                            ],
                          ),
                        _buildResponsiveLayout(
                          context,
                          constraints,
                          dashboardData,
                          notifire,
                          state,
                        ),
                      ],
                    ),
                  );
                },
              );
          }
        },
      ),
    );
  }

  Widget _buildResponsiveLayout(
      BuildContext context,
      BoxConstraints constraints,
      DashboardData data,
      ColorNotifire notifire,
      DashboardState state,
      ) {





    final kpiSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BalanceCard(notifire: notifire, kpis: data.kpis),
        const SizedBox(height: 30),
        TopItemsSection(
          title: "Produtos em Destaque",
          items: data.topProducts,
          emptyStateMessage:
          "Não há dados de vendas suficientes para mostrar os produtos mais vendidos.",
          notifire: notifire,
        ),
        const SizedBox(height: 30),
        TopItemsSection(
          title: "Categorias em Destaque",
          items: data.topCategories,
          emptyStateMessage:
          "Não há dados de vendas suficientes para mostrar as categorias mais vendidas.",
          notifire: notifire,
        ),
        const SizedBox(height: 30),
      ],
    );

    final mainContentSection = Column(
      children: [
        QuickLinksGrid(notifire: notifire, size: constraints.maxWidth),
        const SizedBox(height: 30),
        StatsHeader(
          notifire: notifire,
          size: constraints.maxWidth,
          kpis: data.kpis,
          selectedRange: state.selectedRange,
          onRangeSelected: (newRange) {
            context.read<DashboardCubit>().changeDateFilter(newRange);
          },
        ),
        if (constraints.maxWidth < 800) ...[
          const SizedBox(height: 15),
          StatsHeaderMobile(notifire: notifire, kpis: data.kpis),
        ],
        const SizedBox(height: 30),
        StatisticsChart(
          notifire: notifire,
          size: constraints.maxWidth,
          salesData: data.salesOverTime,
        ),
        const SizedBox(height: 30),
        if (constraints.maxWidth < 800)
          Column(
            children: [
              PaymentMethodsSummaryCard(
                notifire: notifire,
                paymentMethods: data.paymentMethods,
              ),
              const SizedBox(height: 24),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: PaymentMethodsSummaryCard(
                  notifire: notifire,
                  paymentMethods: data.paymentMethods,
                ),
              ),
              // 🔧 se não houver outro card, pode remover o SizedBox abaixo
              const SizedBox(width: 24),
            ],
          ),
      ],
    );

    if (constraints.maxWidth < 1000) {
      return Column(
        children: [kpiSection, SizedBox(height: padding), mainContentSection],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: kpiSection),
          SizedBox(width: padding),
          Expanded(flex: 5, child: mainContentSection),
        ],
      );
    }
  }
}
