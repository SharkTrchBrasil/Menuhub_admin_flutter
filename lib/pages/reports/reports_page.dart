import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key, required this.storeId});
  final int storeId;
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Relatórios'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Vendas'),
              Tab(text: 'Pedidos'),
              Tab(text: 'Clientes'),
              Tab(text: 'Produtos'),
              Tab(text: 'Cupons'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SalesReportTab(),
            OrdersReportTab(),
            CustomersReportTab(),
            ProductsReportTab(),
            CouponsReportTab(),
          ],
        ),
      ),
    );
  }
}

// As abas estão separadas em widgets para modularidade
class SalesReportTab extends StatelessWidget {
  const SalesReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Relatório de Vendas'));
  }
}

class OrdersReportTab extends StatelessWidget {
  const OrdersReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Relatório de Pedidos'));
  }
}

class CustomersReportTab extends StatelessWidget {
  const CustomersReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Relatório de Clientes'));
  }
}

class ProductsReportTab extends StatelessWidget {
  const ProductsReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Relatório de Produtos'));
  }
}

class CouponsReportTab extends StatelessWidget {
  const CouponsReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Relatório de Cupons'));
  }
}