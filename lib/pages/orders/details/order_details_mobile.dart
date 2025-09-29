// lib/pages/orders/widgets/order_details_mobile.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/pages/orders/cubit/order_page_cubit.dart';
import 'package:totem_pro_admin/pages/orders/cubit/order_page_state.dart';
import 'package:totem_pro_admin/pages/orders/details/widgets/order_header_card.dart';
import 'package:totem_pro_admin/pages/orders/details/widgets/order_items_card.dart';
import 'package:totem_pro_admin/pages/orders/details/widgets/order_logistics_card.dart';
import 'package:totem_pro_admin/pages/orders/details/widgets/order_status_bar.dart';
import 'package:totem_pro_admin/pages/orders/details/widgets/order_summary_card.dart';
import 'package:totem_pro_admin/pages/orders/utils/order_helpers.dart';
import 'package:totem_pro_admin/pages/orders/widgets/store_header.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/widgets/order_printing_actions_widget.dart';

import '../widgets/order_status_button.dart';



class OrderDetailsPageMobile extends StatefulWidget {
  final OrderDetails order;
  final Store store;

  const OrderDetailsPageMobile({
    super.key,
    required this.order,
    required this.store,
  });

  @override
  State<OrderDetailsPageMobile> createState() => _OrderDetailsPageMobileState();
}

class _OrderDetailsPageMobileState extends State<OrderDetailsPageMobile> {
  // A lógica de scroll e de cancelamento continua aqui, pois controla a página como um todo.
  final ScrollController _scrollController = ScrollController();
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (!mounted) return;
    final shouldCollapse = _scrollController.offset > 60;
    if (shouldCollapse != _collapsed) {
      setState(() => _collapsed = shouldCollapse);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _showCancelDialog(BuildContext context, OrderDetails order) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirmar Cancelamento'),
          content: Text('Tem certeza que deseja cancelar o pedido #${order.publicId}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Não'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sim', style: TextStyle(color: Colors.white)),
              onPressed: () {
                context.read<OrderCubit>().updateOrderStatus(order.id, 'canceled');
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is! OrdersLoaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final updatedOrder = state.orders.firstWhere(
              (o) => o.id == widget.order.id,
          orElse: () => widget.order,
        );

        final isOrderFinished = ['finalized', 'canceled'].contains(updatedOrder.orderStatus);

        return Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                elevation: 1,
                expandedHeight: 80,
                centerTitle: true,
                title: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _collapsed ? 1.0 : 0.0,
                  child: Text(
                    '#${updatedOrder.sequentialId} - ${updatedOrder.customerName}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                actions: [
                  OrderPrintingActionsWidget(order: updatedOrder, store: widget.store),
                  if (canStoreCancelOrder(updatedOrder.orderStatus))
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'cancel') {
                          _showCancelDialog(context, updatedOrder);
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'cancel',
                          child: ListTile(
                            leading: Icon(Icons.cancel_outlined, color: Colors.red),
                            title: Text('Cancelar Pedido', style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    if (!_collapsed) OrderHeaderCard(order: updatedOrder),
                    OrderStatusBar(order: updatedOrder),
                    const Divider(thickness: 1, height: 35),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: StoreHeader(store: widget.store),
                    ),
                    const Divider(thickness: 1, height: 24),

                    // Você criaria estes widgets da mesma forma que criamos os outros
                     OrderItemsCard(order: updatedOrder),
                     const Divider(thickness: 1, height: 24),
                     OrderSummaryCard(order: updatedOrder),
                     const Divider(thickness: 1, height: 24),
                     OrderLogisticsCard(order: updatedOrder),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: isOrderFinished
              ? null
              : BottomAppBar(
            color: Colors.white,
            elevation: 10.0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: OrderStatusButton(
                order: updatedOrder,
                store: widget.store,
              ),
            ),
          ),
        );
      },
    );
  }
}