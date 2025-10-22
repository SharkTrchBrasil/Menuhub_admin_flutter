import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../cubits/store_manager_cubit.dart';
import '../../../cubit/order_page_cubit.dart';
import '../../../cubit/order_page_state.dart';
import '../orders_desktop_layout.dart';

class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, orderState) {
          if (orderState is OrdersLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orderState is OrdersLoaded) {
            return OrdersDesktopLayout(
              activeStore: context.read<StoresManagerCubit>().g()?.store,
              warningMessage: null,
              orders: orderState.orders,
              isLoading: false,
              onOrderSelected: (order) {
                // Ação ao selecionar pedido
              },
            );
          }

          return const Center(child: Text('Erro ao carregar pedidos'));
        },
      ),
    );
  }
}