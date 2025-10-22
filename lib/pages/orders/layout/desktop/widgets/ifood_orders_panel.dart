import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/order_details.dart';

import 'ifood_order_card.dart';


class IfoodOrdersPanel extends StatefulWidget {
  final List<OrderDetails> orders;
  final bool isLoading;
  final Function(OrderDetails) onOrderSelected;

  const IfoodOrdersPanel({
    super.key,
    required this.orders,
    required this.isLoading,
    required this.onOrderSelected,
  });

  @override
  State<IfoodOrdersPanel> createState() => _IfoodOrdersPanelState();
}

class _IfoodOrdersPanelState extends State<IfoodOrdersPanel>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Abas "Agora" e "Agendados"
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFEA1D2C),
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: const Color(0xFFEA1D2C),
              tabs: const [
                Tab(text: 'Agora'),
                Tab(text: 'Agendados'),
              ],
            ),
          ),

          // Controles: Aceite automático + Busca
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Aceite automático
                Expanded(
                  child: Row(
                    children: [
                      const Text(
                        'Aceite automático de pedidos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: true,
                        onChanged: (value) {},
                        activeColor: const Color(0xFFEA1D2C),
                      ),
                    ],
                  ),
                ),

                // Barra de busca
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Buscar pedido',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, size: 20),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Filtros
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text('Filtros'),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de pedidos
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab "Agora"
                _buildOrdersList(
                  widget.orders.where((o) => !o.isScheduled).toList(),
                ),

                // Tab "Agendados"
                _buildOrdersList(
                  widget.orders.where((o) => o.isScheduled).toList(),
                ),
              ],
            ),
          ),

          // Resumo de vendas
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resumo de Vendas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '0 pedidos concluídos',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(List<OrderDetails> orders) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orders.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum pedido encontrado',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return IfoodOrderCard(
          order: order,
          onTap: () => widget.onOrderSelected(order),
        );
      },
    );
  }
}