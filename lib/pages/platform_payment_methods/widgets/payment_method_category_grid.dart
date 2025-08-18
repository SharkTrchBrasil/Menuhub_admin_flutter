// Em: lib/pages/payment_methods/widgets/payment_method_category_grid.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
import 'payment_method_item.dart';

class PaymentMethodCategoryGrid extends StatelessWidget {
  final PaymentMethodCategory category;
  final Function(PlatformPaymentMethod, bool) onActivationChanged;

  const PaymentMethodCategoryGrid({
    super.key,
    required this.category,
    required this.onActivationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0, top: 30.0),
          child: Text(
            category.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 800 ? 3 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: category.methods.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio:16,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final method = category.methods[index];
                return PaymentMethodItem(
                  method: method,
                  onChanged: (newValue) => onActivationChanged(method, newValue),
                );
              },
            );
          },
        ),
      ],
    );
  }
}