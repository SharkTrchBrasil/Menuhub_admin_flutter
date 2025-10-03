import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/pages/edit_settings/payment_methods/widgets/payment_method_tile.dart';

class PaymentGroupView extends StatelessWidget {
  final PaymentMethodGroup group;
  final int storeId;

  const PaymentGroupView({super.key, required this.group, required this.storeId});

  @override
  Widget build(BuildContext context) {
    // Usamos apenas um Column para criar a seção, sem Card externo.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho da seção (ex: "Cartões de Crédito")
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              group.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          // Lista de métodos de pagamento dentro da seção
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero, // Removemos o padding da lista interna
            itemCount: group.methods.length,
            itemBuilder: (context, index) {
              final method = group.methods[index];
              return PaymentMethodTile(
                method: method,
                storeId: storeId,
              );
            },
          ),
        ],
      ),
    );
  }
}