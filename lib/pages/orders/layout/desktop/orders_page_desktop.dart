// [Arquivo: orders_page_desktop.dart]

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/models/order_details.dart';

// Importe as páginas que serão trocadas
import 'package:totem_pro_admin/pages/orders/layout/desktop/views/orders_list_page.dart';
import 'package:totem_pro_admin/pages/orders/layout/desktop/views/orders_shipping_page.dart';
import 'package:totem_pro_admin/pages/orders/layout/desktop/views/orders_menu_page.dart';
import 'package:totem_pro_admin/pages/orders/layout/desktop/views/orders_helper_page.dart';
import 'package:totem_pro_admin/pages/orders/layout/desktop/views/orders_settings_page.dart';

import 'widgets/ifood_header.dart';
import 'widgets/ifood_sidebar.dart';

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
  // ✅ Estado para controlar o índice selecionado
  int _selectedIndex = 0;

  // ✅ Lista de widgets (as "páginas" que serão trocadas)
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const OrdersListPage(),        // Índice 0
      OrdersShippingPage(),    // Índice 1
      const OrdersMenuPage(),        // Índice 2
      const OrdersHelpPage(),        // Índice 3
      const OrdersSettingsPage(),    // Índice 4
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header estilo iFood
          IfoodHeader(activeStore: widget.activeStore),

          // Conteúdo principal
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Sidebar de navegação por índice
                IfoodSidebar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),

                // ✅ Conteúdo Dinâmico baseado no índice
                Expanded(
                  flex: 10,
                  child: _pages[_selectedIndex],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}