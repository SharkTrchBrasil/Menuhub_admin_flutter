import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:totem_pro_admin/constdata/colorprovider.dart';

import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/pages/base/BasePage.dart';
import 'package:totem_pro_admin/pages/orders/utils/order_helpers.dart';
import 'package:totem_pro_admin/pages/orders/widgets/kanban_column.dart';
import 'package:totem_pro_admin/pages/orders/widgets/orders_top_bar.dart';
import 'package:totem_pro_admin/services/print/printer_settings.dart';
import 'package:totem_pro_admin/pages/orders/store_settings.dart';
import 'package:totem_pro_admin/pages/orders/widgets/count_badge.dart';
import 'package:totem_pro_admin/pages/orders/widgets/desktoptoolbar.dart';
import 'package:totem_pro_admin/pages/orders/widgets/empty_order_view.dart';
import 'package:totem_pro_admin/pages/orders/widgets/mobile_order_layout.dart';
import 'package:totem_pro_admin/pages/orders/widgets/order_details_desktop.dart';
import 'package:totem_pro_admin/pages/orders/widgets/order_type_tab.dart';
import 'package:totem_pro_admin/pages/orders/widgets/store_header.dart';
import 'package:totem_pro_admin/pages/orders/widgets/summary_panel.dart';
import 'package:totem_pro_admin/pages/orders/widgets/order_list_item.dart';
import 'package:totem_pro_admin/widgets/access_wrapper.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';

import '../../core/helpers/sidepanel.dart';
import '../../services/subscription/subscription_service.dart';
import '../../widgets/appbarcode.dart';
import '../../widgets/select_store.dart';
import '../../widgets/subscription_blocked_card.dart';
import '../table/tables.dart';
import 'cubit/order_page_cubit.dart';
import 'cubit/order_page_state.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  OrderDetails? _selectedOrderDetails;

  // ✅ ESTADO DE FILTRO ATUALIZADO PARA SER MAIS ROBUSTO
  String? _selectedTabKey; // Ex: 'delivery', 'balcao', 'mesa'
  int _selectedStatusFilterIndex = 0;
  OrderDetails? _selectedOrder; // Estado para o pedido selecionado

  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncActiveStoreWithRoute();
    });
  }

  void _syncActiveStoreWithRoute() {
    final storeIdString = GoRouterState.of(context).pathParameters['storeId'];
    final storeId = int.tryParse(storeIdString ?? '');
    if (storeId == null) return;

    final storeCubit = context.read<StoresManagerCubit>();
    final currentState = storeCubit.state;
    if (currentState is StoresManagerLoaded && currentState.activeStoreId != storeId) {
      storeCubit.changeActiveStore(storeId);
    }
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
        _selectedOrderDetails = null;
      });
    }
  }

  void _onOrderSelected(OrderDetails order) {
    setState(() {
      _selectedOrderDetails = order;
    });
  }

  List<OrderDetails> _getDisplayOrders(List<OrderDetails> allOrders) {
    final tabFiltered = _currentTabIndex == 0
        ? allOrders.where((o) => o.scheduledFor == null).toList()
        : allOrders.where((o) => o.scheduledFor != null).toList();

    final searchText = _searchController.text.toLowerCase();
    if (searchText.isEmpty) return tabFiltered;

    return tabFiltered.where((order) =>
    order.customerName.toLowerCase().contains(searchText) ||
        order.publicId.toLowerCase().contains(searchText)
    ).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ✅ MÉTODO DE FILTRAGEM ATUALIZADO PARA USAR A CHAVE DA ABA
  List<OrderDetails> _filterOrders(List<OrderDetails> allOrders) {
    List<OrderDetails> orders;

    // 1. Filtro por tipo (usando a chave da aba)
    if (_selectedTabKey == null) {
      orders = []; // Se nenhuma aba estiver selecionada, não mostra nada
    } else {
      // O tipo de entrega no seu modelo é 'balcao', 'delivery', etc.
      // A chave da aba deve corresponder a isso.
      orders = allOrders.where((o) => o.deliveryType == _selectedTabKey).toList();
    }

    // 2. Filtro por status
    if (_selectedStatusFilterIndex == 1) {
      orders = orders.where((o) => o.orderStatus == 'pending').toList();
    } else if (_selectedStatusFilterIndex == 2) {
      orders = orders.where((o) => o.orderStatus == 'preparing').toList();
    }

    return orders;
  }

  @override
  Widget build(BuildContext context) {


    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, storeState) {
        if (storeState is! StoresManagerLoaded) {
          return const Scaffold(body: Center(child: DotLoading()));
        }

        final activeStore = storeState.stores[storeState.activeStoreId]?.store;
        final warningMessage = storeState.subscriptionWarning;

        return BlocBuilder<OrderCubit, OrderState>(
          builder: (context, orderState) {
            List<OrderDetails> displayOrders = [];
            if(orderState is OrdersLoaded) {
              displayOrders = _getDisplayOrders(orderState.orders);
            }

            return BasePage(
           //   desktopAppBar: appber(store: activeStore,),
              mobileBuilder: (context) => MobileOrderLayout(
                searchController: _searchController,
                onOpenOrderDetailsPage: (ctx, order) {
                  context.go(
                    '/stores/${activeStore?.core.id}/orders/${order.id}',
                    extra: {'order': order, 'store': activeStore},
                  );
                },
                store: activeStore,
                orderState: orderState,
                displayOrders: displayOrders, // Sua lista de pedidos filtrada
              ),
              desktopBuilder: (context) => _buildDesktopLayout(context, activeStore, warningMessage),
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context, Store? activeStore, String? warningMessage) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          if (warningMessage != null) SubscriptionBlockedCard(message: warningMessage),
          _buildTopBar(context, activeStore),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildMainContentPanel(context, activeStore),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContentPanel(BuildContext context, Store? activeStore) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16), // Padding ajustado
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        // ✅ AQUI ESTÁ A LÓGICA ATUALIZADA
        child: _buildCurrentTabView(activeStore),
      ),
    );
  }




  Widget _buildTopBar(BuildContext context, Store? activeStore) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, storeState) {
        if (storeState is! StoresManagerLoaded) return const SizedBox.shrink();

        final options = storeState.activeStore?.relations.storeOperationConfig;

        // 1. Lógica para determinar as abas disponíveis (agora vive na página)
        final availableTabsKeys = <String>[];
        if (options?.deliveryEnabled ?? false) availableTabsKeys.add('delivery');
        if (options?.pickupEnabled ?? false) availableTabsKeys.add('balcao');
        if (options?.tableEnabled ?? false) availableTabsKeys.add('mesa');

        // 2. Garante que uma aba válida esteja sempre selecionada
        // Usamos um `Future` para evitar chamar `setState` durante o build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_selectedTabKey == null && availableTabsKeys.isNotEmpty) {
            setState(() => _selectedTabKey = availableTabsKeys.first);
          } else if (_selectedTabKey != null && !availableTabsKeys.contains(_selectedTabKey)) {
            setState(() => _selectedTabKey = availableTabsKeys.isNotEmpty ? availableTabsKeys.first : null);
          }
        });

        // 3. Retorna o novo widget otimizado
        return OrdersTopBar(
          selectedTabKey: _selectedTabKey,
          onTabSelected: (newKey) {
            setState(() {
              _selectedTabKey = newKey;
            });
          },
        );
      },
    );
  }


  Widget _buildOrdersDataTable(List<OrderDetails> orders) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('DATA')),
        DataColumn(label: Text('ESTADO')),
        DataColumn(label: Text('TOTAL')),
        DataColumn(label: Text('CLIENTE')),
        DataColumn(label: Text('')), // Coluna de ações
      ],
      rows: orders.map((order) {
        return DataRow(
          cells: [
            DataCell(Text(order.createdAt.toString())), // Supondo que você tenha uma função para formatar data
            DataCell(Text(order.orderStatus)),
            DataCell(Text('R\$ ${order.totalPrice.toStringAsFixed(2)}')),
            DataCell(Text(order.customerName)),
            DataCell(Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.more_horiz), onPressed: (){}),
              ],
            )),
          ],
        );
      }).toList(),
    );
  }



  Widget _buildCurrentTabView(Store? activeStore) {
    switch (_selectedTabKey) {
      case 'delivery':
      // A view de Delivery usa o OrderCubit
        return BlocBuilder<OrderCubit, OrderState>(
          builder: (context, orderState) {
            if (orderState is! OrdersLoaded) return const Center(child: DotLoading());
            final filteredOrders = _filterOrders(orderState.orders);
            if (filteredOrders.isEmpty) return const EmptyOrdersView();
            return _buildKanbanView(filteredOrders, activeStore);
          },
        );

      case 'balcao':
      // A view de Balcão também usa o OrderCubit
        return BlocBuilder<OrderCubit, OrderState>(
          builder: (context, orderState) {
            if (orderState is! OrdersLoaded) return const Center(child: DotLoading());
            final filteredOrders = _filterOrders(orderState.orders);
            if (filteredOrders.isEmpty) return const EmptyOrdersView();
            return _buildOrdersDataTable(filteredOrders);
          },
        );

      case 'mesa':
      // A view de Mesas usa o novo TablesCubit!
        return const TablesGridView();

      default:
      // Estado inicial ou quando nenhuma aba está selecionada
        return const Center(child: DotLoading());
    }
  }



  Widget _buildKanbanView(List<OrderDetails> orders, Store? store) {
    // Mapeia os status para as colunas
    final analysisOrders = orders.where((o) => o.orderStatus == 'pending').toList();
    final productionOrders = orders.where((o) => o.orderStatus == 'preparing').toList();
    final readyOrders = orders.where((o) => ['ready', 'on_route'].contains(o.orderStatus)).toList();


    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
        builder: (context, storeState) {
      // Pega o Set de IDs do estado
      final stuckOrderIds = storeState is StoresManagerLoaded ? storeState.stuckOrderIds : <int>{};


    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coluna 1: Em análise
          Expanded(
            child: KanbanColumn(
              title: 'Em análise',
              backgroundColor: Color(0xFFfb6f2d),
              orders: analysisOrders,
              store: store,
              stuckOrderIds: stuckOrderIds,
            ),
          ),
          // Coluna 2: Em produção
          Expanded(
            child: KanbanColumn(
              title: 'Em produção',
              backgroundColor: Color(0xFFfd9d30),
              orders: productionOrders,
              store: store,
            ),
          ),
          // Coluna 3: Prontos para entrega
          Expanded(
            child: KanbanColumn(
              title: 'Prontos para entrega',
              backgroundColor: Color(0xFF269247),
              orders: readyOrders,
              store: store,
            ),
          ),
        ],
      ),
    );


        },
    );
  }












}


