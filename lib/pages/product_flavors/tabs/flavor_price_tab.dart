import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/prodcut_category_links.dart';

import '../../../models/option_group.dart';

class FlavorPriceTab extends StatelessWidget {
  final Product product;
  final Category parentCategory;
  final ValueChanged<Product> onUpdate;

  const FlavorPriceTab({super.key, required this.product, required this.parentCategory, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    // Encontra o grupo de opções de "Tamanho" na categoria pai
    final sizeGroup = parentCategory.optionGroups.firstWhere((g) => g.name == 'Tamanho', orElse: () => OptionGroup(name: 'Tamanho', items: [], minSelection: 0, maxSelection: 0));

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: sizeGroup.items.length,
      separatorBuilder: (_, __) => const Divider(height: 32),
      itemBuilder: (context, index) {
        // Dentro do itemBuilder do ListView
        final sizeOption = sizeGroup.items[index];

// Encontra o link de preço correspondente ao tamanho específico
        final priceLink = product.categoryLinks.firstWhere(
              (link) => link.optionItemId == sizeOption.id, // ✅ CORREÇÃO APLICADA AQUI
          orElse: () => ProductCategoryLink(
              categoryId: parentCategory.id!,
              optionItemId: sizeOption.id, // Garanta que o fallback também tenha o id
              price: 0,
              product: product,
              category: parentCategory),
        );


        return _PriceRow(
          sizeName: sizeOption.name,
          priceLink: priceLink,
          // Dentro do widget _PriceRow, no callback onUpdate
          onUpdate: (updatedLink) {
            final updatedLinks = product.categoryLinks.map(
                    (link) => link.optionItemId == updatedLink.optionItemId // ✅ CORREÇÃO APLICADA AQUI
                    ? updatedLink
                    : link
            ).toList();
            onUpdate(product.copyWith(categoryLinks: updatedLinks));
          },
        );
      },
    );
  }
}

// Widget auxiliar para cada linha de preço
class _PriceRow extends StatelessWidget {
  final String sizeName;
  final ProductCategoryLink priceLink;
  final ValueChanged<ProductCategoryLink> onUpdate;

  const _PriceRow({required this.sizeName, required this.priceLink, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(sizeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            SizedBox(
              width: 120,
              child: TextFormField(
                initialValue: (priceLink.price / 100).toStringAsFixed(2),
                decoration: const InputDecoration(labelText: 'Preço', prefixText: 'R\$ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  final doubleValue = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                  onUpdate(priceLink.copyWith(price: (doubleValue * 100).round()));
                },
              ),
            ),
            const SizedBox(width: 16),
            // TODO: Adicionar o Switch de status aqui
            Switch(value: priceLink.isAvailable, onChanged: (val){
              onUpdate(priceLink.copyWith(isAvailable: val));
            }),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: priceLink.posCode,
          decoration: const InputDecoration(labelText: 'Cód. PDV'),
          onChanged: (value) => onUpdate(priceLink.copyWith(posCode: value)),
        ),
      ],
    );
  }
}