import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/enums/foodtags.dart';
import 'package:totem_pro_admin/models/product.dart';

import '../../../core/enums/beverage.dart';



class ProductAttributesSection extends StatelessWidget {
  final Product product;
  // ✅ 1. AGORA TEMOS DOIS CALLBACKS, UM PARA CADA TIPO DE TAG
  final ValueChanged<FoodTag> onDietaryTagToggled;
  final ValueChanged<BeverageTag> onBeverageTagToggled;

  final ValueChanged<int?> onServesUpToChanged;
  final ValueChanged<String> onWeightChanged;
  final ValueChanged<String> onUnitChanged;

  const ProductAttributesSection({
    super.key,
    required this.product,
    required this.onDietaryTagToggled, // ✅
    required this.onBeverageTagToggled, // ✅
    required this.onServesUpToChanged,
    required this.onWeightChanged,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ 2. CHAMADA PARA A SEÇÃO DE RESTRIÇÕES ALIMENTARES
        _buildTagsSection<FoodTag>(
          context: context,
          title: 'Restrições alimentares',
          subtitle: 'Informe se seu produto é adequado a restrições...',
          allTags: FoodTag.values,
          selectedTags: product.dietaryTags,
          tagNames: foodTagNames, // Seu mapa de nomes para FoodTag
          onToggled: onDietaryTagToggled,
        ),
        const SizedBox(height: 24),

        // ✅ 3. CHAMADA PARA A SEÇÃO DE BEBIDAS
        _buildTagsSection<BeverageTag>(
          context: context,
          title: 'Em caso de bebidas',
          subtitle: '', // Subtítulo opcional
          allTags: BeverageTag.values,
          selectedTags: product.beverageTags,
          tagNames: beverageTagNames, // Seu mapa de nomes para BeverageTag
          onToggled: onBeverageTagToggled,
        ),
        const SizedBox(height: 24),

        _buildItemSizeSection(context),
        const SizedBox(height: 24),
        _buildDisclaimerSection(context),
      ],
    );
  }

  // ✅ 4. NOVO MÉTODO AUXILIAR GENÉRICO E REUTILIZÁVEL
  Widget _buildTagsSection<T extends Enum>({
    required BuildContext context,
    required String title,
    String? subtitle,
    required List<T> allTags,
    required Set<T> selectedTags,
    required Map<T, String> tagNames,
    required ValueChanged<T> onToggled,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500)),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
        const SizedBox(height: 16),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: allTags.map((tag) {
            final isSelected = selectedTags.contains(tag);
            return FilterChip(
              label: Text(tagNames[tag]!),
              selected: isSelected,
              onSelected: (_) => onToggled(tag),
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
              elevation: 0,
            );
          }).toList(),
        ),
      ],
    );
  }








  // Seção de Tamanho do Item
  Widget _buildItemSizeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tamanho do item', style: Theme.of(context).textTheme.titleMedium),
        Text('Dê mais detalhes para que o cliente possa planejar a refeição', style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown "Serve até"
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<int?>(
                value: product.servesUpTo,
                hint: const Text('Não se aplica'),
                decoration: const InputDecoration(labelText: 'Serve até', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('Não se aplica')),
                  ...List.generate(10, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1} pessoa(s)'))),
                ],
                onChanged: onServesUpToChanged,
              ),
            ),
            const SizedBox(width: 16),
            // Campo "Peso"
            Expanded(
              flex: 1,
              child: TextFormField(
                initialValue: product.weight?.toString() ?? '',
                decoration: const InputDecoration(labelText: 'Peso', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: onWeightChanged,
              ),
            ),
            const SizedBox(width: 8),
            // Dropdown "Unidade"
            SizedBox(
              width: 80,
              child: DropdownButtonFormField<String>(
                value: product.unit.isNotEmpty ? product.unit : 'g',
                items: ['g', 'kg', 'ml', 'L'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                onChanged: (val) {
                  if (val != null) onUnitChanged(val);
                },
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Seção do aviso
  Widget _buildDisclaimerSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Lembre-se que você é responsável por todas as informações sobre os itens.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}