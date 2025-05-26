import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/models/variant.dart';

import 'package:totem_pro_admin/widgets/app_availability_dot.dart';

import '../../edit_variant/widgets/variant_option_list_item.dart';



class ProductVariantListItem extends StatelessWidget {
  const ProductVariantListItem({
    super.key,
    required this.variant,
    required this.storeId,

    required this.showUnpublished,
  });

  final int storeId;

  final Variant variant;
  final bool showUnpublished;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => context.go(
                '/stores/$storeId/variants/${variant.id}'),
            child: Container(
              color: Colors.blue.withAlpha(70),
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppAvailabilityDot(available: variant.available),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          variant.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (variant.description.isNotEmpty)
                          Text(
                            variant.description,
                            style: const TextStyle(
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Text(
                    'Selecione de ${variant.minQuantity} a ${variant.maxQuantity} - ${variant.repeatable ? 'Com repetição' : 'Sem repetição'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final o in variant.options!.where((o) => showUnpublished || o.available))
            VariantOptionListItem(
              option: o,
              storeId: storeId,

              variantId: variant.id!, onSaved: null,
            ),
        ],
      ),
    );
  }
}