import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/models/variant_option.dart';
import 'package:totem_pro_admin/widgets/app_availability_dot.dart';
import '../../../services/dialog_service.dart';

class VariantOptionListItem extends StatefulWidget {
  const VariantOptionListItem({
    super.key,
    required this.option,
    required this.storeId,
    required this.variantId,
    required this.onSaved,
  });

  final int storeId;
  final int variantId;
  final VariantOption option;
  final void Function()? onSaved;

  @override
  State<VariantOptionListItem> createState() => _VariantOptionListItemState();
}

class _VariantOptionListItemState extends State<VariantOptionListItem> {
  VariantOption get option => widget.option;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric( vertical: 8.0),
      child: InkWell(
        onTap: () async {
          await DialogService.showVariantsOptionsDialog(
            context,
            widget.storeId,
            widget.variantId,
            id: widget.option.id,
            onSaved: widget.onSaved,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppAvailabilityDot(available: option.available),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (option.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          option.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 24),

              option.isFree ?
              Text('Grátis', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w400), ) :
              Text(
                NumberFormat.simpleCurrency(locale: 'pt_BR')
                    .format((option.price ?? 0) / 100),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
