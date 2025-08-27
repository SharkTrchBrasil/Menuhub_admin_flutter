// lib/pages/performance/widgets/orders_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../ConstData/typography.dart';
import '../../../models/order_details.dart';
import '../cubit/performance_cubit.dart';

class OrdersSection extends StatefulWidget {
  const OrdersSection({super.key});

  @override
  State<OrdersSection> createState() => _OrdersSectionState();
}

class _OrdersSectionState extends State<OrdersSection> {
  final _searchController = TextEditingController();
  String? _selectedStatus;

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ O widget agora é apenas uma Column. O Card ou Padding fica no widget pai (a aba).
    return BlocBuilder<PerformanceCubit, PerformanceState>(
      // Reconstrói apenas quando a lista de pedidos ou o estado de loading mudam
      buildWhen: (prev, curr) {
        if (prev is! PerformanceLoaded || curr is! PerformanceLoaded) return true;
        return prev.orders != curr.orders || prev.isLoadingOrders != curr.isLoadingOrders;
      },
      builder: (context, state) {
        if (state is! PerformanceLoaded) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pedidos no Período",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildOrderFilters(state),
            const SizedBox(height: 16),
            _buildOrdersTable(state),
            const SizedBox(height: 16),
            _buildPaginationControls(state),
          ],
        );
      },
    );
  }

  Widget _buildOrderFilters(PerformanceLoaded state) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por cliente ou ID...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onSubmitted: (value) {
              context.read<PerformanceCubit>().fetchOrders(
                search: value,
                status: _selectedStatus,
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: _selectedStatus,
          hint: const Text('Status'),
          items: ['pending', 'preparing', 'delivered', 'canceled']
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (value) {
            setState(() => _selectedStatus = value);
            context.read<PerformanceCubit>().fetchOrders(
              search: _searchController.text,
              status: value,
            );
          },
        ),
      ],
    );
  }

  Widget _buildOrdersTable(PerformanceLoaded state) {
    if (state.isLoadingOrders) {
      return const Center(heightFactor: 5, child: CircularProgressIndicator());
    }
    if (state.orders.isEmpty) {
      return const Center(heightFactor: 5, child: Text("Nenhum pedido encontrado."));
    }
    // Para evitar overflow em telas estreitas, a DataTable deve ser rolável horizontalmente
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Pedido')),
          DataColumn(label: Text('Cliente')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Valor')),
        ],
        rows: state.orders
            .map((order) => DataRow(cells: [
          DataCell(Text('#${order.publicId}')),
          DataCell(Text(order.customerName ?? 'N/A')),
          DataCell(Text(order.orderStatus)),
          DataCell(Text(_formatCurrency(order.totalPrice / 100.0))),
        ]))
            .toList(),
      ),
    );
  }

  Widget _buildPaginationControls(PerformanceLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: state.currentPage > 1
              ? () {
            context.read<PerformanceCubit>().fetchOrders(
              page: state.currentPage - 1,
              search: _searchController.text,
              status: _selectedStatus,
            );
          }
              : null,
        ),
        Text('Página ${state.currentPage} de ${state.totalPages}'),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: state.currentPage < state.totalPages
              ? () {
            context.read<PerformanceCubit>().fetchOrders(
              page: state.currentPage + 1,
              search: _searchController.text,
              status: _selectedStatus,
            );
          }
              : null,
        ),
      ],
    );
  }
}