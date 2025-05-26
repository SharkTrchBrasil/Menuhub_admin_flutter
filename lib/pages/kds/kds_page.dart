import 'package:flutter/material.dart';


class OrderManagementScreen extends StatefulWidget {
  @override
  _OrderManagementScreenState createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Gestão de Pedidos"),




      ),

      body: Column(
        children: [
          TabBar(
            onTap: _onTabSelected,
            tabs: [
              Tab(text: 'Mesas'),
              Tab(text: 'Delivery'),
              Tab(text: 'Comandas'),
              Tab(text: 'KDS'),
            ],
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                _buildOrdersView('Mesas'),
                _buildOrdersView('Delivery'),
                _buildOrdersView('Comandas'),
                _buildKDSView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersView(String type) {
    return ListView.builder(
      itemCount: 10, // Exemplo de pedidos
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text('$type - Pedido ${index + 1}'),
            subtitle: Text('Status: Em preparo'),
            onTap: () {
              // Detalhes do pedido
            },
          ),
        );
      },
    );
  }

  Widget _buildKDSView() {
    return Center(
      child: Text('Tela de KDS - Exibindo pedidos em andamento na cozinha'),
    );
  }
}
