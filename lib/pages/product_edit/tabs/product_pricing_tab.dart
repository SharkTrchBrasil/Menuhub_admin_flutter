import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';
import 'package:totem_pro_admin/models/prodcut_category_links.dart';
import 'package:totem_pro_admin/pages/product_edit/cubit/edit_product_cubit.dart';

class ProductPricingTab extends StatelessWidget {
  const ProductPricingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditProductCubit, EditProductState>(
      builder: (context, state) {
        final cubit = context.read<EditProductCubit>();
        final links = state.editedProduct.categoryLinks;

        if (links.isEmpty) {
          return const Center(child: Text("Este produto não está em nenhuma categoria."));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(24.0),
          itemCount: links.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final link = links[index];
            return _CategoryPriceRow(
              key: ValueKey(link.categoryId),
              link: link,
              onPriceChanged: (newPrice) => cubit.updatePriceInCategory(link, newPrice),
            );
          },
        );
      },
    );
  }
}

class _CategoryPriceRow extends StatelessWidget {
  final ProductCategoryLink link;
  final ValueChanged<int> onPriceChanged;

  const _CategoryPriceRow({super.key, required this.link, required this.onPriceChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(link.category?.name ?? 'Categoria desconhecida'),
        trailing: SizedBox(
          width: 120,
          child: TextFormField(
            initialValue: UtilBrasilFields.obterReal(link.price / 100),
            decoration: const InputDecoration(labelText: 'Preço', prefixText: 'R\$ '),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter()],
            onFieldSubmitted: (value) {
              final priceInCents = (UtilBrasilFields.converterMoedaParaDouble(value) * 100).toInt();
              onPriceChanged(priceInCents);
            },
          ),
        ),
      ),
    );
  }
}