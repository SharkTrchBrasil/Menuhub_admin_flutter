import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brasil_fields/brasil_fields.dart'; // Para formatar o preço
import '../../../models/product.dart';
import '../cubit/bulk_category_cubit.dart';
import '../cubit/bulk_category_state.dart';


class Step2SetPrices extends StatelessWidget {
  const Step2SetPrices({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BulkAddToCategoryCubit, BulkAddToCategoryState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Text(
                "Defina preço e código PDV para cada produto",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            // Cabeçalho da Tabela
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              color: Colors.grey[100],
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text("Produto", style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text("Preço", style: TextStyle(fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text("Código PDV", style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            // Lista de Produtos
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: state.selectedProducts.length,
                itemBuilder: (context, index) {
                  final product = state.selectedProducts[index];
                  return _ProductPriceRow(key: ValueKey(product.id), product: product);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductPriceRow extends StatefulWidget {
  final Product product;
  const _ProductPriceRow({super.key, required this.product});

  @override
  State<_ProductPriceRow> createState() => _ProductPriceRowState();
}

class _ProductPriceRowState extends State<_ProductPriceRow> {
  late final TextEditingController _priceController;
  late final TextEditingController _pdvController;

  @override
  void initState() {
    super.initState();
    final cubitState = context.read<BulkAddToCategoryCubit>().state;
    final targetCategory = cubitState.targetCategory!;

    // Lógica para definir o preço inicial
    int initialPrice = widget.product.price ?? 0;
    String initialPdv = '';

    try {
      final existingLink = widget.product.categoryLinks.firstWhere(
            (link) => link.category?.id == targetCategory.id,
      );
      initialPrice = existingLink.price;
      initialPdv = existingLink.posCode ?? '';
    } catch (e) {
      // O produto não estava na categoria, usa o preço base
      initialPrice = widget.product.price ?? 0;
    }

    _priceController = TextEditingController(text: UtilBrasilFields.obterReal(initialPrice / 100));
    _pdvController = TextEditingController(text: initialPdv);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _pdvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BulkAddToCategoryCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Informações do produto
          Expanded(
            flex: 2,
            child: Text(widget.product.name, overflow: TextOverflow.ellipsis),
          ),
          // Campo de preço
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(border: OutlineInputBorder(), prefixText: "R\$ "),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, CentavosInputFormatter()],
              onChanged: (value) {
                final priceInCents = (UtilBrasilFields.converterMoedaParaDouble(value) * 100).toInt();
                cubit.updatePriceForProduct(widget.product.id!, priceInCents);
              },
            ),
          ),
          const SizedBox(width: 16),
          // Campo de código PDV
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: _pdvController,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "Cód."),
              onChanged: (value) => cubit.updatePosCodeForProduct(widget.product.id!, value),
            ),
          ),
        ],
      ),
    );
  }
}