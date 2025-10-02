import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/payment_method.dart';
import 'package:totem_pro_admin/pages/edit_settings/payment_methods/widgets/payment_method_tile.dart';

class PaymentGroupView extends StatelessWidget {
  final PaymentMethodGroup group;
  final int storeId;

  const PaymentGroupView({super.key, required this.group, required this.storeId});

  @override
  Widget build(BuildContext context) {
    // ✅ ================== LAYOUT SIMPLIFICADO SEM ABAS ==================
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título e descrição do grupo
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 38),
              Text(
                group.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                group.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Lista de métodos
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: group.methods.length,
            itemBuilder: (context, index) {
              final method = group.methods[index];
              return PaymentMethodTile(
                method: method,
                storeId: storeId,
              );
            },
          ),
        ),
      ],
    );
    // ================== FIM DA CORREÇÃO ==================
  }
}