// lib/pages/orders/widgets/mobile_order_layout.dart

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import '../order_page_cubit.dart';
import '../order_page_state.dart';
import '../utils/order_helpers.dart';
import 'count_badge.dart';
import 'order_list_item.dart';

class MobileOrderLayout extends StatefulWidget {
  // Parâmetros de UI e Callbacks
  final TabController mobileTabController;
  final TextEditingController searchController;
  final int currentTabIndex;
  final Function(int index) onTabChanged;
  final void Function(BuildContext, OrderDetails) onOpenOrderDetailsPage;

  // Parâmetros de DADOS e ESTADO (recebidos do pai)
  final Store? store;
  final OrderState orderState;
  final List<OrderDetails> displayOrders;

  const MobileOrderLayout({
    super.key,
    required this.mobileTabController,
    required this.searchController,
    required this.currentTabIndex,
    required this.onTabChanged,
    required this.onOpenOrderDetailsPage,
    required this.store,
    required this.orderState,
    required this.displayOrders,
  });

  @override
  State<MobileOrderLayout> createState() => _MobileOrderLayoutState();
}

class _MobileOrderLayoutState extends State<MobileOrderLayout> {
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    widget.mobileTabController.index = widget.currentTabIndex;
    widget.mobileTabController.addListener(_handleTabChange);
    _searchFocusNode.addListener(_handleSearchFocusChange);
  }

  void _handleTabChange() {
    if (!widget.mobileTabController.indexIsChanging) {
      widget.onTabChanged(widget.mobileTabController.index);
      setState(() {
        _isSearchExpanded = false;
        _searchFocusNode.unfocus();
        widget.searchController.clear();
        context.read<OrderCubit>().applyFilter(OrderFilter.all);
      });
    }
  }

  void _handleSearchFocusChange() {
    if (!_searchFocusNode.hasFocus && widget.searchController.text.isEmpty) {
      setState(() => _isSearchExpanded = false);
    }
  }

  @override
  void dispose() {
    widget.mobileTabController.removeListener(_handleTabChange);
    _searchFocusNode.removeListener(_handleSearchFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.store?.name ?? 'Pedidos', style: const TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      actions: [
        if (widget.orderState is OrdersLoaded)
          _buildFilterDropdown((widget.orderState as OrdersLoaded).filter),
        IconButton(
          icon: Icon(_isSearchExpanded ? Icons.close : Icons.search),
          onPressed: () => setState(() {
            _isSearchExpanded = !_isSearchExpanded;
            if (_isSearchExpanded) _searchFocusNode.requestFocus();
            else {
              widget.searchController.clear();
              _searchFocusNode.unfocus();
            }
          }),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(_isSearchExpanded ? 60 : 48),
        child: Column(
          children: [
            _buildSearchField(),
            _buildTabBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(OrderFilter currentFilter) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<OrderFilter>(
        value: currentFilter,
        icon: const Icon(Icons.filter_list, color: Colors.black54),
        items: OrderFilter.values.map((filter) {
          return DropdownMenuItem<OrderFilter>(
            value: filter,
            child: Text(
              orderFilterToDisplayName[filter] ?? 'Filtro',
              style: const TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: (newFilter) {
          if (newFilter != null) {
            context.read<OrderCubit>().applyFilter(newFilter);
          }
        },
      ),
    );
  }

  Widget _buildSearchField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isSearchExpanded ? 60 : 0,
      child: _isSearchExpanded
          ? Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: TextField(
          controller: widget.searchController,
          focusNode: _searchFocusNode,
          decoration: InputDecoration(
            hintText: 'Buscar por nome ou ID...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (_) => setState(() {}),
        ),
      )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildTabBar() {
    int nowCount = 0;
    int scheduledCount = 0;

    if (widget.orderState is OrdersLoaded) {
      final allOrders = (widget.orderState as OrdersLoaded).orders;
      nowCount = allOrders.where((o) => o.scheduledFor == null).length;
      scheduledCount = allOrders.where((o) => o.scheduledFor != null).length;
    }

    return TabBar(
      controller: widget.mobileTabController,
      isScrollable: true,
      indicator: const UnderlineTabIndicator(borderSide: BorderSide(width: 3.0, color: Colors.red), insets: EdgeInsets.symmetric(horizontal: 16.0)),
      labelColor: Colors.red,
      unselectedLabelColor: Colors.black,
      tabs: [
        Tab(child: _buildTabLabel('Agora', nowCount)),
        Tab(child: _buildTabLabel('Agendados', scheduledCount)),
      ],
    );
  }

  Widget _buildTabLabel(String text, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text),
        if (count > 0)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: CountBadge(count: count),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Nenhum pedido encontrado."));
  }

  Widget _buildOrderList(List<OrderDetails> orders, OrderFilter activeFilter) {
    if (activeFilter != OrderFilter.all) {
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: orders.length,
        itemBuilder: (context, index) => OrderListItem(
          order: orders[index],
          store: widget.store,
          onTap: () => widget.onOpenOrderDetailsPage(context, orders[index]),
        ),
      );
    }
    return _buildGroupedOrderList(orders);
  }

  Widget _buildGroupedOrderList(List<OrderDetails> orders) {
    final ordersByStatus = groupBy(orders, (order) => order.orderStatus);
    const displayStatuses = ['pending', 'preparing', 'ready', 'on_route', 'delivered', 'canceled'];

    return ListView(
      padding: const EdgeInsets.all(8),
      children: displayStatuses.map((status) {
        final statusOrders = ordersByStatus[status] ?? [];
        if (statusOrders.isEmpty) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            initiallyExpanded: status == 'pending',
            title: Text('${internalStatusToDisplayName[status] ?? status} (${statusOrders.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
            children: statusOrders.map((order) => OrderListItem(
              order: order,
              store: widget.store,
              onTap: () => widget.onOpenOrderDetailsPage(context, order),
            )).toList(),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Builder(
        builder: (context) {
          if (widget.orderState is OrdersLoading || widget.orderState is OrdersInitial) {
            return const Center(child: DotLoading());
          }
          if (widget.orderState is OrdersError) {
            return Center(child: Text('Erro: ${(widget.orderState as OrdersError).message}'));
          }
          if (widget.orderState is OrdersLoaded) {
            // O pai (OrdersPage) já fez a filtragem, agora usamos a lista final.
            if (widget.displayOrders.isEmpty) {
              return _buildEmptyState();
            }
            return _buildOrderList(
              widget.displayOrders,
              (widget.orderState as OrdersLoaded).filter,
            );
          }
          return _buildEmptyState();
        },
      ),
    );
  }
}