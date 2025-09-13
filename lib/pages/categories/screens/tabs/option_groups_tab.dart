// Em: lib/pages/categories/screens/tabs/option_group_content_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/enums/pricing_strategy.dart';
import 'package:totem_pro_admin/models/option_group.dart';
import 'package:totem_pro_admin/pages/categories/cubit/category_wizard_cubit.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/widgets/item_card_default.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/widgets/sizes_cards.dart';


import '../../../../core/enums/category_template_type.dart';
import '../../../../core/enums/option_group_type.dart';



class OptionGroupContentTab extends StatelessWidget {
  final OptionGroup group;
  const OptionGroupContentTab({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryWizardCubit>();
    final state = context.watch<CategoryWizardCubit>().state;

    final bool isSizeGroup = group.groupType == OptionGroupType.size;
    final bool isPizzaTemplate = state.selectedTemplate == CategoryTemplateType.pizza;
    final bool showPizzaSizeUI = isSizeGroup && isPizzaTemplate;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [




          if (group.items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48.0),
              child: Center(child: Text("Nenhuma opção adicionada. Clique no botão abaixo.")),
            ),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: group.items.length,
            itemBuilder: (context, index) {
              final item = group.items[index];
              if (showPizzaSizeUI) {
                return PizzaSizeItemCard(
                  key: ValueKey(item.localId),
                  item: item,
                  onUpdate: (updatedItem) => cubit.updateOptionItem(group.localId!, updatedItem),
                  onRemove: () => cubit.removeOptionItem(group.localId!, item.localId!),
                );
              } else {
                return DoughItemCard(
                  key: ValueKey(item.localId),
                  item: item,

                  onUpdate: (updatedItem) => cubit.updateOptionItem(group.localId!, updatedItem),
                  onRemove: () => cubit.removeOptionItem(group.localId!, item.localId!),
                );
              }
            },
          ),
          const SizedBox(height: 24),

          // ===================================================================
          // ✅ BLOCO 4: BOTÕES DE AÇÃO NO FINAL
          // ===================================================================
          ElevatedButton.icon(
            onPressed: () => cubit.addOptionItem(group.localId!),
            icon: const Icon(Icons.add),
            label: const Text("Adicionar Nova Opção"),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          if (group.isConfigurable) ...[
            const SizedBox(height: 16),
            Center(
              child: Wrap(
                spacing: 24,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => _showMobileSettingsDialog(context, cubit, group),
                    icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey,),
                    label: const Text("Editar Regras do Grupo", style: TextStyle(color: Colors.grey),),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => _showDeleteConfirmationDialog(context, cubit, group),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text("Apagar Grupo"),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class _GroupSettings extends StatelessWidget {
  final OptionGroup group;
  const _GroupSettings({required this.group});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryWizardCubit>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Regras do Grupo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextFormField(initialValue: group.minSelection.toString(), onChanged: (v) => cubit.updateOptionGroup(group.copyWith(minSelection: int.tryParse(v) ?? 0)), decoration: const InputDecoration(labelText: "Mínimo"))),
                const SizedBox(width: 16),
                Expanded(child: TextFormField(initialValue: group.maxSelection.toString(), onChanged: (v) => cubit.updateOptionGroup(group.copyWith(maxSelection: int.tryParse(v) ?? 1)), decoration: const InputDecoration(labelText: "Máximo"))),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PricingStrategy>(
              value: group.pricingStrategy,
              decoration: const InputDecoration(labelText: "Cálculo de Preço", border: OutlineInputBorder()),
              items: PricingStrategy.values.map((s) => DropdownMenuItem(value: s, child: Text(_getStrategyLabel(s)))).toList(),
              onChanged: (val) { if (val != null) cubit.updateGroupPricingStrategy(group.localId!, val); },
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemsList extends StatelessWidget {
  final OptionGroup group;
  final bool showPizzaSizeUI;
  const _ItemsList({required this.group, required this.showPizzaSizeUI});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryWizardCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (group.items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48.0),
            child: Center(child: Text("Nenhuma opção adicionada.")),
          ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: group.items.length,
          itemBuilder: (context, index) {
            final item = group.items[index];
            if (showPizzaSizeUI) {
              return PizzaSizeItemCard(
                key: ValueKey(item.localId),
                item: item,
                onUpdate: (updatedItem) => cubit.updateOptionItem(group.localId!, updatedItem),
                onRemove: () => cubit.removeOptionItem(group.localId!, item.localId!),
              );
            } else {
              return DoughItemCard(
                key: ValueKey(item.localId),
                item: item,
               // showPrice: group.groupType != OptionGroupType.size,
                onUpdate: (updatedItem) => cubit.updateOptionItem(group.localId!, updatedItem),
                onRemove: () => cubit.removeOptionItem(group.localId!, item.localId!),
              );
            }
          },
        ),
      ],
    );
  }


// =======================================================================
// DIÁLOGOS E FUNÇÕES AUXILIARES (extraídos da classe para maior clareza)

  // =======================================================================
  // DIÁLOGOS
  // =======================================================================

}


void _showRenameDialog(BuildContext context, CategoryWizardCubit cubit, OptionGroup group) {
  final TextEditingController controller = TextEditingController(text: group.name);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Renomear Grupo'),
      content: TextFormField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Nome do grupo',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              cubit.updateOptionGroup(group.copyWith(name: controller.text.trim()));
              Navigator.pop(context);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}

void _showMobileSettingsDialog(BuildContext context, CategoryWizardCubit cubit, OptionGroup group) {
  final minController = TextEditingController(text: group.minSelection.toString());
  final maxController = TextEditingController(text: group.maxSelection.toString());

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Configurações do Grupo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: minController,
              decoration: const InputDecoration(
                labelText: "Mínimo de Opções",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: maxController,
              decoration: const InputDecoration(
                labelText: "Máximo de Opções",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<PricingStrategy>(
              value: group.pricingStrategy,
              decoration: const InputDecoration(
                labelText: "Estratégia de Preço",
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            cubit.updateOptionGroup(group.copyWith(
              minSelection: int.tryParse(minController.text) ?? 0,
              maxSelection: int.tryParse(maxController.text) ?? 1,
            ));
            Navigator.pop(context);
          },
          child: const Text('Salvar'),
        ),
      ],
    ),
  );
}

void _showDeleteConfirmationDialog(BuildContext context, CategoryWizardCubit cubit, OptionGroup group) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Remover Grupo'),
      content: Text('Tem certeza que deseja remover o grupo "${group.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            cubit.removeOptionGroup(group.localId!);
            Navigator.pop(context);
          },
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Remover'),
        ),
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
