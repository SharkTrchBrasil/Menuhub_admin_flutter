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

    // ✅ Usamos um Card para dar o visual da imagem de referência
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12), // Espaçamento entre os cards

      child: ListTile(
        leading: _buildPaymentIcon(method.iconKey),
        title: Text(method.name, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // O Switch para ativar/desativar
            Switch(
              value: isEnabled,
              onChanged: (newValue) {
                final currentActivation = activation ?? StorePaymentMethodActivation.empty();
                final updatedActivation = currentActivation.copyWith(isActive: newValue);

                context.read<StoresManagerCubit>().updatePaymentMethodActivation(
                  storeId: storeId,
                  platformMethodId: method.id,
                  activation: updatedActivation,
                );
              },
            ),
            // O botão de configurações (os três pontinhos da imagem)
            if (method.requiresDetails)
              IconButton(
                icon: const Icon(Icons.more_vert), // Ícone de três pontinhos
                tooltip: 'Configurar ${method.name}',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => PaymentMethodConfigDialog(
                      method: method,
                      storeId: storeId,
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
        width: 32, // Um pouco maior para destaque
        height: 32,
        child: SvgPicture.asset(
          assetPath,
          placeholderBuilder: (context) => const Icon(Icons.credit_card, size: 24),
        ),
      );
    }
    return const Icon(Icons.payment, size: 24);
  }
}