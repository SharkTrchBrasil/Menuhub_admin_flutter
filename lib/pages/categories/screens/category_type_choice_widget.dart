// lib/features/categories/screens/category_type_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/category_type.dart';
import '../cubit/category_wizard_cubit.dart';

class CategoryTypeSelectionScreen extends StatelessWidget {
  const CategoryTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 48),

            // Cards de opções
            _buildOptionCard(
              context: context,
              title: "Itens Principais",
              subtitle: "Pratos principais, lanches, sobremesas e bebidas. Ideal para cardápios tradicionais.",
              icon: Icons.restaurant_menu_rounded,
              categoryType: CategoryType.GENERAL,
              color: Colors.blue.shade700,
            ),
            const SizedBox(height: 20),
            _buildOptionCard(
              context: context,
              title: "Customizável",
              subtitle: "Itens montáveis como pizzas, açaís e pastéis. Permite personalização do cliente.",
              icon: Icons.tune_rounded,
              categoryType: CategoryType.CUSTOMIZABLE,
              color: Colors.green.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Criar Nova Categoria",
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 28,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Escolha o tipo de categoria que melhor se adapta aos seus produtos",
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey.shade600,
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required CategoryType categoryType,
    required Color color,
  }) {
    final cubit = context.watch<CategoryWizardCubit>();
    final isSelected = cubit.state.categoryType == categoryType;

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      elevation: isSelected ? 4 : 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: InkWell(
        onTap: () => cubit.selectCategoryType(categoryType),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            gradient: isSelected
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.05),
                color.withOpacity(0.02),
              ],
            )
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone com background
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.1) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? color : Colors.grey.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),

              // Conteúdo textual
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : Colors.black87,
                        )
                    ),
                    const SizedBox(height: 8),
                    Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          height: 1.5,
                          fontSize: 14,
                        )
                    ),
                  ],
                ),
              ),

              // Indicador de seleção sutil
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: color,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}