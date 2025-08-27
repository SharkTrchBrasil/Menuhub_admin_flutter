// lib/pages/performance/performance_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';

import 'package:totem_pro_admin/pages/perfomance/widgets/customers_tab_view.dart';
import 'package:totem_pro_admin/pages/perfomance/widgets/menu_tab_view.dart';
import 'package:totem_pro_admin/pages/perfomance/widgets/ordr_tab_view.dart';
import 'package:totem_pro_admin/pages/perfomance/widgets/persistent_filter_bar.dart';
import 'package:totem_pro_admin/pages/perfomance/widgets/sales_tab_view.dart';

import 'package:totem_pro_admin/pages/perfomance/widgets/today_summary_card.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';

import '../../core/helpers/sidepanel.dart';
import 'cubit/performance_cubit.dart';

import 'widgets/filter_info_footer.dart';
import 'widgets/filter_side_panel.dart';


class PerformancePage extends StatefulWidget {
  const PerformancePage({super.key});

  @override
  State<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends State<PerformancePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 6));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<PerformanceCubit>().loadDataForPeriod(startDate: _startDate, endDate: _endDate);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openFilterPanel() {

    showResponsiveSidePanel(
      context,

      FilterSidePanel(
        initialStartDate: _startDate,
        initialEndDate: _endDate,
        onApply: (newStart, newEnd) {
          _applyFilters(newStart, newEnd);
          Navigator.of(context).pop();
        },
      ),
    );




  }

  void _applyFilters(DateTime newStart, DateTime newEnd) {
    setState(() {
      _startDate = newStart;
      _endDate = newEnd;
    });
    context.read<PerformanceCubit>().loadDataForPeriod(startDate: newStart, endDate: newEnd);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveBuilder.isMobile(context) ? 14 : 24.0,
                ),
                child: _buildHeaderContent(),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(height: 28,),
            ) ,

            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: ResponsiveBuilder.isMobile(context) ? true : false,

                  tabAlignment: ResponsiveBuilder.isMobile(context)
                      ? TabAlignment.start
                      : TabAlignment.center, // Para TabBar não rolável, o padrão é preencher.


                  indicatorSize: TabBarIndicatorSize.label,


                  tabs: const [
                    Tab(text: 'Vendas'),
                    Tab(text: 'Cardápio'),
                    Tab(text: 'Clientes'),
                    Tab(text: 'Pedidos'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveBuilder.isMobile(context) ? 14 : 24.0,
          ),
          child: BlocBuilder<PerformanceCubit, PerformanceState>(
            builder: (context, state) {
              if (state is PerformanceLoading) {
                return const Center(child: DotLoading());
              }
              if (state is PerformanceError) {
                return Center(child: Text('Erro: ${state.message}'));
              }
              if (state is PerformanceLoaded) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    SalesTabView(data: state.performanceData),
                    MenuTabView(data: state.performanceData),
                    CustomersTabView(data: state.performanceData),
                    const OrdersTabView(), // Nosso novo widget
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),

      // ✅ ADD THE BOTTOM NAVIGATION BAR FOR MOBILE
      bottomNavigationBar:
           BlocBuilder<PerformanceCubit, PerformanceState>(
        builder: (context, state) {
          if (state is PerformanceLoaded) {
            return PersistentFilterBar(
              startDate: state.startDate,
              endDate: state.endDate,
              onFilterTap: _openFilterPanel,
            );
          }
          return const SizedBox.shrink(); // Hide bar while loading
        },
      )
        // No bottom bar on desktop

    );
  }

  Widget _buildHeaderContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FixedHeader(
          title: 'Desempenho',
          subtitle: 'Acompanhe os principais indicadores da sua loja.',
          actions: [

            DsButton(
              style: DsButtonStyle.secondary,
              onPressed: () {
                // Exemplo de como chamar
                // context.read<AnalyticsRepository>().downloadReport(
                //   storeId: context.read<PerformanceCubit>().storeId,
                //   startDate: _startDate,
                //   endDate: _endDate,
                //   format: 'pdf',
                // );
              },
              label: 'Exportar PDF',
            ),
          ],
        ),
        const SizedBox(height: 20),
        BlocBuilder<PerformanceCubit, PerformanceState>(
          builder: (context, state) {
            if (state is! PerformanceLoaded) {
              return const SizedBox(height: 150, child: Center(child: DotLoading()));
            }
            return Column(

              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Text("Vendas do dia", style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Tooltip(message: "Os valores são atualizados durante o dia e consideram apenas pedidos concluídos.", child: Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600)),
                    ]),
                    TextButton.icon(
                      onPressed: () => context.read<PerformanceCubit>().fetchTodaySummary(),
                      icon: Icon(Icons.refresh, size: 18, color: Theme.of(context).primaryColor),
                      label: Text("Atualizar", style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TodayMetricsCard(summary: state.todaySummary),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilterInfoFooter(startDate: state.startDate, endDate: state.endDate),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}


class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);

    final tabBar = TabBar(
      controller: _tabBar.controller,
      isScrollable: true, // 🔹 sempre scrollable = abas ficam só do tamanho do texto
      tabAlignment: TabAlignment.start, // 🔹 alinha à esquerda
      indicatorSize: TabBarIndicatorSize.label,
      tabs: _tabBar.tabs,
    );

    return Container(
      color: theme.scaffoldBackgroundColor,
      alignment: Alignment.centerLeft,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
