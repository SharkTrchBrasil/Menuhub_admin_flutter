import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/pages/edit_settings/payment_methods/widgets/payment_method_config_dialog.dart';

class PaymentMethodTile extends StatelessWidget {
  final PlatformPaymentMethod method;
  final int storeId;

  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    final activation = method.activation;
    final bool isEnabled = activation?.isActive ?? false;

    // Usamos um Card para dar um bom visual e espaçamento
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: _buildPaymentIcon(method.iconKey),
        title: Text(method.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: isEnabled,
              onChanged: (newValue) {
                final updatedActivation = activation?.copyWith(isActive: newValue) ??
                    StorePaymentMethodActivation(
                      id: 0,
                      isActive: newValue,
                      feePercentage: 0,
                      isForDelivery: true,
                      isForPickup: true,
                      isForInStore: true,
                    );

                context.read<StoresManagerCubit>().updatePaymentMethodActivation(
                  storeId: storeId,
                  platformMethodId: method.id,
                  activation: updatedActivation,
                );
              },
            ),
            if (method.requiresDetails)
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Configurar ${method.name}',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => PaymentMethodConfigDialog(
                      method: method, // Passa o método de pagamento específico
                      storeId: storeId,   // E o ID da loja
                    ),
                  );

                },
              ),
          ],
        ),
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