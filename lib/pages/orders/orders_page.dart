// lib/pages/orders/orders_page.dart

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
import 'package:totem_pro_admin/pages/orders/widgets/count_badge.dart';
import 'package:totem_pro_admin/pages/orders/widgets/mobile_order_layout.dart';
import 'package:totem_pro_admin/pages/orders/widgets/store_header.dart';
import 'package:totem_pro_admin/pages/orders/widgets/summary_panel.dart';
import 'package:totem_pro_admin/pages/orders/widgets/order_list_item.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';


import '../../widgets/app_bar_subscription_info.dart';
import '../../widgets/select_store.dart';
import '../../widgets/subscription_blocked_card.dart';
import 'order_page_cubit.dart';
import 'order_page_state.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  OrderDetails? _selectedOrderDetails;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _searchController.addListener(() => setState(() {})); // Para a busca funcionar em tempo real

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, storeState) {
        if (storeState is! StoresManagerLoaded) {
          return const Scaffold(body: Center(child: DotLoading()));
        }



        final activeStore = storeState.stores[storeState.activeStoreId]?.store;

        // NOVO: Pega a mensagem de aviso do estado do Cubit
        final warningMessage = storeState.subscriptionWarning;



        // 2. NOVA LÓGICA: Se houver uma mensagem de aviso, exibe uma tela de bloqueio e para aqui.
        if (warningMessage != null) {
          return BasePage(
            desktopAppBar: AppBarCustom(title: '', actions: [
              Row(children: [StoreSelectorWidget()])
            ]),
            // Mostra o card de bloqueio tanto no mobile quanto no desktop
            mobileBuilder: (context) => Center(child: SubscriptionBlockedCard(message: warningMessage)),
            desktopBuilder: (context) => Center(child: SubscriptionBlockedCard(message: warningMessage)),
          );
        }




        // Ouve o OrderCubit para obter a lista de pedidos e o estado de filtro
        return BlocBuilder<OrderCubit, OrderState>(
          builder: (context, orderState) {

            // A lógica de filtragem agora vive aqui, no pai.
            List<OrderDetails> displayOrders = [];
            if(orderState is OrdersLoaded) {
              displayOrders = _getDisplayOrders(orderState.orders);
            }

            return BasePage(
              desktopAppBar: AppBarCustom(title: '', actions: [
                Row(
                  children: [
                  //  AppBarSubscriptionInfo(),
                    StoreSelectorWidget(),

                  ],
                )



              ],),


              mobileBuilder: (context) => MobileOrderLayout(

                mobileTabController: _tabController,
                searchController: _searchController,
                currentTabIndex: _currentTabIndex,
                onTabChanged: (index) => _tabController.animateTo(index),
                onOpenOrderDetailsPage: (ctx, order) {
                  context.go(
                    '/stores/${activeStore?.id}/orders/${order.id}',
                    extra: {'order': order, 'store': activeStore},
                  );
                },
                // Passando os dados e estado necessários para o filho "burro"
                store: activeStore,
                orderState: orderState,
                displayOrders: displayOrders,
              ),
              desktopBuilder: (context) => _buildDesktopLayout(context, activeStore, warningMessage),
            );
          },
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context, Store? activeStore, String? warningMessage) {
    // Ouve o OrderCubit para obter a lista de pedidos e o estado de carregamento
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, orderState) {
        return Scaffold(
          body: Column(
            children: [


              // NOVO: Adiciona o banner se existir uma mensagem
              if (warningMessage != null) SubscriptionBlockedCard(message:warningMessage),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildOrderListPanel(context, activeStore, orderState),
                    ),
                    Expanded(
                      flex: 4,
                      child: SummaryPanel(
                        selectedOrder: _selectedOrderDetails,
                        store: activeStore,
                        orderState: orderState, // Passa o estado completo dos pedidos
                        notifire: Provider.of<ColorNotifire>(context, listen: false),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderListPanel(BuildContext context, Store? activeStore, OrderState orderState) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [




                _buildTabBar(orderState),



                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome ou ID...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                const SizedBox(height: 16),

                _buildAutoAcceptToggle(context, activeStore),


              ],
            ),
          ),





          Expanded(
            child: Builder(
              builder: (context) {
                if (orderState is! OrdersLoaded) {
                  return const Center(child: DotLoading());
                }

                final displayOrders = _getDisplayOrders(orderState.orders);

                if (displayOrders.isEmpty) {
                  return const Center(child: Text('Nenhum pedido encontrado.'));
                }

                return ListView.builder(
                  itemCount: displayOrders.length,
                  itemBuilder: (context, index) {
                    final order = displayOrders[index];
                    return OrderListItem(
                      order: order,
                      store: activeStore,
                      onTap: () => _onOrderSelected(order),
                     // isSelected: _selectedOrderDetails?.id == order.id,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }


// Adicione este método na sua classe da página de Pedidos

  Widget _buildAutoAcceptToggle(BuildContext context, Store? activeStore) {
    // Garante que só vamos construir o widget se tivermos uma loja e configurações válidas.
    if (activeStore == null || activeStore.storeSettings == null) {
      return const SizedBox.shrink(); // Retorna um widget vazio se não houver dados
    }

    final settings = activeStore.storeSettings!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Aceitar pedidos automaticamente',
            style: TextStyle(fontSize: 16),
          ),
          Switch(
            value: settings.autoAcceptOrders,
            onChanged: (newValue) {
              // Chama o método do Cubit para atualizar a configuração no backend
              context.read<StoresManagerCubit>().updateStoreSettings(
                activeStore.id!,
                autoAcceptOrders: newValue,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(OrderState orderState) {
    int nowCount = 0;
    int scheduledCount = 0;

    if (orderState is OrdersLoaded) {
      final allOrders = (orderState).orders;
      nowCount = allOrders.where((o) => o.scheduledFor == null && o.orderStatus == "pending").length;



      scheduledCount = allOrders.where((o) => o.scheduledFor != null).length;
    }

    return TabBar(
      controller: _tabController,
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


}