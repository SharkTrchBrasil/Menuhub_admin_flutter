import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../cubits/store_manager_cubit.dart';
import '../../../../../cubits/store_manager_state.dart';
import '../../../../../models/order_details.dart';
import '../../../cubit/order_page_cubit.dart';
import '../../../cubit/order_page_state.dart';
import '../widgets/ifood_dashboard_panel.dart';
import '../widgets/ifood_orders_panel.dart';

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<StoresManagerCubit, StoresManagerState>(
        builder: (context, storeState) {
          if (storeState is! StoresManagerLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final activeStore = storeState.activeStore;

          return BlocBuilder<OrderCubit, OrderState>(
            builder: (context, orderState) {
              if (orderState is OrdersLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final orders = orderState is OrdersLoaded
                  ? orderState.orders
                  : <OrderDetails>[];
              final isLoading = orderState is! OrdersLoaded;



              return Row(
                children: [
                  // ✅ Painel da direita: Lista de Pedidos
                  Expanded(
                    flex: 2,
                    child: IfoodOrdersPanel(
                      orders: orders,
                      isLoading: isLoading,
                      onOrderSelected: (order) {
                        // ✅ Ação ao selecionar pedido
                        print('Pedido selecionado: ${order.publicId}');
                      },
                    ),
                  ),

                  // ✅ Painel da esquerda: Dashboard
                  Expanded(
                    flex: 3,
                    child: IfoodDashboardPanel(
                      activeStore: activeStore,
                      orders: orders,
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
}