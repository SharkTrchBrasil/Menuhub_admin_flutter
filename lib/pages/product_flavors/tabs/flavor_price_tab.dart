import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/flavor_price.dart';


import '../../product-wizard/cubit/product_wizard_cubit.dart';
import '../../product-wizard/cubit/product_wizard_state.dart';

class FlavorPriceTab extends StatelessWidget {
  const FlavorPriceTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductWizardCubit, ProductWizardState>(
      buildWhen: (p, c) => p.productInCreation.prices != c.productInCreation.prices || p.priceVariationGroup != c.priceVariationGroup,
      builder: (context, state) {
        final cubit = context.read<ProductWizardCubit>();
        final priceVariationGroup = state.priceVariationGroup;

        if (priceVariationGroup == null || priceVariationGroup.items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Nenhum grupo de variação de preço (como "Tamanho") foi configurado para esta categoria.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade700),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: priceVariationGroup.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final option = priceVariationGroup.items[index];
            final flavorPrice = state.productInCreation.prices.firstWhere(
                  (p) => p.sizeOptionId == option.id,
              orElse: () => FlavorPrice(sizeOptionId: option.id!, price: 0),
            );

            return _PriceCard(
              sizeName: option.name,
              flavorPrice: flavorPrice,
              onUpdate: cubit.updateFlavorPrice,
            );
          },
        );
      },
    );
  }
}

class _PriceCard extends StatefulWidget {
  final String sizeName;
  final FlavorPrice flavorPrice;
  final ValueChanged<FlavorPrice> onUpdate;

  const _PriceCard({
    required this.sizeName,
    required this.flavorPrice,
    required this.onUpdate,
  });

  @override
  State<_PriceCard> createState() => _PriceCardState();
}

class _PriceCardState extends State<_PriceCard> {
  late TextEditingController _priceController;
  late TextEditingController _posCodeController;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: (widget.flavorPrice.price / 100).toStringAsFixed(2),
    );
    _posCodeController = TextEditingController(text: widget.flavorPrice.posCode ?? '');
  }

  @override
  void dispose() {
    _priceController.dispose();
    _posCodeController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _PriceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flavorPrice.price != oldWidget.flavorPrice.price) {
      final text = (widget.flavorPrice.price / 100).toStringAsFixed(2);
      _priceController.value = _priceController.value.copyWith(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    if (widget.flavorPrice.posCode != oldWidget.flavorPrice.posCode) {
      _posCodeController.text = widget.flavorPrice.posCode ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.sizeName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      widget.flavorPrice.isAvailable ? 'Disponível' : 'Indisponível',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: widget.flavorPrice.isAvailable ? Colors.green : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: widget.flavorPrice.isAvailable,
                      onChanged: (value) {
                        widget.onUpdate(widget.flavorPrice.copyWith(isAvailable: value));
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Preço',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CentavosInputFormatter(),
                    ],
                    onChanged: (value) {
                      final priceInCents = (UtilBrasilFields.converterMoedaParaDouble(value) * 100).toInt();
                      widget.onUpdate(widget.flavorPrice.copyWith(price: priceInCents));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _posCodeController,
                    decoration: InputDecoration(
                      labelText: 'Cód. PDV',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) => widget.onUpdate(widget.flavorPrice.copyWith(posCode: value)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}