// Em: lib/pages/payment_methods/widgets/payment_method_item.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:totem_pro_admin/models/payment_method.dart';

class PaymentMethodItem extends StatelessWidget {
  final PlatformPaymentMethod method;
  final ValueChanged<bool> onChanged;

  const PaymentMethodItem({
    super.key,
    required this.method,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = method.activation?.isActive ?? false;
    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Checkbox(
            value: isEnabled,
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
            checkColor: Colors.white,
            fillColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.selected)) {
                return Theme.of(context).colorScheme.primary;
              }
              return Colors.white;
            }),
            side: MaterialStateBorderSide.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return BorderSide(color: Theme.of(context).colorScheme.primary);
              }
              return BorderSide(color: Colors.grey.shade400);
            }),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
          _buildPaymentIcon(method.iconKey),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              method.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentIcon(String? iconKey) {

    if (iconKey != null && iconKey.isNotEmpty) {
      final String assetPath = 'assets/icons/$iconKey';
      return SizedBox(
        width: 24,
        height: 24,
        child: SvgPicture.asset(
          assetPath,

          placeholderBuilder: (context) => Icon(Icons.credit_card, size: 24, ),
        ),
      );
    }
    return Icon(Icons.payment, size: 24);
  }
}