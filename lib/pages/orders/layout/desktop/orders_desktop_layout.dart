// orders_desktop_layout.dart
import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/pages/orders/layout/desktop/ifood_desktop_layout.dart';

class OrdersDesktopLayout extends StatefulWidget {
  final Store? activeStore;
  final String? warningMessage;
  final List<OrderDetails> orders;
  final bool isLoading;
  final Function(OrderDetails) onOrderSelected;

  const OrdersDesktopLayout({
    super.key,
    required this.activeStore,
    this.warningMessage,
    required this.orders,
    required this.isLoading,
    required this.onOrderSelected,
  });

  @override
  State<OrdersDesktopLayout> createState() => _OrdersDesktopLayoutState();
}

class _OrdersDesktopLayoutState extends State<OrdersDesktopLayout> {

  @override
  Widget build(BuildContext context) {
    return IfoodDesktopLayout(
      activeStore: widget.activeStore,
      warningMessage: widget.warningMessage,
      orders: widget.orders,
      isLoading: widget.isLoading,
      onOrderSelected: widget.onOrderSelected,
    );
  }
}