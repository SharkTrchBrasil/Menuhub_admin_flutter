// lib/pages/orders/widgets/mobile_order_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store.dart';
import 'package:totem_pro_admin/pages/orders/widgets/responsive_order_view.dart';

import '../../../core/enums/order_view.dart';
import '../cubit/order_page_state.dart';
import '../store_settings.dart';
import 'management_switcher.dart';
import 'operational_shortcuts.dart';
import 'order_search_delegate.dart';

class MobileOrderLayout extends StatefulWidget {
  final void Function(BuildContext, OrderDetails) onOpenOrderDetailsPage;
  final Store? store;
  final OrderState orderState;

  const MobileOrderLayout({
    super.key,
    required this.onOpenOrderDetailsPage,
    required this.store,
    required this.orderState,
  });

  @override
  State<MobileOrderLayout> createState() => _MobileOrderLayoutState();
}

class _MobileOrderLayoutState extends State<MobileOrderLayout> {
  final GlobalKey<ResponsiveOrderViewState> _orderViewKey = GlobalKey<ResponsiveOrderViewState>();

  OrderViewMode _viewMode = OrderViewMode.list;
  int _selectedFilterIndex = 0;
  final List<ListFilter> _filters = [
    ListFilter.all,
    ListFilter.deliveries,
    ListFilter.scheduled,
    ListFilter.completed,
  ];

  // MODIFICADO: 2. Crie a função para mostrar o BottomSheet de configurações
  void _showStoreSettings() {
    // Garante que a loja não seja nula antes de tentar abrir as configurações
    if (widget.store == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma loja selecionada para configurar.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      // Permite que o conteúdo determine a altura, evitando que o teclado sobreponha
      isScrollControlled: true,
      // Define a cor de fundo como transparente para que o borderRadius funcione
      backgroundColor: Colors.transparent,
      builder: (context) {
        // Usa uma fração da altura da tela para não ocupar a tela inteira
        return FractionallySizedBox(
          heightFactor: 0.8, // Ocupa 80% da altura da tela
          child: StoreSettingsSidePanel(storeId: widget.store!.core.id!),
        );
      },
    );
  }

// ✅ 2. CRIE AS FUNÇÕES PARA MOSTRAR CADA BOTTOMSHEET
  void _showEditDeliveryTimeSheet() {
    if (widget.store?.relations.storeOperationConfig == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Essencial para o teclado não cobrir o campo
      builder: (context) => EditDeliveryTimeBottomSheet(
        storeId: widget.store!.core.id!,
        initialConfig: widget.store!.relations.storeOperationConfig!,
      ),
    );
  }

  void _showEditMinOrderSheet() {
    if (widget.store?.relations.storeOperationConfig == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditMinOrderBottomSheet(
        storeId: widget.store!.core.id!,
        initialConfig: widget.store!.relations.storeOperationConfig!,
      ),
    );
  }




  void _showSearch() async {
    final allOrders = (widget.orderState is OrdersLoaded)
        ? (widget.orderState as OrdersLoaded).orders
        : <OrderDetails>[];

    // AQUI ESTÁ A CORREÇÃO:
    final OrderDetails? selectedOrder = await showSearch<OrderDetails?>( // <-- Adicione o tipo aqui
      context: context,
      delegate: OrderSearchDelegate(allOrders),
    );

    if (selectedOrder != null && mounted) {
      widget.onOpenOrderDetailsPage(context, selectedOrder);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allOrders = (widget.orderState is OrdersLoaded)
        ? (widget.orderState as OrdersLoaded).orders
        : <OrderDetails>[];


    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
        title: const AppBarModeSwitcher(),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _showSearch),
          IconButton(
            icon: Icon(_viewMode == OrderViewMode.list ? Icons.view_day_outlined : Icons.view_list_outlined),
            tooltip: 'Mudar Layout',
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == OrderViewMode.list ? OrderViewMode.grouped : OrderViewMode.list;
              });
              _orderViewKey.currentState?.switchView();
            },
          ),

          // MODIFICADO: 3. Atualize o onPressed para chamar a nova função
          IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: _showStoreSettings // Chama a função do bottom sheet
          ),
        ],
      ),
      body: Column(
        children: [
          OperationalShortcutsBar(
            store: widget.store,
            onEditDeliveryTime: _showEditDeliveryTimeSheet,
            onEditMinOrder: _showEditMinOrderSheet,
          ),

          Expanded(
            child: ResponsiveOrderView(
              key: _orderViewKey,
              orders: allOrders,
              store: widget.store,
              initialViewMode: _viewMode,
              activeFilter: _filters[_selectedFilterIndex],
              onOrderTap: (order) => widget.onOpenOrderDetailsPage(context, order),
            ),
          )
        ],
      ),
      bottomNavigationBar: _viewMode == OrderViewMode.list
          ? BottomNavigationBar(
        currentIndex: _selectedFilterIndex,
        onTap: (index) {
          setState(() {
            _selectedFilterIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Pedidos'),
          BottomNavigationBarItem(icon: Icon(Icons.delivery_dining), label: 'Entregas'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Agendados'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Concluídos'),
        ],
      )
          : null,
    );
  }


}