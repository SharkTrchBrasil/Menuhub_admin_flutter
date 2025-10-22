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
import 'widgets/ifood_sidebar.dart'; // Importe seu sidebar modificado (código abaixo)

// 1. Converta para StatefulWidget
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
  // 2. Adicione o estado para controlar o índice selecionado
  int _selectedIndex = 0;

  // 3. Crie a lista de widgets (as "páginas" que serão trocadas)
  //    Note que estamos passando os dados necessários para a OrdersListPage.
  //    As outras páginas (Shipping, Menu, etc.) são dos seus arquivos.
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Inicialize a lista de páginas aqui para poder usar os 'widgets'
    _pages = [
      // Índice 0: Pedidos (o layout de duas colunas)
      OrdersListPage(), //

      // Índice 1: Expedição
      const OrdersShippingPage(), //

      // Índice 2: Cardápio
      const OrdersMenuPage(), //

      // Índice 3: Ajuda
      const OrdersHelpPage(), //

      // Índice 4: Configurações
      const OrdersSettingsPage(), //
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
                // 4. Sidebar de navegação
                //    Passe o índice selecionado e um callback para atualizar o estado
                IfoodSidebar(
                  selectedIndex: _selectedIndex,
                  onItemTapped: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                ),

                // 5. Conteúdo Dinâmico
                //    Substitua os painéis fixos pelo widget da lista _pages
                //    com base no _selectedIndex
                Expanded(
                  // Use uma flex grande para ocupar o resto do espaço
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