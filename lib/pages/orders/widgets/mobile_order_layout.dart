import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';
import '../../../models/order_details.dart';
import '../../../models/store_settings.dart';
import '../../../widgets/dot_loading.dart';
import '../order_page_cubit.dart';
import '../order_page_state.dart';
import '../utils/order_helpers.dart';
import 'count_badge.dart';
import 'order_list_item.dart';

class MobileOrderLayout extends StatefulWidget {
  final String storeName;
  final TabController mobileTabController;
  final TextEditingController searchController;
  final int currentTabIndex;
  final Function(int index) onTabChanged;
  final void Function(BuildContext, OrderDetails) onOpenOrderDetailsPage;
  final void Function(OrderDetails) onPrintOrder;
  final int? activeStoreId;
  final StoreSettings? storeSettings;

  const MobileOrderLayout({
    super.key,
    required this.storeName,
    required this.mobileTabController,
    required this.searchController,
    required this.currentTabIndex,
    required this.onTabChanged,
    required this.onPrintOrder,
    required this.onOpenOrderDetailsPage,
    this.activeStoreId,
    this.storeSettings,
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

  Widget _buildOrderListByStatus(List<OrderDetails> orders) {
    final List<OrderDetails> sortedOrders = List.from(orders)
      ..sort((a, b) {
        if (a.orderStatus == 'pending' && b.orderStatus != 'pending') return -1;
        if (a.orderStatus != 'pending' && b.orderStatus == 'pending') return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

    final ordersByStatus = groupBy(sortedOrders, (order) => order.orderStatus);

    const List<String> mobileDisplayStatuses = [
      'pending',
      'preparing',
      'ready',
      'on_route',
      'delivered',
      'canceled',
    ];

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: mobileDisplayStatuses.map((internalStatus) {
        final statusOrders = ordersByStatus[internalStatus] ?? [];
        if (statusOrders.isEmpty) return const SizedBox();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: internalStatus == 'pending',
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                childrenPadding: EdgeInsets.zero,
                title: Text(
                  '${internalStatusToDisplayName[internalStatus] ?? 'Status Desconhecido'} (${statusOrders.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                children: statusOrders.map((order) {
                  final storeManagerState = context.watch<StoresManagerCubit>().state;
                  String currentStoreName = 'Loja Desconhecida';
                  if (storeManagerState is StoresManagerLoaded &&
                      storeManagerState.stores.containsKey(order.storeId)) {
                    currentStoreName = storeManagerState.stores[order.storeId]!.store.name;
                  }

                  return OrderListItem(
                    order: order,
                    onPrintOrder: widget.onPrintOrder,
                    onTap: () => widget.onOpenOrderDetailsPage(context, order),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAutoAcceptSwitch(StoreSettings settings) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Auto Aceite",
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black),
        ),
        Switch(
          value: settings.autoAcceptOrders,
          onChanged: (newValue) {
            context.read<StoresManagerCubit>().updateStoreSettings(
              widget.activeStoreId!,
              autoAcceptOrders: newValue,
            );
          },
          activeColor: Colors.green,
          inactiveThumbColor: Colors.red,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _isSearchExpanded ? 56 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: widget.searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Buscar pedidos...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _searchFocusNode.unfocus(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(StoreSettings? settings) {
    return AppBar(
      title: Text(
        widget.storeName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1,
      actions: [
        if (settings != null && widget.activeStoreId != null)
          _buildAutoAcceptSwitch(settings),
        IconButton(
          icon: Icon(_isSearchExpanded ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearchExpanded = !_isSearchExpanded;
              if (_isSearchExpanded) {
                _searchFocusNode.requestFocus();
              } else {
                widget.searchController.clear();
                _searchFocusNode.unfocus();
              }
            });
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(_isSearchExpanded ? 112 : 56),
        child: Column(
          children: [
            _buildSearchField(),
            _buildTabBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, orderState) {
        int nowPendingCount = 0;
        int scheduledPendingCount = 0;

        if (orderState is OrdersLoaded) {
          nowPendingCount = orderState.orders
              .where((o) => o.scheduledFor == null && o.orderStatus == 'pending')
              .length;
          scheduledPendingCount = orderState.orders
              .where((o) => o.scheduledFor != null && o.orderStatus == 'pending')
              .length;
        }

        return TabBar(
          controller: widget.mobileTabController,
          isScrollable: true,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 3.0, color: Colors.red),
            insets: EdgeInsets.symmetric(horizontal: 16.0),
          ),
          labelColor: Colors.red,
          unselectedLabelColor: Colors.black,
          tabs: [
            Tab(child: _buildTabLabel('Agora', nowPendingCount)),
            Tab(child: _buildTabLabel('Agendados', scheduledPendingCount)),
          ],
        );
      },
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
    final currentTabName = widget.currentTabIndex == 0 ? "para agora" : "agendado";
    final searchText = widget.searchController.text;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Nenhum pedido ${searchText.isEmpty ? currentTabName : "para a busca"} encontrado.',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            searchText.isNotEmpty
                ? 'Tente ajustar o termo de busca.'
                : 'Verifique os filtros ou aguarde novos pedidos.',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final storeCubitState = context.watch<StoresManagerCubit>().state;
    StoreSettings? currentSettings = widget.storeSettings;

    if (currentSettings == null && storeCubitState is StoresManagerLoaded) {
      currentSettings = storeCubitState.stores[widget.activeStoreId]?.store.storeSettings;
    }

    return Scaffold(
      appBar: _buildAppBar(currentSettings),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrdersLoading || state is OrdersInitial) {
            return const Center(child: DotLoading(color: Colors.red, size: 12));
          }
          if (state is OrdersError) {
            return Center(child: Text('Erro: ${state.message}'));
          }
          if (state is OrdersLoaded) {
            final orders = widget.currentTabIndex == 0
                ? state.orders.where((o) => o.scheduledFor == null).toList()
                : state.orders.where((o) => o.scheduledFor != null).toList();

            final displayOrders = widget.searchController.text.isEmpty
                ? orders
                : orders.where((o) =>
            o.publicId.toLowerCase().contains(widget.searchController.text.toLowerCase()) ||
                o.customerName.toLowerCase().contains(widget.searchController.text.toLowerCase()))
                .toList();

            return displayOrders.isEmpty
                ? _buildEmptyState()
                : _buildOrderListByStatus(displayOrders);
          }
          return const Center(child: Text('Estado desconhecido'));
        },
      ),
    );
  }
}