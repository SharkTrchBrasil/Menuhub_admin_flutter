import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:totem_pro_admin/models/option_group_template.dart';
import '../cubit/category_wizard_cubit.dart';

class CategoryTemplateSelectionScreen extends StatelessWidget {
  const CategoryTemplateSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryWizardCubit>();

    // Lista de templates disponíveis
    final templates = [
      _TemplateInfo(
        title: "Pizza",
        icon: Icons.local_pizza_outlined,
        color: const Color(0xFFF4511E),
        onTap: () => cubit.applyTemplate(CategoryTemplates.forPizza()),
      ),
      _TemplateInfo(
        title: "Açaí",
        icon: Icons.icecream_outlined,
        color: const Color(0xFF7B1FA2),
        onTap: () => cubit.applyTemplate(CategoryTemplates.forAcai()),
      ),
      _TemplateInfo(
        title: "Lanches",
        icon: Icons.lunch_dining_outlined,
        color: const Color(0xFFF57C00),
        onTap: () => cubit.applyTemplate(CategoryTemplates.forLanches()),
      ),
      _TemplateInfo(
        title: "Sushi",
        icon: Icons.restaurant_outlined,
        color: const Color(0xFFD32F2F),
        onTap: () => cubit.applyTemplate(CategoryTemplates.forSushi()),
      ),
      _TemplateInfo(
        title: "Saladas",
        icon: Icons.eco_outlined,
        color: const Color(0xFF388E3C),
        onTap: () => cubit.applyTemplate(CategoryTemplates.forSaladas()),
      ),
      _TemplateInfo(
        title: "Sobremesas",
        icon: Icons.cake_outlined,
        color: const Color(0xFF7B1FA2),
        onTap: () => cubit.applyTemplate(CategoryTemplates.forSobremesas()),
      ),
      _TemplateInfo(
        title: "Bebidas",
        icon: Icons.local_drink_outlined,
        color: const Color(0xFF0288D1),
        onTap: () => cubit.applyTemplate(CategoryTemplates.forBebidas()),
      ),
      _TemplateInfo(
        title: "Café da Manhã",
        icon: Icons.free_breakfast_outlined,
        color: const Color(0xFF5D4037),
        onTap: () => cubit.applyTemplate(CategoryTemplates.forCafeDaManha()),
      ),
      _TemplateInfo(
        title: "Marmitas",
        icon: Icons.set_meal_outlined,
        color: const Color(0xFFFFA000),
        onTap: () => cubit.applyTemplate(CategoryTemplates.forMarmitas()),
      ),
      _TemplateInfo(
        title: "Do Zero",
        icon: Icons.add_circle_outline,
        color: const Color(0xFF78909C),
        onTap: () => cubit.applyTemplate([]),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,


      body: LayoutBuilder(
        builder: (context, constraints) {
          // Layout responsivo baseado na largura da tela
          final crossAxisCount = constraints.maxWidth > 1000
              ? 5
              : constraints.maxWidth > 800
              ? 4
              : constraints.maxWidth > 600
              ? 3
              : 2;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              itemCount: templates.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1, // Quadrado perfeito
              ),
              itemBuilder: (BuildContext context, int index) {
                final template = templates[index];
                return _buildTemplateCard(
                  title: template.title,
                  icon: template.icon,
                  color: template.color,
                  onTap: template.onTap,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container circular para o ícone
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              // Texto com tamanho fixo e overflow controlado
              SizedBox(
                width: 80, // Largura fixa para controlar o texto
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Classe auxiliar para organizar os dados dos templates
class _TemplateInfo {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _TemplateInfo({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}