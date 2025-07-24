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
import 'package:totem_pro_admin/pages/orders/printer_settings.dart';
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
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/widgets/mobileappbar.dart';



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
  // VARIÁVEIS DE ESTADO ATUALIZADAS
  bool _areTabsMerged = false; // Novo estado para fundir abas
  int _selectedOrderTypeIndex = 0;
  int _selectedStatusFilterIndex = 0;
// Novo estado para fundir abas
  OrderDetails? _selectedOrder; // Novo estado para o pedido selecionado

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


  // NOVO: Função para abrir os painéis de overlay (impressora, etc.)
  void _showOverlaySidePanel(BuildContext context, Widget panel) {
    // Use a função com PageRouteBuilder da resposta anterior
    Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => panel,
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.5),
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeOut));
          return SlideTransition(position: animation.drive(tween), child: child);
        }));
  }


  // MÉTODO DE FILTRAGEM ATUALIZADO
  List<OrderDetails> _filterOrders(List<OrderDetails> allOrders) {
    List<OrderDetails> orders;

    // 1. Filtro por tipo (com lógica de "Fundir")
    if (_areTabsMerged) {
      // Se fundido, pega pedidos de Balcão E Delivery
      orders = allOrders.where((o) => o.deliveryType == 'balcao' || o.deliveryType == 'delivery').toList();
    } else {
      final orderTypes = ['balcao', 'delivery', 'mesa'];
      final selectedType = orderTypes[_selectedOrderTypeIndex];
      orders = allOrders.where((o) => o.deliveryType == selectedType).toList();
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

        // NOVO: Pega a mensagem de aviso do estado do Cubit
        final warningMessage = storeState.subscriptionWarning;




        // Ouve o OrderCubit para obter a lista de pedidos e o estado de filtro
        return BlocBuilder<OrderCubit, OrderState>(
          builder: (context, orderState) {

            // A lógica de filtragem agora vive aqui, no pai.
            List<OrderDetails> displayOrders = [];
            if(orderState is OrdersLoaded) {
              displayOrders = _getDisplayOrders(orderState.orders);
            }

            return BasePage(
              desktopAppBar: appber(store: activeStore,),

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







  // Dentro da sua classe _OrdersPageState

// MODIFIQUE O MÉTODO _buildDesktopLayout PARA USAR O PAINEL DE DETALHES ADAPTADO
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
                  // ✅ Passa o activeStore para o painel de conteúdo
                  child: _buildMainContentPanel(context, activeStore),
                ),
                // ✅ Usa o novo OrderDetailsPanel adaptado
                if (_selectedOrder != null)


                  OrderDetailsPanel(
                    order: _selectedOrder!,
                    store: activeStore,
                    onClose: () => setState(() => _selectedOrder = null),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

// MODIFIQUE O MÉTODO _buildMainContentPanel PARA RENDERIZAÇÃO CONDICIONAL
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
            _buildFiltersBar(context),
            const Divider(height: 1),
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

                  // ✅ LÓGICA CONDICIONAL AQUI
                  // Se a aba "Delivery" (índice 1) estiver selecionada, mostra o Kanban.
                  // Caso contrário, mostra a tabela de dados.
                  if (_selectedOrderTypeIndex == 1) {
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
















// WIDGET DA BARRA SUPERIOR ATUALIZADO
  Widget _buildTopBar(BuildContext context, Store? activeStore) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Tabs
          OrderTypeTab(
              icon: Icons.storefront, label: 'Balcão', count: 0,
              isSelected: _selectedOrderTypeIndex == 0 && !_areTabsMerged,
              onTap: () => setState(() { _selectedOrderTypeIndex = 0; _areTabsMerged = false; })),
          OrderTypeTab(
              icon: Icons.delivery_dining, label: 'Delivery', count: 1,
              isSelected: _selectedOrderTypeIndex == 1 && !_areTabsMerged,
              onTap: () => setState(() { _selectedOrderTypeIndex = 1; _areTabsMerged = false; })),
          OrderTypeTab(
              icon: Icons.table_restaurant, label: 'Mesas', count: 0,
              isSelected: _selectedOrderTypeIndex == 2 && !_areTabsMerged,
              onTap: () => setState(() { _selectedOrderTypeIndex = 2; _areTabsMerged = false; })),
          const SizedBox(width: 8),



          const Spacer(),

          // ✅ BOTÕES DE IMPRESSORA E CONFIGURAÇÕES
          if (activeStore != null) ...[
            IconButton(
              icon: const Icon(Icons.print_outlined),
              tooltip: 'Configurações de Impressão',
              onPressed: () => _showOverlaySidePanel(context, PrinterSettingsSidePanel(storeId: activeStore.id!)),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Configurações da Loja',
              onPressed: () => _showOverlaySidePanel(context, StoreSettingsSidePanel(storeId: activeStore.id!)),
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
  }














// NOVO: WIDGET DA BARRA DE FILTROS
  Widget _buildFiltersBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.filter_list)),
          FilterChip(
            label: const Text('Tudo'),
            selected: _selectedStatusFilterIndex == 0,
            onSelected: (selected) => setState(() => _selectedStatusFilterIndex = 0),
            selectedColor: Colors.blue[100],
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Pendente'),
            selected: _selectedStatusFilterIndex == 1,
            onSelected: (selected) => setState(() => _selectedStatusFilterIndex = 1),
            selectedColor: Colors.orange[100],
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Em curso'),
            selected: _selectedStatusFilterIndex == 2,
            onSelected: (selected) => setState(() => _selectedStatusFilterIndex = 2),
            selectedColor: Colors.green[100],
          ),
          const Spacer(),
          const Text('Total: ', style: TextStyle(fontWeight: FontWeight.bold)),
          IconButton(onPressed: (){}, icon: const Icon(Icons.visibility))
        ],
      ),
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
          color: backgroundColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '$title (${orders.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 1),
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
                      // Atualiza o estado para mostrar o painel de detalhes
                      setState(() {
                        _selectedOrder = order;
                      });
                    },
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
            backgroundColor: Colors.orange,
            orders: analysisOrders,
            store: store,
          ),
          // Coluna 2: Em produção
          _buildKanbanColumn(
            title: 'Em produção',
            backgroundColor: Colors.amber,
            orders: productionOrders,
            store: store,
          ),
          // Coluna 3: Prontos para entrega
          _buildKanbanColumn(
            title: 'Prontos para entrega',
            backgroundColor: Colors.green,
            orders: readyOrders,
            store: store,
          ),
        ],
      ),
    );
  }




  // Widget _buildDesktopLayout(BuildContext context, Store? activeStore, String? warningMessage) {
  //   // Ouve o OrderCubit para obter a lista de pedidos e o estado de carregamento
  //   return BlocBuilder<OrderCubit, OrderState>(
  //     builder: (context, orderState) {
  //       return Scaffold(
  //         body: Column(
  //           children: [
  //             // NOVO: Adiciona o banner se existir uma mensagem
  //             if (warningMessage != null) SubscriptionBlockedCard(message:warningMessage),
  //             Expanded(
  //               child: Row(
  //                 children: [
  //                   Expanded(
  //                     flex: 3,
  //                     child: _buildOrderListPanel(context, activeStore, orderState),
  //                   ),
  //                   Expanded(
  //                     flex: 4,
  //                     child: SummaryPanel(
  //                       selectedOrder: _selectedOrderDetails,
  //                       store: activeStore,
  //                       orderState: orderState, // Passa o estado completo dos pedidos
  //                       notifire: Provider.of<ColorNotifire>(context, listen: false),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }
  //







































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
    // Retorna um widget vazio se não houver loja ou configurações.
    // O '?' faz a checagem de nulo em cascata de forma segura e limpa.
    if (activeStore?.storeSettings == null) {
      return const SizedBox.shrink();
    }

    // A partir daqui, temos certeza que activeStore e storeSettings não são nulos.
    final settings = activeStore!.storeSettings!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // Garante alinhamento vertical
        children: [
          // ✅ AQUI ESTÁ A CORREÇÃO:
          // Envolvemos o Text com Expanded para que ele quebre a linha
          // se o texto for muito longo para o espaço disponível.
          const Expanded(
            child: Text(
              'Aceitar pedidos automaticamente',
              style: TextStyle(fontSize: 16),
            ),
          ),
          // Adiciona um pequeno espaçamento para garantir que não fiquem colados
          const SizedBox(width: 8),

          // O Switch ocupa seu espaço fixo.
          Switch(
            value: settings.autoAcceptOrders,
            onChanged: (newValue) {
              context.read<StoresManagerCubit>().updateStoreSettings(
                activeStore.id!, // Não precisa do '!' pois já foi checado
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



class OrderDetailsSidePanel extends StatelessWidget {
  final OrderDetails order;
  final VoidCallback onClose;
  final Store? store;

  const OrderDetailsSidePanel({
    super.key,
    required this.order,
    required this.onClose,
    this.store,
  });

  @override
  Widget build(BuildContext context) {
    // Usaremos o SummaryPanel que você já tinha, adaptado para este contexto
    // Se não tiver mais, pode criar um widget simples aqui.
    return Container(
      width: MediaQuery.of(context).size.width * 0.35, // Ocupa 35% da tela
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          left: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      // O SummaryPanel antigo pode ser reutilizado aqui.
      // Por simplicidade, vou criar um placeholder.
      child: Column(
        children: [
          // Barra superior do painel de detalhes
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Detalhes do Pedido #${order.publicId}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose, // Usa a função passada para fechar
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cliente: ${order.customerName}'),
                  const SizedBox(height: 8),
                  Text('Total: R\$ ${order.totalPrice.toStringAsFixed(2)}'),
                  const SizedBox(height: 8),
                  Text('Status: ${order.orderStatus}'),
                  // Adicione mais detalhes do pedido aqui
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}