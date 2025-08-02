// lib/pages/orders/widgets/mobile_order_layout.dart

import 'package:avatar_glow/avatar_glow.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import '../../../core/helpers/sidepanel.dart';
import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';
import '../../../services/print/printer_settings.dart';
import '../../../widgets/access_wrapper.dart';
import '../order_page_state.dart';
import '../store_settings.dart';
import '../utils/order_helpers.dart';
import 'count_badge.dart';
import 'empty_order_view.dart';
import 'order_list_item.dart';

class _OrderStatusTab {
  final String title;
  final List<String> statuses;
  final Color color;
  final IconData icon;

  const _OrderStatusTab({
    required this.title,
    required this.statuses,
    required this.color,
    required this.icon,
  });
}

class MobileOrderLayout extends StatefulWidget {
  final TextEditingController searchController;
  final void Function(BuildContext, OrderDetails) onOpenOrderDetailsPage;
  final Store? store;
  final OrderState orderState;
  final List<OrderDetails> displayOrders;

  const MobileOrderLayout({
    super.key,
    required this.searchController,
    required this.onOpenOrderDetailsPage,
    required this.store,
    required this.orderState,
    required this.displayOrders,
  });

  @override
  State<MobileOrderLayout> createState() => _MobileOrderLayoutState();
}

class _MobileOrderLayoutState extends State<MobileOrderLayout> with SingleTickerProviderStateMixin {
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchExpanded = false;
  int _selectedStatusTabIndex = 0;

  TabController? _tabController;
  List<Map<String, String>> _availableTabs = [];

  final List<_OrderStatusTab> _statusTabs = const [
    _OrderStatusTab(title: 'Análise', statuses: ['pending'], color: Colors.orange, icon: Icons.hourglass_top_rounded),
    _OrderStatusTab(title: 'Produção', statuses: ['preparing'], color: Colors.blue, icon: Icons.soup_kitchen_rounded),
    _OrderStatusTab(title: 'Pronto', statuses: ['ready', 'on_route'], color: Colors.green, icon: Icons.check_circle_outline_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _updateTabController();
    _searchFocusNode.addListener(_handleSearchFocusChange);
  }

  @override
  void didUpdateWidget(MobileOrderLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.store?.deliveryOptions != oldWidget.store?.deliveryOptions) {
      _updateTabController();
    }
  }

  void _updateTabController() {
    final options = widget.store?.deliveryOptions;
    final newTabs = <Map<String, String>>[];

    if (options?.deliveryEnabled ?? false) {
      newTabs.add({'key': 'delivery', 'label': 'Delivery'});
    }
    if (options?.pickupEnabled ?? false) {
      newTabs.add({'key': 'takeout', 'label': 'Balcão'});
    }
    if (options?.tableEnabled ?? false) {
      newTabs.add({'key': 'dine_in', 'label': 'Mesas'});
    }

    if (!const ListEquality().equals(
        newTabs.map((e) => e['key']).toList(),
        _availableTabs.map((e) => e['key']).toList()
    )) {
      setState(() {
        _availableTabs = newTabs;
        _tabController?.removeListener(_handleTabChange);
        _tabController?.dispose();
        _tabController = TabController(
            length: _availableTabs.isEmpty ? 1 : _availableTabs.length, vsync: this);
        _tabController!.addListener(_handleTabChange);
      });
    }
  }

  void _handleTabChange() {
    if (_tabController != null && !_tabController!.indexIsChanging) {
      setState(() {
        _isSearchExpanded = false;
        _searchFocusNode.unfocus();
        widget.searchController.clear();
        _selectedStatusTabIndex = 0;
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
    _tabController?.removeListener(_handleTabChange);
    _tabController?.dispose();
    _searchFocusNode.removeListener(_handleSearchFocusChange);
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool get _isDeliveryTabSelected {
    if (_tabController == null || _availableTabs.isEmpty || _tabController!.index >= _availableTabs.length) {
      return false;
    }
    return _availableTabs[_tabController!.index]['key'] == 'delivery';
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.store?.name ?? 'Pedidos', style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      actions: [
        if (widget.store != null) ...[
          BlocBuilder<StoresManagerCubit, StoresManagerState>(
            builder: (context, state) {
              bool needsConfiguration = false;
              int activeStoreId = -1;

              if (state is StoresManagerLoaded) {
                activeStoreId = state.activeStoreId;
                final settings = state.activeStore?.storeSettings;
                if (settings == null || (settings.mainPrinterDestination == null && settings.kitchenPrinterDestination == null)) {
                  needsConfiguration = true;
                }
              }

              final iconButton = IconButton(
                icon: Icon(Icons.print_outlined, color: needsConfiguration ? Colors.amber : null),
                tooltip: 'Configurações de Impressão',
                onPressed: () {
                  if (activeStoreId != -1) {
                    showResponsiveSidePanel(context, PrinterSettingsSidePanel(storeId: activeStoreId));
                  }
                },
              );

              Widget finalIconWidget;
              if (needsConfiguration) {
                finalIconWidget = AvatarGlow(
                  animate: true,
                  glowColor: Colors.amber,
                  duration: const Duration(milliseconds: 2000),
                  repeat: true,
                  child: iconButton,
                );
              } else {
                finalIconWidget = iconButton;
              }

              return AccessWrapper(
                featureKey: 'auto_printing',
                child: finalIconWidget,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configurações da Loja',
            onPressed: () => showResponsiveSidePanel(context, StoreSettingsSidePanel(storeId: widget.store!.id!)),
          ),
        ],
        IconButton(
          icon: Icon(_isSearchExpanded ? Icons.close : Icons.search),
          onPressed: () => setState(() {
            _isSearchExpanded = !_isSearchExpanded;
            if (_isSearchExpanded) {
              _searchFocusNode.requestFocus();
            } else {
              widget.searchController.clear();
              _searchFocusNode.unfocus();
            }
          }),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(_isSearchExpanded ? 60 : 0),
        child: _buildSearchField(),
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
            hintText: 'Buscar por nome ou ID do cliente...',
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

  Widget _buildPrimaryTabBar() {
    if (_tabController == null || _availableTabs.isEmpty) {
      return const SizedBox.shrink();
    }

    final allOrders = (widget.orderState is OrdersLoaded) ? (widget.orderState as OrdersLoaded).orders : <OrderDetails>[];

    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        indicatorColor: Theme.of(context).primaryColor,
        indicatorWeight: 3.0,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey[600],
        tabs: _availableTabs.map((tab) {
          final count = allOrders.where((o) => o.deliveryType == tab['key']).length;
          return Tab(child: _buildTabLabel(tab['label']!, count));
        }).toList(),
      ),
    );
  }

  Widget _buildSecondaryStatusTabs(List<OrderDetails> deliveryOrders) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _statusTabs.asMap().entries.map((entry) {
          int index = entry.key;
          _OrderStatusTab tab = entry.value;
          final count = deliveryOrders.where((o) => tab.statuses.contains(o.orderStatus)).length;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedStatusTabIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(color: tab.color, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(tab.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabLabel(String text, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (count > 0) Padding(padding: const EdgeInsets.only(left: 8.0), child: CountBadge(count: count)),
      ],
    );
  }

  Widget _buildGroupedOrderList(List<OrderDetails> orders, Color groupColor, String groupTitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        color: groupColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  Expanded(child: Text(groupTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))),
                  Text('${orders.length}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return OrderListItem(
                    order: order,
                    store: widget.store,
                    onTap: () => widget.onOpenOrderDetailsPage(context, order),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = (widget.orderState is OrdersLoaded) ? (widget.orderState as OrdersLoaded).orders : <OrderDetails>[];

    if (_availableTabs.isEmpty && widget.store != null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Nenhum tipo de pedido (Delivery, Balcão, Mesas) está habilitado nas configurações da loja.', textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildPrimaryTabBar(),
          if (_isDeliveryTabSelected)
            _buildSecondaryStatusTabs(
              allOrders.where((o) => o.deliveryType == 'delivery').toList(),
            ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (widget.orderState is OrdersLoading || widget.orderState is OrdersInitial) {
                  return const Center(child: DotLoading());
                }
                if (widget.orderState is OrdersError) {
                  return Center(child: Text('Erro: ${(widget.orderState as OrdersError).message}'));
                }
                if (widget.orderState is OrdersLoaded) {
                  if (_tabController == null || _tabController!.index >= _availableTabs.length) {
                    return const EmptyOrdersView();
                  }

                  final selectedDeliveryType = _availableTabs[_tabController!.index]['key']!;
                  String groupTitle = _availableTabs[_tabController!.index]['label']!;

                  List<OrderDetails> filteredOrders = widget.displayOrders.where((order) => order.deliveryType == selectedDeliveryType).toList();
                  Color? kanbanColor = Colors.grey[100];

                  if (_isDeliveryTabSelected) {
                    final selectedStatusTab = _statusTabs[_selectedStatusTabIndex];
                    kanbanColor = selectedStatusTab.color;
                    groupTitle = selectedStatusTab.title;
                    filteredOrders = filteredOrders.where((order) => selectedStatusTab.statuses.contains(order.orderStatus)).toList();
                  }

                  if (filteredOrders.isEmpty) {
                    return EmptyOrdersView(color: kanbanColor);
                  }

                  return _buildGroupedOrderList(filteredOrders, kanbanColor!, groupTitle);
                }
                return EmptyOrdersView();
              },
            ),
          ),
        ],
      ),
    );
  }
}








// // lib/pages/orders/widgets/mobile_order_layout.dart
//
// import 'package:collection/collection.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import 'package:totem_pro_admin/models/order_details.dart';
// import 'package:totem_pro_admin/models/store.dart';
// import 'package:totem_pro_admin/widgets/dot_loading.dart';
// import '../order_page_cubit.dart';
// import '../order_page_state.dart';
// import '../utils/order_helpers.dart';
// import 'count_badge.dart';
// import 'order_list_item.dart';
//
// class MobileOrderLayout extends StatefulWidget {
//   // Parâmetros de UI e Callbacks
//   final TabController mobileTabController;
//   final TextEditingController searchController;
//   final int currentTabIndex;
//   final Function(int index) onTabChanged;
//   final void Function(BuildContext, OrderDetails) onOpenOrderDetailsPage;
//
//   // Parâmetros de DADOS e ESTADO (recebidos do pai)
//   final Store? store;
//   final OrderState orderState;
//   final List<OrderDetails> displayOrders;
//
//   const MobileOrderLayout({
//     super.key,
//     required this.mobileTabController,
//     required this.searchController,
//     required this.currentTabIndex,
//     required this.onTabChanged,
//     required this.onOpenOrderDetailsPage,
//     required this.store,
//     required this.orderState,
//     required this.displayOrders,
//   });
//
//   @override
//   State<MobileOrderLayout> createState() => _MobileOrderLayoutState();
// }
//
// class _MobileOrderLayoutState extends State<MobileOrderLayout> {
//   final FocusNode _searchFocusNode = FocusNode();
//   bool _isSearchExpanded = false;
//
//   @override
//   void initState() {
//     super.initState();
//     widget.mobileTabController.index = widget.currentTabIndex;
//     widget.mobileTabController.addListener(_handleTabChange);
//     _searchFocusNode.addListener(_handleSearchFocusChange);
//   }
//
//   void _handleTabChange() {
//     if (!widget.mobileTabController.indexIsChanging) {
//       widget.onTabChanged(widget.mobileTabController.index);
//       setState(() {
//         _isSearchExpanded = false;
//         _searchFocusNode.unfocus();
//         widget.searchController.clear();
//         context.read<OrderCubit>().applyFilter(OrderFilter.all);
//       });
//     }
//   }
//
//   void _handleSearchFocusChange() {
//     if (!_searchFocusNode.hasFocus && widget.searchController.text.isEmpty) {
//       setState(() => _isSearchExpanded = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     widget.mobileTabController.removeListener(_handleTabChange);
//     _searchFocusNode.removeListener(_handleSearchFocusChange);
//     _searchFocusNode.dispose();
//     super.dispose();
//   }
//
//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       title: Text(widget.store?.name ?? 'Pedidos', style: const TextStyle(fontWeight: FontWeight.bold)),
//       centerTitle: true,
//       backgroundColor: Colors.white,
//       foregroundColor: Colors.black,
//       elevation: 1,
//       actions: [
//         if (widget.orderState is OrdersLoaded)
//           _buildFilterDropdown((widget.orderState as OrdersLoaded).filter),
//         IconButton(
//           icon: Icon(_isSearchExpanded ? Icons.close : Icons.search),
//           onPressed: () => setState(() {
//             _isSearchExpanded = !_isSearchExpanded;
//             if (_isSearchExpanded) _searchFocusNode.requestFocus();
//             else {
//               widget.searchController.clear();
//               _searchFocusNode.unfocus();
//             }
//           }),
//         ),
//       ],
//       bottom: PreferredSize(
//         preferredSize: Size.fromHeight(_isSearchExpanded ? 60 : 48),
//         child: Column(
//           children: [
//             _buildSearchField(),
//             _buildTabBar(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFilterDropdown(OrderFilter currentFilter) {
//     return DropdownButtonHideUnderline(
//       child: DropdownButton<OrderFilter>(
//         value: currentFilter,
//         icon: const Icon(Icons.filter_list, color: Colors.black54),
//         items: OrderFilter.values.map((filter) {
//           return DropdownMenuItem<OrderFilter>(
//             value: filter,
//             child: Text(
//               orderFilterToDisplayName[filter] ?? 'Filtro',
//               style: const TextStyle(fontSize: 14),
//             ),
//           );
//         }).toList(),
//         onChanged: (newFilter) {
//           if (newFilter != null) {
//             context.read<OrderCubit>().applyFilter(newFilter);
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildSearchField() {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       height: _isSearchExpanded ? 60 : 0,
//       child: _isSearchExpanded
//           ? Padding(
//         padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
//         child: TextField(
//           controller: widget.searchController,
//           focusNode: _searchFocusNode,
//           decoration: InputDecoration(
//             hintText: 'Buscar por nome ou ID...',
//             prefixIcon: const Icon(Icons.search),
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
//             filled: true,
//             fillColor: Colors.grey[200],
//             contentPadding: EdgeInsets.zero,
//           ),
//           onChanged: (_) => setState(() {}),
//         ),
//       )
//           : const SizedBox.shrink(),
//     );
//   }
//
//   Widget _buildTabBar() {
//     int nowCount = 0;
//     int scheduledCount = 0;
//
//     if (widget.orderState is OrdersLoaded) {
//       final allOrders = (widget.orderState as OrdersLoaded).orders;
//       nowCount = allOrders.where((o) => o.scheduledFor == null).length;
//       scheduledCount = allOrders.where((o) => o.scheduledFor != null).length;
//     }
//
//     return TabBar(
//       controller: widget.mobileTabController,
//       isScrollable: true,
//       indicator: const UnderlineTabIndicator(borderSide: BorderSide(width: 3.0, color: Colors.red), insets: EdgeInsets.symmetric(horizontal: 16.0)),
//       labelColor: Colors.red,
//       unselectedLabelColor: Colors.black,
//       tabs: [
//         Tab(child: _buildTabLabel('Agora', nowCount)),
//         Tab(child: _buildTabLabel('Agendados', scheduledCount)),
//       ],
//     );
//   }
//
//   Widget _buildTabLabel(String text, int count) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(text),
//         if (count > 0)
//           Padding(
//             padding: const EdgeInsets.only(left: 8.0),
//             child: CountBadge(count: count),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return const Center(child: Text("Nenhum pedido encontrado."));
//   }
//
//   Widget _buildOrderList(List<OrderDetails> orders, OrderFilter activeFilter) {
//     if (activeFilter != OrderFilter.all) {
//       return ListView.builder(
//         padding: const EdgeInsets.all(8),
//         itemCount: orders.length,
//         itemBuilder: (context, index) => OrderListItem(
//           order: orders[index],
//           store: widget.store,
//           onTap: () => widget.onOpenOrderDetailsPage(context, orders[index]),
//         ),
//       );
//     }
//     return _buildGroupedOrderList(orders);
//   }
//
//   Widget _buildGroupedOrderList(List<OrderDetails> orders) {
//     final ordersByStatus = groupBy(orders, (order) => order.orderStatus);
//     const displayStatuses = ['pending', 'preparing', 'ready', 'on_route', 'delivered', 'canceled'];
//
//     return ListView(
//       padding: const EdgeInsets.all(8),
//       children: displayStatuses.map((status) {
//         final statusOrders = ordersByStatus[status] ?? [];
//         if (statusOrders.isEmpty) return const SizedBox.shrink();
//
//         return Card(
//           margin: const EdgeInsets.symmetric(vertical: 4),
//           elevation: 1,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           child: ExpansionTile(
//             initiallyExpanded: status == 'pending',
//             title: Text('${internalStatusToDisplayName[status] ?? status} (${statusOrders.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
//             children: statusOrders.map((order) => OrderListItem(
//               order: order,
//               store: widget.store,
//               onTap: () => widget.onOpenOrderDetailsPage(context, order),
//             )).toList(),
//           ),
//         );
//       }).toList(),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(),
//       body: Builder(
//         builder: (context) {
//           if (widget.orderState is OrdersLoading || widget.orderState is OrdersInitial) {
//             return const Center(child: DotLoading());
//           }
//           if (widget.orderState is OrdersError) {
//             return Center(child: Text('Erro: ${(widget.orderState as OrdersError).message}'));
//           }
//           if (widget.orderState is OrdersLoaded) {
//             // O pai (OrdersPage) já fez a filtragem, agora usamos a lista final.
//             if (widget.displayOrders.isEmpty) {
//               return _buildEmptyState();
//             }
//             return _buildOrderList(
//               widget.displayOrders,
//               (widget.orderState as OrdersLoaded).filter,
//             );
//           }
//           return _buildEmptyState();
//         },
//       ),
//     );
//   }
// }