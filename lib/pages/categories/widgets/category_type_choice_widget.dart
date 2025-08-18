import 'package:flutter/material.dart';

// Enum para o tipo, pode ser definido em um arquivo de modelos
enum CategoryType { mainItem, pizza }

class CategoryTypeChoiceWidget extends StatelessWidget {
  final Function(CategoryType) onTypeSelected;

  const CategoryTypeChoiceWidget({super.key, required this.onTypeSelected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nova categoria', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Selecione o modelo de categoria para dividir o seu cardápio', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 32),
              _buildChoiceCard(
                context: context,
                icon: Icons.fastfood,
                title: 'Itens principais',
                subtitle: 'Defina nome e descrição pra categorias de marmitas, lanches, etc.',
                onTap: () => onTypeSelected(CategoryType.mainItem),
              ),
              const SizedBox(height: 16),
              _buildChoiceCard(
                context: context,
                icon: Icons.local_pizza,
                title: 'Pizza',
                subtitle: 'Defina o tamanho, tipos de massa, bordas e sabores',
                onTap: () {
                  // Ação para o tipo Pizza
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Modelo de Pizza ainda não implementado.')),
                  );
                  // onTypeSelected(CategoryType.pizza); // Descomente quando for implementar
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para os cards de escolha
  Widget _buildChoiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}