import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/enums/foodtags.dart';
import 'package:totem_pro_admin/models/product.dart';

class FlavorClassificationTab extends StatelessWidget {
  final Product product;
  final ValueChanged<Product> onUpdate;
  const FlavorClassificationTab({super.key, required this.product, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Classificação', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Indique se seu item é adequado a restrições alimentares.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: FoodTag.values.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final tag = FoodTag.values[index];
              return CheckboxListTile(
                title: Text(foodTagNames[tag]!),
                subtitle: Text(foodTagDescriptions[tag]!),

                // ✅ 1. CORREÇÃO: Lê da nova lista 'dietaryTags'
                value: product.dietaryTags.contains(tag),

                onChanged: (isSelected) {
                  // ✅ 2. CORREÇÃO: Cria a cópia a partir de 'dietaryTags'
                  final newTags = Set<FoodTag>.from(product.dietaryTags);
                  if (isSelected == true) {
                    newTags.add(tag);
                  } else {
                    newTags.remove(tag);
                  }

                  // ✅ 3. CORREÇÃO: Passa a nova lista para o parâmetro 'dietaryTags' do copyWith
                  onUpdate(product.copyWith(dietaryTags: newTags));
                },
              );
            },
          ),
        ],
      ),
    );
  }
}