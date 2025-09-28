// lib/pages/orders/widgets/order_search_delegate.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/order_details.dart';
import 'package:totem_pro_admin/pages/orders/widgets/order_list_item.dart';

// ✅ CORREÇÃO 1: Adicione o '?' para indicar que o resultado pode ser nulo.
class OrderSearchDelegate extends SearchDelegate<OrderDetails?> {
  final List<OrderDetails> searchList;

  OrderSearchDelegate(this.searchList);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        // ✅ CORREÇÃO 2: Agora é permitido passar 'null' porque o tipo é OrderDetails?
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSuggestions(context);
  }

  Widget _buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? []
        : searchList.where((order) {
      final queryLower = query.toLowerCase();
      final customerNameLower = order.customerName?.toLowerCase() ?? '';
      final publicIdLower = order.publicId.toLowerCase();
      return customerNameLower.contains(queryLower) ||
          publicIdLower.contains(queryLower);
    }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final order = suggestionList[index];
        return OrderListItem(
          order: order,
          store: null,
          onTap: () {
            // ✅ CORREÇÃO 3: Passa o objeto 'order' selecionado.
            close(context, order);
          },
        );
      },
    );
  }
}