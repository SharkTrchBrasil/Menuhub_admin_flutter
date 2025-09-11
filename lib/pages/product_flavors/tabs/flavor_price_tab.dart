import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/category.dart';
import 'package:totem_pro_admin/models/product.dart';
import 'package:totem_pro_admin/models/prodcut_category_links.dart';

import '../../../models/flavor_price.dart';
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


        // ✅ LÓGICA CORRIGIDA: Encontra o FlavorPrice correspondente ao tamanho
        final flavorPrice = product.prices.firstWhere(
              (p) => p.sizeOptionId == sizeOption.id,
          // Fallback para o caso de algo dar errado (não deve acontecer com a lógica do Cubit)
          orElse: () => FlavorPrice(sizeOptionId: sizeOption.id!, price: 0),
        );





        return _PriceRow(
          sizeName: sizeOption.name,
          flavorPrice: flavorPrice,
          // O onUpdate agora passa o FlavorPrice atualizado
          onUpdate: (updatedPrice) {
            final updatedPrices = product.prices.map(
                    (p) => p.sizeOptionId == updatedPrice.sizeOptionId ? updatedPrice : p
            ).toList();
            onUpdate(product.copyWith(prices: updatedPrices));
          },
        );
      },
    );
  }
}

// Widget auxiliar para cada linha de preço
class _PriceRow extends StatelessWidget {
  final String sizeName;
  final FlavorPrice flavorPrice;
  final ValueChanged<FlavorPrice> onUpdate;

  const _PriceRow({required this.sizeName, required this.flavorPrice, required this.onUpdate});

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
                initialValue: (flavorPrice.price / 100).toStringAsFixed(2),
                decoration: const InputDecoration(labelText: 'Preço', prefixText: 'R\$ '),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  final doubleValue = double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
                  onUpdate(flavorPrice.copyWith(price: (doubleValue * 100).round()));
                },
              ),
            ),
            const SizedBox(width: 16),
            // TODO: Adicionar o Switch de status aqui
            Switch(value: flavorPrice.isAvailable, onChanged: (val){
              onUpdate(flavorPrice.copyWith(isAvailable: val));
            }),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: flavorPrice.posCode,
          decoration: const InputDecoration(labelText: 'Cód. PDV'),
          onChanged: (value) => onUpdate(flavorPrice.copyWith(posCode: value)),
        ),
      ],
    );
  }
}