// lib/pages/orders/layout/desktop/views/orders_list_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../cubits/store_manager_cubit.dart';
import '../../../../../cubits/store_manager_state.dart';
import '../../../../../models/order_details.dart';
import '../../../../../models/store/store.dart';
import '../../../../../widgets/dot_loading.dart';
import '../../../cubit/order_page_cubit.dart';
import '../../../cubit/order_page_state.dart';
import '../../../details/order_details_desktop.dart';
import '../../../widgets/empty_order_view.dart';
import '../../../widgets/order_list_item.dart';
import '../../../widgets/order_search_delegate.dart';
import '../../../widgets/responsive_order_view.dart';
import '../../../../../core/enums/order_view.dart';
import '../widgets/ifood_dashboard_panel.dart';

class OrdersListPage extends StatefulWidget {
  const OrdersListPage({super.key});

  @override
  State<OrdersListPage> createState() => _OrdersListPageState();
}

class _OrdersListPageState extends State<OrdersListPage>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  OrderDetails? _selectedOrder;

  OrderViewMode _viewMode = OrderViewMode.list;
  int _selectedFilterIndex = 0;

  final List<ListFilter> _filters = [
    ListFilter.all,
    ListFilter.deliveries,
    ListFilter.scheduled,
    ListFilter.completed,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showSearch(List<OrderDetails> orders, Store? store) async {
    final OrderDetails? selectedOrder = await showSearch<OrderDetails?>(
      context: context,
      delegate: OrderSearchDelegate(orders),
    );

    if (selectedOrder != null && mounted) {
      setState(() {
        _selectedOrder = selectedOrder;
      });
    }
  }

  List<OrderDetails> _getFilteredOrders(List<OrderDetails> orders) {
    if (_searchController.text.isEmpty) return orders;

    final searchText = _searchController.text.toLowerCase();
    return orders.where((order) {
      return order.customerName.toLowerCase().contains(searchText) ||
          order.publicId.toLowerCase().contains(searchText);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<StoresManagerCubit, StoresManagerState>(
        builder: (context, storeState) {
          if (storeState is! StoresManagerLoaded) {
            return const Center(child: DotLoading());
          }

          final activeStore = storeState.activeStore;

          return BlocBuilder<OrderCubit, OrderState>(
            builder: (context, orderState) {
              if (orderState is OrdersLoading) {
                return const Center(child: DotLoading());
              }

              if (orderState is OrdersError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar pedidos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(orderState.message),
                    ],
                  ),
                );
              }

              final allOrders = orderState is OrdersLoaded
                  ? orderState.orders
                  : <OrderDetails>[];

              final filteredOrders = _getFilteredOrders(allOrders);

              return Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildOrdersPanel(
                      context,
                      filteredOrders,
                      activeStore,
                      orderState is OrdersLoaded,
                    ),
                  ),

                  Expanded(
                    flex: 3,
                    child: _selectedOrder != null
                        ? _buildOrderDetailsPanel(activeStore)
                        : IfoodDashboardPanel(
                      activeStore: activeStore,
                      orders: allOrders,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrdersPanel(
      BuildContext context,
      List<OrderDetails> orders,
      Store? store,
      bool isLoaded,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTabBar(),
          _buildSearchAndFilters(orders, store),
          Expanded(
            child: _viewMode == OrderViewMode.list
                ? _buildTabView(orders, store, isLoaded)
                : _buildGroupedView(orders, store),
          ),
          _buildSalesResume(orders),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFFEA1D2C),
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: const Color(0xFFEA1D2C),
        tabs: const [
          Tab(text: 'Agora'),
          Tab(text: 'Agendados'),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(List<OrderDetails> orders, Store? store) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou número do pedido',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),
          const SizedBox(width: 8),

          _buildFilterDropdown(),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return PopupMenuButton<ListFilter>(
      initialValue: _filters[_selectedFilterIndex],
      onSelected: (ListFilter filter) {
        setState(() {
          _selectedFilterIndex = _filters.indexOf(filter);
        });
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<ListFilter>>[
        const PopupMenuItem<ListFilter>(
          value: ListFilter.all,
          child: Row(
            children: [
              Icon(Icons.receipt_long, size: 20),
              SizedBox(width: 12),
              Text('Todos os Pedidos'),
            ],
          ),
        ),
        const PopupMenuItem<ListFilter>(
          value: ListFilter.deliveries,
          child: Row(
            children: [
              Icon(Icons.delivery_dining, size: 20),
              SizedBox(width: 12),
              Text('Entregas'),
            ],
          ),
        ),
        const PopupMenuItem<ListFilter>(
          value: ListFilter.scheduled,
          child: Row(
            children: [
              Icon(Icons.schedule, size: 20),
              SizedBox(width: 12),
              Text('Agendados'),
            ],
          ),
        ),
        const PopupMenuItem<ListFilter>(
          value: ListFilter.completed,
          child: Row(
            children: [
              Icon(Icons.check_circle_outline, size: 20),
              SizedBox(width: 12),
              Text('Concluídos'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            Text('Filtros'),
            SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTabView(List<OrderDetails> orders, Store? store, bool isLoaded) {
    if (!isLoaded) {
      return const Center(child: DotLoading());
    }

    return TabBarView(
      controller: _tabController,
      children: [
        // ✅ Tab "Agora" - Pedidos NÃO agendados
        _buildOrdersList(
          orders.where((o) => o.scheduledFor == null).toList(), // ← CORREÇÃO AQUI
          store,
        ),

        // ✅ Tab "Agendados" - Pedidos COM scheduledFor
        _buildOrdersList(
          orders.where((o) => o.scheduledFor != null).toList(), // ← CORREÇÃO AQUI
          store,
        ),
      ],
    );
  }

  Widget _buildOrdersList(List<OrderDetails> orders, Store? store) {
    if (orders.isEmpty) {
      return const EmptyOrdersView();
    }

    return ResponsiveOrderView(
      orders: orders,
      store: store,
      initialViewMode: OrderViewMode.list,
      activeFilter: _filters[_selectedFilterIndex],
      onOrderTap: (order) {
        setState(() {
          _selectedOrder = order;
        });
      },
    );
  }

  Widget _buildGroupedView(List<OrderDetails> orders, Store? store) {
    if (orders.isEmpty) {
      return const EmptyOrdersView();
    }

    return ResponsiveOrderView(
      orders: orders,
      store: store,
      initialViewMode: OrderViewMode.grouped,
      activeFilter: _filters[_selectedFilterIndex],
      onOrderTap: (order) {
        setState(() {
          _selectedOrder = order;
        });
      },
    );
  }

  Widget _buildSalesResume(List<OrderDetails> orders) {
    final completedOrders = orders.where((o) =>
        ['delivered', 'finalized'].contains(o.orderStatus)
    ).toList();

    final totalSales = completedOrders.fold<double>(
        0,
            (sum, order) => sum + (order.totalPrice / 100)
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Resumo de Vendas',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${completedOrders.length} pedidos concluídos',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                'R\$ ${totalSales.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsPanel(Store? store) {
    if (_selectedOrder == null) {
      return const Center(child: Text('Selecione um pedido'));
    }

    return OrderDetailsPanel(
      order: _selectedOrder!,
      store: store,
      onClose: () {
        setState(() {
          _selectedOrder = null;
        });
      },
    );
  }
}