// Em: lib/pages/categories/screens/tabs/option_groups_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/categories/cubit/category_wizard_cubit.dart';
import 'package:totem_pro_admin/models/option_group.dart';
import 'package:totem_pro_admin/models/option_item.dart';

import '../../../../core/enums/pricing_strategy.dart';

class OptionGroupsTab extends StatelessWidget {
  const OptionGroupsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos 'watch' aqui para que a tela inteira reconstrua se um grupo for adicionado/removido
    final cubit = context.watch<CategoryWizardCubit>();
    final state = cubit.state;
    final optionGroups = state.optionGroups;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (optionGroups.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48.0),
                  child: Text("Nenhum grupo de opções foi adicionado ainda."),
                ),
              ),

            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: optionGroups.length,
              itemBuilder: (context, index) {
                final group = optionGroups[index];
                return _OptionGroupCard(
                  key: ValueKey(group.localId),
                  group: group,
                  // ✅ Passamos a flag de precificação para o widget filho
                  priceVariesBySize: state.priceVariesBySize,
                );
              },
              onReorder: (oldIndex, newIndex) {
                cubit.reorderOptionGroups(oldIndex, newIndex);
              },
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: cubit.addOptionGroup,
              icon: const Icon(Icons.add),
              label: const Text("Adicionar novo grupo de opções"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget para exibir e editar um único OptionGroup
class _OptionGroupCard extends StatelessWidget {
  final OptionGroup group;
  final bool priceVariesBySize; // ✅ Recebe a flag

  const _OptionGroupCard({
    super.key,
    required this.group,
    required this.priceVariesBySize,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryWizardCubit>();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        key: PageStorageKey(group.localId),
        title: Text(group.name.isEmpty ? "Novo Grupo" : group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => cubit.removeOptionGroup(group.localId!),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0).copyWith(top: 0),
            child: Column(
              children: [
                TextFormField(
                  initialValue: group.name,
                  decoration: const InputDecoration(labelText: "Nome do Grupo"),
                  onChanged: (newName) {
                    cubit.updateOptionGroup(group.copyWith(name: newName));
                  },
                ),
                const SizedBox(height: 16),

                // ✅ SELETOR DE ESTRATÉGIA DE PREÇO ADICIONADO AQUI
                DropdownButtonFormField<PricingStrategy>(
                  value: group.pricingStrategy,
                  decoration: const InputDecoration(
                    labelText: "Como o preço deste grupo será calculado?",
                    border: OutlineInputBorder(),
                  ),
                  items: PricingStrategy.values.map((strategy) {
                    return DropdownMenuItem(
                      value: strategy,
                      child: Text(_getStrategyLabel(strategy)),
                    );
                  }).toList(),
                  onChanged: (newStrategy) {
                    if (newStrategy != null) {
                      cubit.updateGroupPricingStrategy(group.localId!, newStrategy);
                    }
                  },
                ),

                const Divider(height: 32),

                ...group.items.map((item) => _OptionItemRow(
                  key: ValueKey(item.localId),
                  item: item,
                  // ✅ Passa a flag para o widget filho
                  priceVariesBySize: priceVariesBySize,
                  onUpdate: (updatedItem) => cubit.updateOptionItem(group.localId!, updatedItem),
                  onRemove: () => cubit.removeOptionItem(group.localId!, item.localId!),
                )),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => cubit.addOptionItem(group.localId!),
                  icon: const Icon(Icons.add),
                  label: const Text("Adicionar opção"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }


  String _getStrategyLabel(PricingStrategy strategy) {
    switch (strategy) {
      case PricingStrategy.sumOfItems:
        return "Soma dos preços dos itens";
      case PricingStrategy.highestPrice:
        return "Preço do item mais caro";
      case PricingStrategy.lowestPrice:
        return "Preço do item mais barato";
    }
  }
}



// Widget para exibir e editar um único OptionItem
class _OptionItemRow extends StatelessWidget {
  final OptionItem item;
  final bool priceVariesBySize; // ✅ Recebe a flag
  final ValueChanged<OptionItem> onUpdate;
  final VoidCallback onRemove;

  const _OptionItemRow({
    super.key,
    required this.item,
    required this.priceVariesBySize,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: item.name,
              decoration: const InputDecoration(labelText: "Nome da Opção", isDense: true),
              onChanged: (newName) => onUpdate(item.copyWith(name: newName)),
            ),
          ),

          // ✅ LÓGICA CONDICIONAL AQUI!
          // O campo de preço só aparece se a flag for verdadeira para este grupo.
          if (!priceVariesBySize) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 100,
              child: TextFormField(
                initialValue: (item.price / 100).toStringAsFixed(2),
                decoration: const InputDecoration(labelText: "Preço", prefixText: "R\$ ", isDense: true),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (newPrice) {
                  final priceInCents = ((double.tryParse(newPrice.replaceAll(',', '.')) ?? 0) * 100).round();
                  onUpdate(item.copyWith(price: priceInCents));
                },
              ),
            ),
          ],

          IconButton(
            icon: const Icon(Icons.delete_forever, size: 20),
            onPressed: onRemove,
            color: Colors.grey.shade600,
          )
        ],
      ),
    );
  }
}