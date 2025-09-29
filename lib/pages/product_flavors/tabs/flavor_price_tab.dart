import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/models/category.dart';

import '../../../core/enums/option_group_type.dart';
import '../../../models/flavor_price.dart';
import '../../../models/option_group.dart';
import '../../product_groups/widgets/editable_complement_card.dart';
import '../cubit/flavor_wizard_cubit.dart';

class FlavorPriceTab extends StatelessWidget {


  const FlavorPriceTab({
    super.key,

  });

  @override
  Widget build(BuildContext context) {
    // ✅ O WIDGET AGORA LÊ DIRETAMENTE DO CUBIT
    return BlocBuilder<FlavorWizardCubit, FlavorWizardState>(
      buildWhen: (p, c) => p.product.prices != c.product.prices || p.parentCategory != c.parentCategory,
      builder: (context, state) {
        final cubit = context.read<FlavorWizardCubit>();

        final sizeGroup = state.parentCategory.optionGroups.firstWhere(
              (g) => g.groupType == OptionGroupType.size,
          orElse: () => const OptionGroup(name: 'Tamanho', items: []),
        );

        return ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: sizeGroup.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final sizeOption = sizeGroup.items[index];
            final flavorPrice = state.product.prices.firstWhere(
                  (p) => p.sizeOptionId == sizeOption.id,
              orElse: () => FlavorPrice(sizeOptionId: sizeOption.id!, price: 0),
            );

            return _PriceCard(
              sizeName: sizeOption.name,
              flavorPrice: flavorPrice,
              // ✅ O onUpdate AGORA CHAMA O MÉTODO ESPECÍFICO DO CUBIT
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
    _posCodeController = TextEditingController(
      text: widget.flavorPrice.posCode ?? '',
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _posCodeController.dispose();
    super.dispose();
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
            // Header da linha
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
                // Switch de disponibilidade
                Row(
                  children: [
                    Text(
                      widget.flavorPrice.isAvailable
                          ? 'Disponível'
                          : 'Indisponível',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            widget.flavorPrice.isAvailable
                                ? Colors.green
                                : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: widget.flavorPrice.isAvailable,
                      onChanged: (value) {
                        widget.onUpdate(
                          widget.flavorPrice.copyWith(isAvailable: value),
                        );
                      },

                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Campos de entrada
            Row(
              children: [
                // Campo de preço
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Preço',

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CentavosInputFormatter(),
                    ],
                    onChanged: (value) {
                      // ✅ CORREÇÃO APLICADA AQUI
                      // Se o campo estiver vazio, considera o preço como 0.
                      final priceInCents =
                          value.isEmpty
                              ? 0
                              : (UtilBrasilFields.converterMoedaParaDouble(
                                        value,
                                      ) *
                                      100)
                                  .toInt();

                      widget.onUpdate(
                        widget.flavorPrice.copyWith(price: priceInCents),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 16),

                // Campo de código PDV
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _posCodeController,
                    decoration: InputDecoration(
                      labelText: 'Cód. PDV',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged:
                        (value) => widget.onUpdate(
                          widget.flavorPrice.copyWith(posCode: value),
                        ),
                  ),
                ),
              ],
            ),

            // Indicador visual de status
            if (!widget.flavorPrice.isAvailable)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Este tamanho não está disponível para venda',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
