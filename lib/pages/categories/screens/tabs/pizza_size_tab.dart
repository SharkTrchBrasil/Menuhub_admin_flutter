// lib/pages/categories/screens/tabs/pizza_sizes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/pizza_model.dart';
import 'package:totem_pro_admin/pages/categories/cubit/category_wizard_cubit.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/widgets/sizes_cards.dart'; // Seu PizzaSizeCard
import 'package:totem_pro_admin/pages/categories/screens/tabs/widgets/pizza_size_summary_card.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/widgets/tab_header.dart'; // O novo card de resumo

class PizzaSizesScreen extends StatelessWidget { // ✅ Mudamos para StatelessWidget
  const PizzaSizesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryWizardCubit, CategoryWizardState>(
      builder: (context, state) {
        final cubit = context.read<CategoryWizardCubit>();
        final pizzaSizes = state.pizzaSizes;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ✅ 2. SUBSTITUA O TEXTO ANTIGO PELO NOVO WIDGET
              const TabHeader(
                title: 'Tamanhos',
                subtitle: 'Indique aqui os tamanhos que suas pizzas são produzidas, em quantos pedaços são cortadas e até quantos sabores sua loja monta cada tamanho.',

              ),


              const SizedBox(height: 24),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pizzaSizes.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final size = pizzaSizes[index];
                  return PizzaSizeCard(
                    size: size,
                    onUpdate: cubit.updatePizzaSize,
                    onRemove: () => cubit.removePizzaSize(size.id),
                  );
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: cubit.addPizzaSize,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFEA1D2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Color(0xFFEBEBEB)),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Adicionar novo tamanho'),
              ),
              const SizedBox(height: 24),

            ],
          ),
        );
      },
    );
  }

}