import 'package:flutter/material.dart';


class OrdersSettingsPage extends StatelessWidget {
  const OrdersSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Configurações',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Personalize sua experiência',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          // ✅ Adicione seu conteúdo aqui
          ElevatedButton(
            onPressed: () {
              // Ação
            },
            child: const Text('Abrir Configurações'),
          ),
        ],
      ),
    );
  }
}