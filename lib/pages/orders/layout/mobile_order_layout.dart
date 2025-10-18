// lib/pages/orders/widgets/mobile_order_layout.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/di.dart';

import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/pages/orders/widgets/responsive_order_view.dart';

import '../../../core/enums/order_view.dart';
import '../../../widgets/app_shell.dart';
import '../../operation_configuration/cubit/operation_config_cubit.dart';
import '../cubit/order_page_state.dart';
import '../settings/orders_settings.dart';
import '../widgets/management_switcher.dart';
import '../widgets/operational_shortcuts.dart';
import '../widgets/order_search_delegate.dart';

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

  // ✅ Função atualizada para fornecer o Cubit
  void _showStoreSettings() {
    if (widget.store == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma loja selecionada para configurar.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // ✅ CORREÇÃO: Envolver com BlocProvider
        return BlocProvider<OperationConfigCubit>(
          create: (context) => getIt<OperationConfigCubit>(),
          child: FractionallySizedBox(
            heightFactor: 0.8,
            child: StoreSettingsSidePanel(storeId: widget.store!.core.id!),
          ),
        );
      },
    );
  }

  // ✅ Funções para os outros bottom sheets
  void _showEditDeliveryTimeSheet() {
    if (widget.store?.relations.storeOperationConfig == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        // ✅ Também forneça o Cubit aqui se necessário
        return BlocProvider<OperationConfigCubit>(
          create: (context) => getIt<OperationConfigCubit>(),
          child: EditDeliveryTimeBottomSheet(
            storeId: widget.store!.core.id!,
            initialConfig: widget.store!.relations.storeOperationConfig!,
          ),
        );
      },
    );
  }

  void _showEditMinOrderSheet() {
    if (widget.store?.relations.storeOperationConfig == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        // ✅ Também forneça o Cubit aqui se necessário
        return BlocProvider<OperationConfigCubit>(
          create: (context) => getIt<OperationConfigCubit>(),
          child: EditMinOrderBottomSheet(
            storeId: widget.store!.core.id!,
            initialConfig: widget.store!.relations.storeOperationConfig!,
          ),
        );
      },
    );
  }

  void _showSearch() async {
    final allOrders = (widget.orderState is OrdersLoaded)
        ? (widget.orderState as OrdersLoaded).orders
        : <OrderDetails>[];

    final OrderDetails? selectedOrder = await showSearch<OrderDetails?>(
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
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showStoreSettings,
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