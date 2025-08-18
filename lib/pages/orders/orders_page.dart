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
      padding: EdgeInsets.fromLTRB(16, 0, _selectedOrder == null ? 16 : 8, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<OrderCubit, OrderState>(
                builder: (context, orderState) {
                  if (orderState is! OrdersLoaded) {
                    return const Center(child: DotLoading());
                  }
                  final filteredOrders = _filterOrders(orderState.orders);

                  if (filteredOrders.isEmpty) {
                    return const EmptyOrdersView();
                  }

                  // A lógica do Kanban agora depende da chave da aba
                  if (_selectedTabKey == 'delivery') {
                    return _buildKanbanView(filteredOrders, activeStore);
                  } else {
                    return _buildOrdersDataTable(filteredOrders);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ WIDGET DA BARRA SUPERIOR TOTALMENTE REFEITO
  Widget _buildTopBar(BuildContext context, Store? activeStore) {
    // A barra de topo agora reage às mudanças do estado da loja
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, storeState) {



        if (storeState is! StoresManagerLoaded) return const SizedBox.shrink();

        final currentStore = storeState.stores[storeState.activeStoreId]?.store;
        final options = currentStore?.relations.storeOperationConfig;

        // 1. Construir a lista de abas disponíveis na ordem desejada
        final List<Map<String, dynamic>> availableTabsConfig = [];
        if (options?.deliveryEnabled ?? false) {
          availableTabsConfig.add({'key': 'delivery', 'label': 'Delivery', 'icon': Icons.delivery_dining});
        }
        if (options?.pickupEnabled ?? false) {
          availableTabsConfig.add({'key': 'balcao', 'label': 'Balcão', 'icon': Icons.storefront});
        }
        if (options?.tableEnabled ?? false) {
          availableTabsConfig.add({'key': 'mesa', 'label': 'Mesas', 'icon': Icons.table_restaurant});
        }

        // 2. Garantir que uma aba válida esteja sempre selecionada
        if (_selectedTabKey == null && availableTabsConfig.isNotEmpty) {
          // Se nenhuma aba estiver selecionada, seleciona a primeira da lista
          _selectedTabKey = availableTabsConfig.first['key'];
        } else if (_selectedTabKey != null && !availableTabsConfig.any((tab) => tab['key'] == _selectedTabKey)) {
          // Se a aba selecionada foi desativada, seleciona a primeira disponível
          _selectedTabKey = availableTabsConfig.isNotEmpty ? availableTabsConfig.first['key'] : null;
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            children: [
              // 3. Renderizar as abas dinamicamente
              ...availableTabsConfig.map((tabConfig) {
                return OrderTypeTab(
                  icon: tabConfig['icon'],
                  label: tabConfig['label'],
                  count: 0, // Adicionar lógica de contagem se necessário
                  isSelected: _selectedTabKey == tabConfig['key'],
                  onTap: () => setState(() {
                    _selectedTabKey = tabConfig['key'];
                  }),
                );
              }).toList(),

              const Spacer(),

              // Botões de Ação (Impressora, etc.)
              if (activeStore != null) ...[

                BlocBuilder<StoresManagerCubit, StoresManagerState>(
                  builder: (context, state) {
                    bool needsConfiguration = false;
                    // O activeStoreId é necessário para o onPressed, então pegamos aqui
                    int activeStoreId = -1;

                    if (state is StoresManagerLoaded) {
                      // Guarda o ID da loja ativa para usar no botão
                      activeStoreId = state.activeStoreId;

                      final settings = state.activeStore?.relations.storeOperationConfig;

                      // Lógica que já corrigimos: precisa de config se AMBAS forem nulas.
                      if (settings == null ||
                          (settings.mainPrinterDestination == null &&
                              settings.kitchenPrinterDestination == null)) {
                        needsConfiguration = true;
                      }
                    }


                    final iconButton = IconButton(
                      icon: Icon(
                        Icons.print_outlined,
                        color: needsConfiguration ? Colors.amber : null,
                      ),
                      tooltip: 'Configurações de Impressão',
                      onPressed: () {
                        if (activeStoreId != -1) {
                          showResponsiveSidePanel(
                            context,
                            PrinterSettingsSidePanel(storeId: activeStoreId),
                          );
                        }
                      },
                    );

                    // ✅ PASSO 2: Decida qual widget final será renderizado.
                    Widget finalIconWidget;
                    if (needsConfiguration) {
                      // Se precisar de configuração, ENVOLVE o botão com o AvatarGlow.
                      finalIconWidget = AvatarGlow(
                        animate: true, // Sempre true aqui, pois só entra neste if se precisar
                        glowColor: Colors.amber, // Cor fixa também
                        duration: const Duration(milliseconds: 2000),
                        repeat: true,
                        child: iconButton,
                      );
                    } else {
                      // Se NÃO precisar, usa APENAS o IconButton.
                      finalIconWidget = iconButton;
                    }

                    // ✅ PASSO 3: Envolve o resultado final com o AccessWrapper.
                    return AccessWrapper(
                      featureKey: 'auto_printing',
                      child: finalIconWidget,
                    );
                  },
                ),


              ],
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700], foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18)),
                child: const Text('Novo pedido'),
              ),
            ],
          ),
        );
      },
    );
  }

// NOVO: WIDGET DA TABELA DE DADOS
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



  // Dentro da sua classe _OrdersPageState

// NOVO: WIDGET PARA UMA COLUNA DO KANBAN
  Widget _buildKanbanColumn({
    required String title,
    required Color backgroundColor,
    required List<OrderDetails> orders,
    required Store? store,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '${orders.length}',
                    style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  // Reutilizando seu OrderListItem
                  return OrderListItem(
                    order: order,
                    store: store,

                    onTap: () {
                      // É AQUI que você chama a função
                      showResponsiveSidePanel(
                        context,
                        OrderDetailsPanel(
                          order: order, // Use o 'order' do item clicado
                          store: store,
                          // IMPORTANTE: O onClose agora deve fechar a rota do Navigator
                          onClose: () => Navigator.of(context).pop(),
                        ),
                      );
                    },

                    // onTap: () {
                    //   // Atualiza o estado para mostrar o painel de detalhes
                    //   setState(() {
                    //     _selectedOrder = order;
                    //   });
                    // },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

// NOVO: WIDGET PRINCIPAL DO KANBAN QUE MONTA AS COLUNAS
  Widget _buildKanbanView(List<OrderDetails> orders, Store? store) {
    // Mapeia os status para as colunas
    final analysisOrders = orders.where((o) => o.orderStatus == 'pending').toList();
    final productionOrders = orders.where((o) => o.orderStatus == 'preparing').toList();
    final readyOrders = orders.where((o) => ['ready', 'on_route'].contains(o.orderStatus)).toList();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coluna 1: Em análise
          _buildKanbanColumn(
            title: 'Em análise',
            backgroundColor: Color(0xFFfb6f2d),
            orders: analysisOrders,
            store: store,
          ),
          // Coluna 2: Em produção
          _buildKanbanColumn(
            title: 'Em produção',
            backgroundColor: Color(0xFFfd9d30),
            orders: productionOrders,
            store: store,
          ),
          // Coluna 3: Prontos para entrega
          _buildKanbanColumn(
            title: 'Prontos para entrega',
            backgroundColor: Color(0xFF269247),
            orders: readyOrders,
            store: store,
          ),
        ],
      ),
    );
  }


}


