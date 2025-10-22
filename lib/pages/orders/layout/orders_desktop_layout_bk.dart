// orders_desktop_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/pages/orders/widgets/empty_order_view.dart';
import 'package:totem_pro_admin/pages/orders/widgets/kanban_column.dart';
import 'package:totem_pro_admin/pages/orders/widgets/operational_shortcuts.dart';
import 'package:totem_pro_admin/pages/orders/widgets/orders_top_bar.dart';
import 'package:totem_pro_admin/widgets/dot_loading.dart';
import 'package:totem_pro_admin/pages/table/tables.dart';
import 'package:totem_pro_admin/pages/commands/commands_page.dart';

import '../../../core/di.dart';
import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';
import '../../commands/cubit/standalone_commands_cubit.dart'; // ✅ NOVO IMPORT

class OrdersDesktopLayout1 extends StatefulWidget {
  final Store? activeStore;
  final String? warningMessage;
  final List<OrderDetails> orders;
  final bool isLoading;
  final Function(OrderDetails) onOrderSelected;

  const OrdersDesktopLayout1({
    super.key,
    required this.activeStore,
    this.warningMessage,
    required this.orders,
    required this.isLoading,
    required this.onOrderSelected,
  });

  @override
  State<OrdersDesktopLayout1> createState() => _OrdersDesktopLayout1State();
}

class _OrdersDesktopLayout1State extends State<OrdersDesktopLayout1> {
  String? _selectedTabKey = 'balcao'; // 'balcao', 'delivery', 'mesa', 'comandas'
  int _selectedStatusFilterIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (widget.warningMessage != null)
          SubscriptionBlockedCard(message: widget.warningMessage!),

        // Barra superior com tabs
        OrdersTopBar(
          selectedTabKey: _selectedTabKey,
          onTabSelected: (key) {
            setState(() {
              _selectedTabKey = key;
            });
          },
        ),

        // Atalhos operacionais (tempo de entrega, pedido mínimo)
        // ✅ NÃO MOSTRA PARA MESAS E COMANDAS
        if (_selectedTabKey != 'mesa' && _selectedTabKey != 'comandas')
          OperationalShortcutsBar(
            store: widget.activeStore,
            onEditDeliveryTime: () {
              // TODO: Implementar edição de tempo de entrega
            },
            onEditMinOrder: () {
              // TODO: Implementar edição de pedido mínimo
            },
          ),

        // Conteúdo principal baseado na tab selecionada
        Expanded(
          child: _buildTabContent(),
        ),
      ],
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabKey) {
      case 'balcao':
        return _buildBalcaoTab();
      case 'delivery':
        return _buildDeliveryTab();
      case 'mesa':
        return _buildMesasTab();
      case 'comandas': // ✅ NOVO CASE
        return _buildComandasTab();
      default:
        return _buildBalcaoTab();
    }
  }

  Widget _buildBalcaoTab() {
    if (widget.isLoading) {
      return const Center(child: DotLoading());
    }

    final balcaoOrders = widget.orders.where((order) =>
    order.deliveryType == 'takeout' &&
        !_isCompletedOrCanceled(order)).toList();

    if (balcaoOrders.isEmpty) {
      return const EmptyOrdersView();
    }

    return _buildKanbanView(balcaoOrders, 'Balcão');
  }

  Widget _buildDeliveryTab() {
    if (widget.isLoading) {
      return const Center(child: DotLoading());
    }

    final deliveryOrders = widget.orders.where((order) =>
    order.deliveryType == 'delivery' &&
        !_isCompletedOrCanceled(order)).toList();

    if (deliveryOrders.isEmpty) {
      return const EmptyOrdersView();
    }

    return _buildKanbanView(deliveryOrders, 'Delivery');
  }

  Widget _buildMesasTab() {
    // Tab de Mesas: Mostra o grid de mesas do salão
    return const SaloonsAndTablesPanel();
  }



  Widget _buildComandasTab() {
    return BlocProvider(
      create: (context) => getIt<StandaloneCommandsCubit>()
        ..connectToStore(
          (context.read<StoresManagerCubit>().state as StoresManagerLoaded)
              .activeStoreId,
        ),
      child: const CommandsPage(),
    );
  }



  Widget _buildKanbanView(List<OrderDetails> orders, String title) {
    // Agrupar pedidos por status para o Kanban
    final pendingOrders = orders.where((o) => o.orderStatus == 'pending').toList();
    final preparingOrders = orders.where((o) => o.orderStatus == 'preparing').toList();
    final readyOrders = orders.where((o) => o.orderStatus == 'ready').toList();
    final onRouteOrders = orders.where((o) => o.orderStatus == 'on_route').toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header do Kanban
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                // Cards de resumo
                Row(
                  children: [
                    _buildSummaryCard('Novos', pendingOrders.length.toString(), Colors.orange),
                    const SizedBox(width: 12),
                    _buildSummaryCard('Preparo', preparingOrders.length.toString(), Colors.blue),
                    const SizedBox(width: 12),
                    _buildSummaryCard('Prontos', readyOrders.length.toString(), Colors.green),
                    if (onRouteOrders.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      _buildSummaryCard('Entrega', onRouteOrders.length.toString(), Colors.purple),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Kanban columns
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coluna "Novos"
                Expanded(
                  child: KanbanColumn(
                    title: 'Novos',
                    backgroundColor: Colors.orange,
                    orders: pendingOrders,
                    store: widget.activeStore,
                    stuckOrderIds: const {},
                  ),
                ),
                const SizedBox(width: 12),

                // Coluna "Em Preparo"
                Expanded(
                  child: KanbanColumn(
                    title: 'Em Preparo',
                    backgroundColor: Colors.blue,
                    orders: preparingOrders,
                    store: widget.activeStore,
                    stuckOrderIds: const {},
                  ),
                ),
                const SizedBox(width: 12),

                // Coluna "Prontos"
                Expanded(
                  child: KanbanColumn(
                    title: 'Prontos',
                    backgroundColor: Colors.green,
                    orders: readyOrders,
                    store: widget.activeStore,
                    stuckOrderIds: const {},
                  ),
                ),

                // Coluna "Em Entrega" (apenas para delivery)
                if (_selectedTabKey == 'delivery' && onRouteOrders.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: KanbanColumn(
                      title: 'Em Entrega',
                      backgroundColor: Colors.purple,
                      orders: onRouteOrders,
                      store: widget.activeStore,
                      stuckOrderIds: const {},
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  bool _isCompletedOrCanceled(OrderDetails order) {
    return ['delivered', 'finalized', 'canceled'].contains(order.orderStatus);
  }
}

class SubscriptionBlockedCard extends StatelessWidget {
  final String message;

  const SubscriptionBlockedCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.orange[100],
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}