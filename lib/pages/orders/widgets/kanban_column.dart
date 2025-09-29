// lib/pages/orders/widgets/kanban_column.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/helpers/sidepanel.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/pages/orders/details/order_details_desktop.dart';
import 'package:totem_pro_admin/pages/orders/widgets/order_list_item.dart';

import '../../../cubits/store_manager_cubit.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final List<OrderDetails> orders;
  final Store? store;
  final Set<int> stuckOrderIds;

  const KanbanColumn({
    Key? key,
    required this.title,
    required this.backgroundColor,
    required this.orders,
    required this.store,
    this.stuckOrderIds = const {},
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da Coluna
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

          // Lista de Pedidos
          Expanded(
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                // ✅ 5. PARA CADA ITEM, VERIFIQUE SE SEU ID ESTÁ NA LISTA DE ALERTAS
                final bool isStuck = stuckOrderIds.contains(order.id);



                return OrderListItem(
                  order: order,
                  isStuck: isStuck,
                  store: store,
                  onTap: () {
                    if (isStuck) {
                      context.read<StoresManagerCubit>().clearStuckOrderAlert(order.id);
                    }
                    showResponsiveSidePanel(
                      context,
                      OrderDetailsPanel(
                        order: order,
                        store: store,
                        onClose: () => Navigator.of(context).pop(),
                      ),
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
}