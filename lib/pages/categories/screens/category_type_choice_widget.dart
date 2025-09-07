// lib/features/categories/screens/category_type_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/category_type.dart';
import '../cubit/category_wizard_cubit.dart';

class CategoryTypeSelectionScreen extends StatelessWidget {
  const CategoryTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
 return
      Center(
      child: SingleChildScrollView(
        // ConstrainedBox limita a largura máxima do conteúdo, criando o efeito de "container" no desktop
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selecione o modelo de categoria para dividir o seu cardápio",
                // Estilo um pouco maior para o título
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),

              // ✨ LayoutBuilder verifica a largura disponível para decidir o layout
              LayoutBuilder(
                builder: (context, constraints) {
                  // Se houver mais de 600px de largura, usamos o layout de linha (desktop)
                  if (constraints.maxWidth > 600) {
                    return IntrinsicHeight( // Garante que ambos os cards tenham a mesma altura
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: _buildCards(context, isRow: true),
                      ),
                    );
                  }
                  // Senão, usamos o layout de coluna (mobile)
                  return Column(
                    children: _buildCards(context, isRow: false),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✨ Nova função auxiliar para construir e organizar os cards
  List<Widget> _buildCards(BuildContext context, {required bool isRow}) {
    final cardGeneral = _buildCategoryCard(
      title: "Itens principais",
      subtitle: "Para categorias de marmitas, lanches, sobremesas, etc.",
      onTap: () => context.read<CategoryWizardCubit>().selectCategoryType(CategoryType.GENERAL),
      iconData: Icons.fastfood_outlined, // Ícone sugerido
    );

    final cardCustomizable = _buildCategoryCard(
      title: "Categoria Customizável",
      subtitle: "Para itens montáveis como pizzas, açaís e pastéis.",
      onTap: () => context.read<CategoryWizardCubit>().selectCategoryType(CategoryType.CUSTOMIZABLE),
      iconData: Icons.local_pizza_outlined, // Ícone sugerido
    );

    // Se o layout for de linha, envolvemos os cards com Expanded para dividir o espaço
    if (isRow) {
      return [
        Expanded(child: cardGeneral),
        const SizedBox(width: 24),
        Expanded(child: cardCustomizable),
      ];
    }

    // Se for de coluna, apenas adicionamos um espaço entre eles
    return [
      cardGeneral,
      const SizedBox(height: 16),
      cardCustomizable,
    ];
  }

  // O seu método _buildCategoryCard com pequenas melhorias de estilo
  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required IconData iconData,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias, // Garante que o InkWell respeite as bordas
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(iconData, size: 40, color: Colors.red.shade700),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey.shade700, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}




