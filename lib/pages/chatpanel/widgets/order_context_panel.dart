import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/models/order_details.dart';

import '../../orders/cubit/order_page_cubit.dart';

class OrderContextPanel extends StatelessWidget {
  final OrderDetails? order;

  const OrderContextPanel({Key? key, this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (order == null) {
      return const SizedBox.shrink(); // Não mostra nada se não houver pedido ativo
    }

    final orderCubit = context.read<OrderCubit>();

    return Container(
      padding: const EdgeInsets.all(12),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Pedido Ativo: #${order!.publicId}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Status: ${order!.orderStatus.toUpperCase()}'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ElevatedButton.icon(
                onPressed: () {   context.go('/stores/${order!.storeId}/orders/${order!.id}'); },
                icon: const Icon(Icons.visibility, size: 16),
                label: const Text('Ver Pedido'),
              ),
              if (order!.orderStatus != 'ready')
                ElevatedButton.icon(
                  // ✅ AÇÃO CONECTADA
                  onPressed: () {
                    orderCubit.updateOrderStatus(order!.id, 'ready');
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Marcar como Pronto'),
                ),
            ],
          )
        ],
      ),
    );
  }
}