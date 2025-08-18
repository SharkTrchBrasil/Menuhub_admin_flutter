

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:provider/provider.dart';
import 'package:totem_pro_admin/pages/dashboard/widgets/empty_state.dart';
import 'package:totem_pro_admin/pages/dashboard/widgets/top_product_card.dart';

import 'package:totem_pro_admin/widgets/dot_loading.dart';

import '../../ConstData/colorprovider.dart';
import '../../ConstData/staticdata.dart';

import '../../ConstData/typography.dart';

import '../../core/di.dart';
import '../../core/enums/dashboard_status.dart';
import '../../cubits/store_manager_cubit.dart';
import '../../cubits/store_manager_state.dart';
import '../../models/dashboard_data.dart'; // Importe seu modelo de dados

import '../../repositories/dashboard_repository.dart';
import 'cubit/dashboard_cubit.dart';
import 'cubit/dashboard_state.dart';
import 'widgets/dashboard_widget.dart'; // Onde seus widgets customizados estão

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, storeState) {
        if (storeState is! StoresManagerLoaded) {
          return const Scaffold(
            body: Center(
              child: DotLoading(), // Ou um widget de "Selecione uma loja"
            ),
          );
        }

        // ✅ LÓGICA DE CRIAÇÃO SIMPLIFICADA
        return BlocProvider(
          create: (context) => DashboardCubit(
            dashboardRepository: getIt<DashboardRepository>(),
            // A única dependência agora é o Cubit principal
            storesManagerCubit: context.read<StoresManagerCubit>(),
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




    return Scaffold(


      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          switch (state.status) {
            case DashboardStatus.initial:
            case DashboardStatus.loading:
              return const Center(child: DotLoading());
            case DashboardStatus.error:
              return Center( /* ... (seu widget de erro - está perfeito) ... */ );
            case DashboardStatus.success:
              final dashboardData = state.data;
              if (dashboardData == null) {
                return const Center(child: Text('Dados não encontrados.'));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(padding),

                    child: _buildResponsiveLayout(context, constraints, dashboardData, notifire, state),
                  );
                },
              );
          }
        },
      ),
    );
  }


  Widget _buildResponsiveLayout(BuildContext context, BoxConstraints constraints, DashboardData data, ColorNotifire notifire, DashboardState state) {

    final kpiSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BalanceCard(notifire: notifire, kpis: data.kpis),
        const SizedBox(height: 30),

        // ✅ CHAMADA PARA OS PRODUTOS EM DESTAQUE ✅
        TopItemsSection(
          title: "Produtos em Destaque",
          items: data.topProducts, // <- Passa a lista de produtos
          emptyStateMessage: "Não há dados de vendas suficientes para mostrar os produtos mais vendidos.",
          notifire: notifire,
        ),

        const SizedBox(height: 30),

        // ✅ CHAMADA PARA AS CATEGORIAS EM DESTAQUE ✅
        TopItemsSection(
          title: "Categorias em Destaque",
          items: data.topCategories, // <- Passa a lista de categorias
          emptyStateMessage: "Não há dados de vendas suficientes para mostrar as categorias mais vendidas.",
          notifire: notifire,
        ),

        const SizedBox(height: 30),

      ],
    );

    // O conteúdo principal agora é construído com acesso a todas as variáveis necessárias
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
        // Para telas menores, o StatsHeaderMobile é mostrado além do StatsHeader principal (que se adapta)
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
              // ConversionSection(notifire: notifire),
            ],
          )
        else
          Row(
            children: [
              Expanded(child: PaymentMethodsSummaryCard(
                notifire: notifire,
                paymentMethods: data.paymentMethods,
              ),),
              const SizedBox(width: 24),
              // Expanded(child: ConversionSection(notifire: notifire)),
            ],
          ),
      ],
    );

    if (constraints.maxWidth < 1000) {
      // Layout em Coluna para Mobile/Tablet
      return Column(
        children: [


          kpiSection,
          SizedBox(height: padding),
          mainContentSection,
        ],
      );
    } else {
      // Layout em Linha para Desktop
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

// dentro de 'dashboard_widgets.dart'

class TopItemsSection extends StatelessWidget {
  // Parâmetros que a tornam reutilizável
  final String title;
  final List<TopItem> items;
  final String emptyStateMessage;
  final ColorNotifire notifire;

  const TopItemsSection({
    super.key,
    required this.title,
    required this.items,
    required this.emptyStateMessage,
    required this.notifire,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Typographyy.heading5.copyWith(color: notifire.getTextColor),
        ),
        const SizedBox(height: 16),

        if (items.isEmpty)
          EmptyStateWidget(
            icon: Icons.sentiment_dissatisfied_outlined,
            title: "Nenhum dado encontrado",
            message: emptyStateMessage,
            notifire: notifire,
          )
        else
          SizedBox(
            height: 240,
            child: ListView.separated(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final currentItem = items[index];
                return SizedBox(
                  width: 280,
                  child: TopItemCard(
                    product: currentItem,
                    notifire: notifire,
                  ),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 16),
            ),
          ),
      ],
    );
  }

}