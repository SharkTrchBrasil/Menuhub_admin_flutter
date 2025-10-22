// Arquivo: lib/pages/orders/views/orders_help_page.dart
import 'package:flutter/material.dart';


class OrdersHelpPage extends StatelessWidget {
  const OrdersHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.help_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Ajuda e Suporte',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Dúvidas frequentes e suporte técnico',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // ✅ Adicione seu conteúdo aqui
          ElevatedButton(
            onPressed: () {
              // Ação
            },
            child: const Text('Ver Ajuda'),
          ),
        ],
      ),
    );
  }
}