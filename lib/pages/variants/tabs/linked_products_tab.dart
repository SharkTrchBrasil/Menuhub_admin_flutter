import 'package:flutter/material.dart';

class LinkedProductsTab extends StatelessWidget {
  const LinkedProductsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Produtos vinculados',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF151515),
                ),
              ),
              // Botão de adicionar (pode ser implementado posteriormente)
              SizedBox(width: 120), // Espaço reservado
            ],
          ),

          SizedBox(height: 24),

          // Estado vazio
          _EmptyProductsState(),
        ],
      ),
    );
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.link_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum produto vinculado',
            style: TextStyle(
              color: Color(0xFF666666),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Os produtos que utilizam este grupo de complementos\naparecerão aqui automaticamente',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF8F8F8F),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          // Botão para vincular produtos (pode ser implementado posteriormente)
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar vinculação de produtos
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: const Color(0xFFEB0033),
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFEB0033)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Vincular produtos'),
          ),
        ],
      ),
    );
  }
}