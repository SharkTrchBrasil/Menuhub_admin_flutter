// lib/pages/orders/widgets/summary_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/constdata/colorprovider.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart'; // Importe o modelo Store
import 'package:totem_pro_admin/models/store_hour.dart';
import 'package:totem_pro_admin/pages/orders/cubit/order_page_state.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:universal_html/js.dart';

import '../../../ConstData/typography.dart';
import 'order_details_desktop.dart';

class SummaryPanel extends StatelessWidget {
  final OrderDetails? selectedOrder;
  final Store? store; // NOVO: Recebe a loja ativa
  final OrderState orderState; // NOVO: Recebe o estado dos pedidos
  final ColorNotifire notifire;

  const SummaryPanel({
    super.key,
    this.selectedOrder,
    required this.store,
    required this.orderState,
    required this.notifire,
  });

  @override
  Widget build(BuildContext context) {
    // Se um pedido estiver selecionado, mostra os detalhes dele.
    if (selectedOrder != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: OrderDetailsPanel(
          order: selectedOrder!,
          store: store, onClose: () {  }, // Passa a loja para o widget de detalhes
        ),
      );
    }

    // Se nenhum pedido estiver selecionado, mostra o painel de resumo/dashboard.
    return _buildDashboard(context);
  }

  Widget _buildDashboard(BuildContext context) {
    // A lógica agora usa os dados recebidos via construtor, sem BlocBuilder interno.
    final storeName = store?.core.name ?? "Loja";
    final isStoreOpen = store?.relations.storeOperationConfig?.isStoreOpen ?? false;
    final storeHours = store?.relations.hours ?? [];

    if (orderState is OrdersLoading || orderState is OrdersInitial) {
      return const Center(child: DotLoading());
    }

    if (orderState is OrdersError) {
      return Center(child: Text('Erro: ${(orderState as OrdersError).message}'));
    }

    if (orderState is OrdersLoaded) {
      // Lógica de cálculo das métricas...
      final allOrders = (orderState as OrdersLoaded).orders;
      final completedOrders = allOrders.where((o) => o.orderStatus == 'delivered').toList();
      final totalRevenue = completedOrders.fold(0.0, (sum, o) => sum + (o.totalPrice / 100));

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStoreStatusCard(context, storeName, isStoreOpen),
            const SizedBox(height: 16),
            _buildOperatingHoursCard(context,storeHours),
            const SizedBox(height: 16),
            _buildMetricsCard(context,completedOrders.length, totalRevenue),
          ],
        ),
      );
    }

    // Fallback para outros estados como OrdersEmpty
    return const Center(child: Text("Selecione um pedido para ver os detalhes ou aguarde novos pedidos."));
  }

  // Widgets auxiliares foram extraídos para maior clareza.

  Widget _buildStoreStatusCard(BuildContext context, String storeName, bool isStoreOpen) {
    return _buildMetricCard(
      context,
      title: storeName,
      customContent: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isStoreOpen ? "Loja Aberta" : "Loja Fechada",
            style: Typographyy.bodyMediumMedium.copyWith(
              color: isStoreOpen ? Colors.green : Colors.red,
            ),
          ),
          Switch(
            value: isStoreOpen,
            onChanged: (newValue) {
              if (store != null) {
                context.read<StoresManagerCubit>().updateStoreSettings(
                  store!.core.id!,
                  isStoreOpen: newValue,
                );
              }
            },
            activeColor: Colors.green,
            inactiveThumbColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildOperatingHoursCard(BuildContext context, List<StoreHour> storeHours) {
    final now = DateTime.now();
    final todayWeekday = now.weekday % 7; // Domingo = 0
    final todayHours = storeHours.where((h) => h.dayOfWeek == todayWeekday && h.isActive).toList();

    String formatTime(TimeOfDay? time) => time?.format(context) ?? 'N/A';

    return _buildMetricCard(
      context,

      title: "Horário de Hoje",
      customContent: todayHours.isEmpty
          ? Text('Fechado', style: Typographyy.bodySmallSemiBold.copyWith(color: Colors.red))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: todayHours.map((h) => Text(
          '${formatTime(h.openingTime)} - ${formatTime(h.closingTime)}',
          style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getTextColor),
        )).toList(),
      ),
    );
  }

  Widget _buildMetricsCard(BuildContext context, int completedCount, double totalRevenue) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return _buildMetricCard(
      context,
      title: "Métricas de Hoje",
      customContent: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                completedCount.toString(),

              ),
              Text("Pedidos Concluídos", style: Typographyy.bodySmallRegular),
            ],
          ),
          Column(
            children: [
              Text(
                currencyFormat.format(totalRevenue),

              ),
              Text("Faturamento", style: Typographyy.bodySmallRegular),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, {required String title, required Widget customContent, }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Typographyy.bodySmallSemiBold.copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(height: 12),
          customContent,
        ],
      ),
    );
  }
}