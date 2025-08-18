// Em: lib/pages/payment_methods/widgets/payment_method_group_section.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
import 'payment_method_category_grid.dart';

class PaymentMethodGroupSection extends StatelessWidget {
  final PaymentMethodGroup group;
  final Function(PlatformPaymentMethod, bool) onActivationChanged;

  const PaymentMethodGroupSection({
    super.key,
    required this.group,
    required this.onActivationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
          child: Text(
            group.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        ...group.categories.map((category) {
          return PaymentMethodCategoryGrid(
            category: category,
            onActivationChanged: onActivationChanged,
          );
        }).toList(),
        const SizedBox(height: 25),
        Divider(height: 1, color: Colors.grey[200]),
      ],
    );
  }
}