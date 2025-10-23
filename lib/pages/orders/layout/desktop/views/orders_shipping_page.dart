// lib/pages/orders/orders_shipping_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../models/order_details.dart';
import '../../../cubit/order_page_cubit.dart';
import '../../../cubit/order_page_state.dart';
import '../widgets/order_kanban_column.dart';


class OrdersShippingPage extends StatefulWidget {
  @override
  _OrdersShippingPageState createState() => _OrdersShippingPageState();
}

class _OrdersShippingPageState extends State<OrdersShippingPage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
             
                borderRadius: BorderRadius.circular(8),

              ),
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar por número, cliente ou endereço',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: 8),
                      ),
                      style: TextStyle(fontSize: 14),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16),

          // Botão de Filtro
          _buildHeaderButton(
            icon: Icons.filter_list,
            tooltip: 'Filtros',
            onPressed: () {
              // TODO: Abrir sheet de filtros
            },
          ),
          SizedBox(width: 16),

          // Botão de Atualizar
          _buildHeaderButton(
            icon: Icons.refresh,
            tooltip: 'Atualizar',
            onPressed: () {
              context.read<OrderCubit>().refreshOrders(); // ✅ Agora funciona
            },
          ),
          SizedBox(width: 16),

          // Status da Conexão
          BlocBuilder<OrderCubit, OrderState>(
            builder: (context, state) {
              if (state is OrdersLoaded) {
                return Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: state.isConnected ? Colors.green[50] : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: state.isConnected ? Colors.green[300]! : Colors.red[300]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: state.isConnected ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        state.isConnected ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: state.isConnected ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return SizedBox();
            },
          ),
          SizedBox(width: 16),

          // Botão de Tela Cheia
          _buildHeaderButton(
            icon: Icons.fullscreen,
            tooltip: 'Tela cheia',
            onPressed: () {
              // TODO: Implementar tela cheia
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
          ),
        ),
        child: IconButton(
          icon: Icon(icon, size: 20),
          color: Colors.grey[700],
          onPressed: onPressed,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        if (state is OrdersLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Carregando pedidos...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        if (state is OrdersError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                SizedBox(height: 16),
                Text(
                  'Erro ao carregar pedidos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.read<OrderCubit>().refreshOrders(),
                  icon: Icon(Icons.refresh),
                  label: Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        if (state is OrdersEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'Nenhum pedido encontrado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  state.message,
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (state is OrdersLoaded) {
          // Filtra pedidos por busca
          final filteredOrders = _filterOrders(state.filteredOrders); // ✅ Agora funciona

          // Separa pedidos por status para o Kanban
          final preparingOrders = filteredOrders
              .where((o) => ['pending', 'confirmed', 'preparing'].contains(o.orderStatus))
              .toList();

          final readyOrders = filteredOrders
              .where((o) => o.orderStatus == 'ready')
              .toList();

          final inTransitOrders = filteredOrders
              .where((o) => o.orderStatus == 'in_transit')
              .toList();

          final completedOrders = filteredOrders
              .where((o) => ['delivered', 'completed'].contains(o.orderStatus))
              .toList();

          return Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Coluna: Em Preparo
                Expanded(
                  flex: 2,
                  child: OrderKanbanColumn(
                    title: 'Em preparo',
                    orders: preparingOrders,
                    emptyIcon: Icons.cookie_outlined,
                    emptyDescription:
                    'Aproveite o momento de tranquilidade para aprender mais sobre o Painel de Expedição',
                    onOrderTap: _openOrderDetails,
                  ),
                ),
                SizedBox(width: 16),

                // Divider Vertical
                Container(
                  width: 1,
                  height: double.infinity,
                  color: Colors.grey[300],
                ),
                SizedBox(width: 16),

                // Colunas: Pronto, Em Rota, Finalizados
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      Expanded(
                        child: OrderKanbanColumn(
                          title: 'Pronto',
                          orders: readyOrders,
                          emptyIcon: Icons.shopping_bag_outlined,
                          emptyDescription: 'Aqui ficarão seus pedidos prontos para coleta',
                          onOrderTap: _openOrderDetails,
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: OrderKanbanColumn(
                          title: 'Em rota',
                          orders: inTransitOrders,
                          emptyIcon: Icons.delivery_dining,
                          emptyDescription: 'Aqui ficarão seus pedidos a caminho dos seus clientes',
                          onOrderTap: _openOrderDetails,
                        ),
                      ),
                      SizedBox(height: 16),
                      Expanded(
                        child: OrderKanbanColumn(
                          title: 'Finalizados',
                          orders: completedOrders,
                          emptyIcon: Icons.check_circle_outline,
                          emptyDescription: 'Aqui ficarão seus pedidos entregues e finalizados',
                          onOrderTap: _openOrderDetails,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Center(
          child: Text('Estado desconhecido'),
        );
      },
    );
  }

  List<OrderDetails> _filterOrders(List<OrderDetails> orders) {
    if (_searchQuery.isEmpty) {
      return orders;
    }

    final query = _searchQuery.toLowerCase();
    return orders.where((order) {
      return order.sequentialId.toString().contains(query) ||
          (order.customerName?.toLowerCase().contains(query) ?? false) ||
          (order.customerPhone?.contains(query) ?? false) ||
          order.street.toLowerCase().contains(query) ||
          order.neighborhood.toLowerCase().contains(query);
    }).toList();
  }

  void _openOrderDetails(OrderDetails order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pedido #${order.sequentialId}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Cliente: ${order.customerName ?? "Não informado"}'),
              SizedBox(height: 8),
              Text('Telefone: ${order.customerPhone ?? "Não informado"}'),
              SizedBox(height: 8),
              Text('Status: ${order.orderStatus}'),
              SizedBox(height: 8),
              Text('Tipo: ${order.deliveryType}'),
              SizedBox(height: 8),
              Text('Total: R\$ ${(order.totalPrice / 100).toStringAsFixed(2)}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fechar'),
          ),
        ],
      ),
    );
  }
}