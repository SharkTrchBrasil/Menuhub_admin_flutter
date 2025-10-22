
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/pages/orders/layout/desktop/views/orders_helper_page.dart';
import 'package:totem_pro_admin/pages/orders/layout/desktop/views/orders_list_page.dart';
import 'package:totem_pro_admin/pages/orders/layout/desktop/views/orders_menu_page.dart';
import 'package:totem_pro_admin/pages/orders/layout/desktop/views/orders_settings_page.dart';
import 'package:totem_pro_admin/pages/orders/layout/desktop/views/orders_shipping_page.dart';
import 'package:totem_pro_admin/pages/orders/layout/desktop/widgets/drawer_orders.dart';

import '../../../../cubits/store_manager_cubit.dart';
import '../../../../cubits/store_manager_state.dart';
import '../../../../widgets/dot_loading.dart';

class OrdersPageDesktop extends StatefulWidget {
  final int storeId;

  const OrdersPageDesktop({super.key, required this.storeId});

  @override
  State<OrdersPageDesktop> createState() => _OrdersPageDesktopState();
}

class _OrdersPageDesktopState extends State<OrdersPageDesktop> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncActiveStoreWithRoute();
    });
  }

  void _syncActiveStoreWithRoute() {
    final storeCubit = context.read<StoresManagerCubit>();
    final currentState = storeCubit.state;
    if (currentState is StoresManagerLoaded &&
        currentState.activeStoreId != widget.storeId) {
      storeCubit.changeActiveStore(widget.storeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.toString();

    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, storeState) {
        if (storeState is! StoresManagerLoaded) {
          return const Scaffold(body: Center(child: DotLoading()));
        }

        final activeStore = storeState.stores[storeState.activeStoreId]?.store;

        return OrdersDrawerLayout(
          storeId: widget.storeId,
          activeStore: activeStore,
          currentRoute: currentRoute,
          child: _buildContent(context, currentRoute),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, String currentRoute) {
    // ✅ Renderiza a página baseada na rota
    if (currentRoute.contains('/orders/list')) {
      return const OrdersListPage();
    } else if (currentRoute.contains('/orders/shipping')) {
      return const OrdersShippingPage();
    } else if (currentRoute.contains('/orders/menu')) {
      return const OrdersMenuPage();
    } else if (currentRoute.contains('/orders/help')) {
      return const OrdersHelpPage();
    } else if (currentRoute.contains('/orders/settings')) {
      return const OrdersSettingsPage();
    }

    // Default: Pedidos
    return const OrdersListPage();
  }
}
