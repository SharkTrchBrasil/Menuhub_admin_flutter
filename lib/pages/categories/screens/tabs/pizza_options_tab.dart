// lib/features/categories/screens/tabs/pizza_options_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/pizza_model.dart';
import 'package:totem_pro_admin/pages/categories/cubit/category_wizard_cubit.dart';

import '../../../../core/enums/pizzaoption.dart';



class PizzaOptionsTab extends StatelessWidget {
  final PizzaOptionType type;

  const PizzaOptionsTab({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryWizardCubit, CategoryWizardState>(
      builder: (context, state) {
        final cubit = context.read<CategoryWizardCubit>();

        final List<PizzaOption> options = type == PizzaOptionType.dough ? state.pizzaDoughs : state.pizzaEdges;

        // TODO: Lembre-se de criar os métodos para 'edge' no seu CUBIT
        final VoidCallback onAdd = type == PizzaOptionType.dough ? cubit.addPizzaDough : () {};
        final ValueChanged<PizzaOption> onUpdate = type == PizzaOptionType.dough ? cubit.updatePizzaDough : (_) {};

        // ✅ CORREÇÃO 1: A função reserva agora aceita um argumento não utilizado '_'
        final ValueChanged<String> onRemove = type == PizzaOptionType.dough ? cubit.removePizzaDough : (_) {};

        return ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            ...options.map((option) => _PizzaOptionCard(
              key: ValueKey(option.id),
              option: option,
              onUpdate: onUpdate,
              onRemove: () => onRemove(option.id),
            )),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(type == PizzaOptionType.dough ? "Adicionar nova massa" : "Adicionar nova borda"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Widget auxiliar para o card de cada opção (massa/borda)
class _PizzaOptionCard extends StatelessWidget {
  final PizzaOption option;
  final ValueChanged<PizzaOption> onUpdate;
  final VoidCallback onRemove;

  const _PizzaOptionCard({
    required this.option,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: option.name,
                decoration: const InputDecoration(labelText: 'Nome'),
                onChanged: (value) => onUpdate(option.copyWith(name: value)),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: TextFormField(
                // ✅ CORREÇÃO 2.1: Exibe o valor em reais (divide por 100)
                initialValue: (option.price / 100).toStringAsFixed(2),
                decoration: const InputDecoration(labelText: 'Preço (R\$)', prefixText: 'R\$ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  // ✅ CORREÇÃO 2.2: Salva o valor em centavos (multiplica por 100)
                  final doubleValue = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                  final intValueInCents = (doubleValue * 100).round();
                  onUpdate(option.copyWith(price: intValueInCents));
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}