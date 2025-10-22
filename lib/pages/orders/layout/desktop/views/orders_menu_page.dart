import 'package:flutter/material.dart';


class OrdersMenuPage extends StatelessWidget {
  const OrdersMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Cardápio',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gerenciador de produtos e categorias',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // ✅ Adicione seu conteúdo aqui
          ElevatedButton(
            onPressed: () {
              // Ação
            },
            child: const Text('Gerenciar Cardápio'),
          ),
        ],
      ),
    );
  }
}