import 'package:flutter/material.dart';
import 'package:totem_pro_admin/pages/product_edit/widgets/variant_callbacks.dart';
import 'package:totem_pro_admin/pages/product_edit/widgets/variant_link_card.dart';

import '../../../models/variant_option.dart';
import '../../../widgets/ds_primary_button.dart';
import '../../variants/widgets/variant_option_tile.dart';


class VariantOptionsList extends StatelessWidget {
  final List<VariantOption> options;
  final VoidCallback onAddOption;
  final OnOptionUpdated onOptionUpdated;
  final OnOptionRemoved onOptionRemoved;

  const VariantOptionsList({super.key,
    required this.options,
    required this.onAddOption,
    required this.onOptionUpdated,
    required this.onOptionRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              DsButton(
                style: DsButtonStyle.secondary,

                label: "Adicionar",
                onPressed: onAddOption,
              ),
            ],
          ),



          const SizedBox(height: 16),
          if (options.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Center(child: Text("Nenhum complemento adicionado a este grupo.")),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return VariantOptionTile(
                  key: ValueKey(option.clientId),
                  index: index,
                  option: option,
                  onUpdate: onOptionUpdated,
                  onRemove: onOptionRemoved,
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 8),
            ),
        ],
      ),
    );
  }




}