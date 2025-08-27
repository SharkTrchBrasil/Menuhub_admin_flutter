// lib/pages/performance/tabs/orders_tab_view.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import '../widgets/orders_section.dart';

class OrdersTabView extends StatelessWidget {
  const OrdersTabView({super.key});

  @override
  Widget build(BuildContext context) {
    // Esta aba contém apenas a seção de pedidos.
    // O Padding garante um espaçamento consistente com as outras abas.
    return ListView(
      padding: EdgeInsets.symmetric(
        vertical: 24.0,

      ),
      children: const [
        OrdersSection(),
      ],
    );
  }
}