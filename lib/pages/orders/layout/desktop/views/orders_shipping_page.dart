// Arquivo: lib/pages/orders/views/orders_shipping_page.dart
import 'package:flutter/material.dart';


class OrdersShippingPage extends StatelessWidget {
  const OrdersShippingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delivery_dining, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Expedição',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gerenciador de entregas e logística',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // ✅ Adicione seu conteúdo aqui
          ElevatedButton(
            onPressed: () {
              // Ação
            },
            child: const Text('Gerenciar Entregas'),
          ),
        ],
      ),
    );
  }
}