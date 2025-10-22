import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/pages/orders/layout/desktop/widgets/ifood_dashboard_panel.dart';
import 'package:totem_pro_admin/pages/orders/layout/desktop/widgets/ifood_header.dart';
import 'package:totem_pro_admin/pages/orders/layout/desktop/widgets/ifood_orders_panel.dart';
import 'package:totem_pro_admin/pages/orders/layout/desktop/widgets/ifood_sidebar.dart';

import '../../../../models/order_details.dart';


class IfoodDesktopLayout extends StatelessWidget {
  final Store? activeStore;
  final String? warningMessage;
  final List<OrderDetails> orders;
  final bool isLoading;
  final Function(OrderDetails) onOrderSelected;

  const IfoodDesktopLayout({
    super.key,
    required this.activeStore,
    this.warningMessage,
    required this.orders,
    required this.isLoading,
    required this.onOrderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header estilo iFood
          IfoodHeader(activeStore: activeStore),

          // Conteúdo principal
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar de navegação
                const IfoodSidebar(),

                // Painel de pedidos (esquerda)
                Expanded(
                  flex: 4,
                  child: IfoodOrdersPanel(
                    orders: orders,
                    isLoading: isLoading,
                    onOrderSelected: onOrderSelected,
                  ),
                ),

                // Painel do dashboard (direita)
                Expanded(
                  flex: 6,
                  child: IfoodDashboardPanel(
                    activeStore: activeStore,
                    orders: orders,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}