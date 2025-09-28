import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/pages/orders/widgets/order_list_item.dart';
import '../../../core/enums/order_view.dart';
import 'package:collection/collection.dart';

import '../utils/order_helpers.dart';
import 'empty_order_view.dart';

// ✅ NOVO WIDGET INTERNO E STATEFUL PARA GERENCIAR AS TABS
class _StatusFilteredOrderTabs extends StatefulWidget {
  final List<OrderDetails> orders;
  final Store? store;
  final Function(OrderDetails) onOrderTap;

  const _StatusFilteredOrderTabs({
    required this.orders,
    required this.store,
    required this.onOrderTap,
  });

  @override
  __StatusFilteredOrderTabsState createState() => __StatusFilteredOrderTabsState();
}

class __StatusFilteredOrderTabsState extends State<_StatusFilteredOrderTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = widget.orders.where((o) => o.orderStatus == 'pending' && !o.isScheduled).toList();
    final preparing = widget.orders.where((o) => o.orderStatus == 'preparing' && !o.isScheduled).toList();
    final ready = widget.orders.where((o) => ['ready'].contains(o.orderStatus) && !o.isScheduled).toList();

    return Column(
      children: [

        Container(
        //  margin: const EdgeInsets.all(16),
        //  padding: const EdgeInsets.all(4),
          child: TabBar(
            controller: _tabController,
            tabAlignment: TabAlignment.fill,
            indicatorColor: Colors.black, // Indicador preto
            labelColor: Colors.black, // Nome preto
            unselectedLabelColor: Colors.grey.shade600, // Cor para tabs não selecionadas
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              _buildModernTab('Novo', pending.length),
              _buildModernTab('Preparo', preparing.length),
              _buildModernTab('Pronto', ready.length),
            ],
          ),
        ),
        SizedBox(height: 8,),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent(pending, 'Novos Pedidos', Icons.add_shopping_cart_rounded),
              _buildTabContent(preparing, 'Em Preparo', Icons.restaurant_rounded),
              _buildTabContent(ready, 'Prontos para Entrega', Icons.check_circle_rounded),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildModernTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
         if(count >0)
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }




  Widget _buildTabContent(List<OrderDetails> orders, String title, IconData icon) {
    if (orders.isEmpty) {
      return _buildEmptyTabState(title, icon);
    }

    return Column(
      children: [
        // Header da tab

        Expanded(
          child: _buildModernOrderList(orders),
        ),
      ],
    );
  }

  Widget _buildEmptyTabState(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B00).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: const Color(0xFFFF6B00)),
          ),
          const SizedBox(height: 20),
          Text(
            'Nenhum pedido',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Não há pedidos $title',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernOrderList(List<OrderDetails> orders) {
    return ListView.separated(
     // padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final order = orders[index];
        return OrderListItem(
          order: order,
          store: widget.store,
          onTap: () => widget.onOrderTap(order),
        );
      },
    );
  }
}

// ✅ FUNÇÃO HELPER PARA CONSTRUIR UMA LISTA SIMPLES (REUTILIZÁVEL)
Widget _buildSimpleOrderList(
    List<OrderDetails> orders, Store? store, Function(OrderDetails) onOrderTap) {
  return ListView.separated(
  //  padding: const EdgeInsets.symmetric(horizontal: 14,),
    itemCount: orders.length,
    separatorBuilder: (context, index) => const SizedBox(height: 8),
    itemBuilder: (context, index) {
      final order = orders[index];
      return OrderListItem(
        order: order,
        store: store,
        onTap: () => onOrderTap(order),
      );
    },
  );
}

class ResponsiveOrderView extends StatefulWidget {
  final List<OrderDetails> orders;
  final Store? store;
  final Function(OrderDetails) onOrderTap;
  final OrderViewMode initialViewMode;
  final ListFilter activeFilter;

  const ResponsiveOrderView({
    super.key,
    required this.orders,
    required this.store,
    required this.onOrderTap,
    this.initialViewMode = OrderViewMode.list,
    this.activeFilter = ListFilter.all,
  });

  @override
  ResponsiveOrderViewState createState() => ResponsiveOrderViewState();
}

class ResponsiveOrderViewState extends State<ResponsiveOrderView> {
  late OrderViewMode _currentViewMode;
  ScheduledFilter _activeScheduledFilter = ScheduledFilter.today;

  @override
  void initState() {
    super.initState();
    _currentViewMode = widget.initialViewMode;
  }

  void switchView() {
    setState(() {
      _currentViewMode =
      _currentViewMode == OrderViewMode.list ? OrderViewMode.grouped : OrderViewMode.list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(16),
      ),
      child: _currentViewMode == OrderViewMode.grouped
          ? _buildGroupedView()
          : _buildListView(),
    );
  }

  Widget _buildListView() {
    // ✅ SWITCH CORRIGIDO PARA PASSAR OS PARÂMETROS DO ESTADO VAZIO
    switch (widget.activeFilter) {
      case ListFilter.all:
        return _StatusFilteredOrderTabs(
          orders: widget.orders,
          store: widget.store,
          onOrderTap: widget.onOrderTap,
        );

      case ListFilter.deliveries:
        final filteredOrders = widget.orders.where((o) => o.orderStatus == 'on_route' && !o.isScheduled).toList();
        return _buildFilteredSection(
          title: 'Entregas em Andamento',
          orders: filteredOrders,
          // Passa a mensagem e o ícone personalizados para o estado vazio
          emptyMessage: 'Nenhuma entrega em andamento',
          emptyIcon: Icons.delivery_dining_rounded,
          emptySubtitle: 'Pedidos prontos para entrega aparecerão aqui.',
        );

      case ListFilter.scheduled:
        return _buildScheduledView();

      case ListFilter.completed:
        final filteredOrders = widget.orders.where((o) => ['delivered', 'finalized', 'canceled'].contains(o.orderStatus)).toList();
        return _buildFilteredSection(
          title: 'Pedidos Concluídos',
          orders: filteredOrders,
          // Passa a mensagem e o ícone personalizados para o estado vazio
          emptyMessage: 'Nenhum pedido concluído',
          emptyIcon: Icons.check_circle_outline_rounded,
          emptySubtitle: 'Pedidos finalizados e cancelados são exibidos aqui.',
        );

      default:
        return _buildEmptyState('Filtro não reconhecido', Icons.error_outline_rounded);
    }
  }



// ✅ FUNÇÃO ATUALIZADA PARA ACEITAR OS NOVOS PARÂMETROS
  Widget _buildFilteredSection({
    required String title,
    required List<OrderDetails> orders,
    required String emptyMessage,
    required IconData emptyIcon,
    String? emptySubtitle,
  }) {
    return Column(
      children: [
        _buildModernHeader(title, orders.length, emptyIcon),
        Expanded(
          child: orders.isEmpty
          // Agora usa os parâmetros recebidos para construir o estado vazio
              ? _buildEmptyState(emptyMessage, emptyIcon, subtitle: emptySubtitle)
              : _buildSimpleOrderList(orders, widget.store, widget.onOrderTap),
        ),
      ],
    );
  }


  Widget _buildModernHeader(String title, int total, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

      ),
     // margin: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [

              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,

                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Text(
              '$total',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledView() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));

    List<OrderDetails> scheduledOrders;
    final allScheduled = widget.orders.where((o) => o.isScheduled && o.scheduledFor != null).toList();

    switch (_activeScheduledFilter) {
      case ScheduledFilter.today:
        scheduledOrders = allScheduled.where((o) =>
        !o.scheduledFor!.isBefore(today) && o.scheduledFor!.isBefore(tomorrow)
        ).toList();
        break;
      case ScheduledFilter.tomorrow:
        scheduledOrders = allScheduled.where((o) =>
        !o.scheduledFor!.isBefore(tomorrow) && o.scheduledFor!.isBefore(dayAfterTomorrow)
        ).toList();
        break;
      case ScheduledFilter.nextDays:
        scheduledOrders = allScheduled.where((o) =>
        !o.scheduledFor!.isBefore(dayAfterTomorrow)
        ).toList();
        break;
    }

    return Column(
      children: [
        _buildModernHeader('Pedidos Agendados', scheduledOrders.length, Icons.calendar_today_rounded),
        const SizedBox(height: 8),

        // Filtros modernos
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 14),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),

          ),
          child: Row(
            children: [
              _buildModernFilterTab(
                label: 'Hoje',
                isSelected: _activeScheduledFilter == ScheduledFilter.today,
                onTap: () => setState(() => _activeScheduledFilter = ScheduledFilter.today),
                count: allScheduled.where((o) =>
                !o.scheduledFor!.isBefore(today) && o.scheduledFor!.isBefore(tomorrow)
                ).length,
              ),
              _buildModernFilterTab(
                label: 'Amanhã',
                isSelected: _activeScheduledFilter == ScheduledFilter.tomorrow,
                onTap: () => setState(() => _activeScheduledFilter = ScheduledFilter.tomorrow),
                count: allScheduled.where((o) =>
                !o.scheduledFor!.isBefore(tomorrow) && o.scheduledFor!.isBefore(dayAfterTomorrow)
                ).length,
              ),
              _buildModernFilterTab(
                label: 'Próximos',
                isSelected: _activeScheduledFilter == ScheduledFilter.nextDays,
                onTap: () => setState(() => _activeScheduledFilter = ScheduledFilter.nextDays),
                count: allScheduled.where((o) =>
                !o.scheduledFor!.isBefore(dayAfterTomorrow)
                ).length,
              ),
            ],
          ),
        ),


        Expanded(
          child: scheduledOrders.isEmpty
              ? _buildEmptyScheduledState(_activeScheduledFilter)
              : _buildSimpleOrderList(scheduledOrders, widget.store, widget.onOrderTap),
        ),
      ],
    );
  }

  Widget _buildModernFilterTab({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required int count,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:  Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyScheduledState(ScheduledFilter filter) {
    String message;
    String subtitle;
    IconData icon;

    switch (filter) {
      case ScheduledFilter.today:
        message = 'Nenhum pedido para hoje';
        subtitle = 'Não há pedidos agendados para o dia de hoje';
        icon = Icons.calendar_today_rounded;
        break;
      case ScheduledFilter.tomorrow:
        message = 'Nenhum pedido para amanhã';
        subtitle = 'Não há pedidos agendados para amanhã';
        icon = Icons.calendar_month_rounded;
        break;
      case ScheduledFilter.nextDays:
        message = 'Nenhum pedido futuro';
        subtitle = 'Não há pedidos agendados para os próximos dias';
        icon = Icons.calendar_view_week_rounded;
        break;
    }

    return _buildEmptyState(message, icon, subtitle: subtitle);
  }

  Widget _buildEmptyState(String message, IconData icon, {String? subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B00).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: const Color(0xFFFF6B00)),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }

// Em: responsive_order_view.dart (dentro da classe ResponsiveOrderViewState)

  Widget _buildGroupedView() {
    // 1. Filtramos os pedidos agendados, como já estava sendo feito.
    final nonScheduledOrders = widget.orders.where((o) => !o.isScheduled).toList();

    // ✅ CORREÇÃO APLICADA AQUI
    // 2. Verificamos se a lista de pedidos a ser exibida está vazia.
    if (nonScheduledOrders.isEmpty) {
      // Se estiver vazia, retorna o widget de estado vazio que você já usa em outras partes.
      return _buildEmptyState(
        'Nenhum pedido encontrado',
        Icons.receipt_long_rounded, // Ícone relevante para pedidos
        subtitle: 'Não há pedidos ativos para serem exibidos.',
      );
    }

    // 3. Se a lista não estiver vazia, o resto do código continua como antes.
    final groupedByStatus = groupBy<OrderDetails, String>(
      nonScheduledOrders,
          (order) => order.orderStatus,
    );

    const statusOrder = ['pending', 'preparing', 'ready', 'on_route', 'delivered', 'finalized', 'canceled'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: statusOrder.map((status) {
        final ordersInStatus = groupedByStatus[status] ?? [];
        if (ordersInStatus.isEmpty) {
          return Container();
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            key: PageStorageKey(status),
            title: Row(
              children: [
                Text(
                  internalStatusToDisplayName[status] ?? status,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      ordersInStatus.length.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            initiallyExpanded: status == 'pending' || status == 'preparing',
            children: ordersInStatus.map((order) {
              return OrderListItem(
                order: order,
                store: widget.store,
                onTap: () => widget.onOrderTap(order),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }


}