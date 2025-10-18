import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/models/subscription/subscription.dart';


class SubscriptionStatusCard extends StatelessWidget {
  final Subscription subscription;
  final int storeId;

  const SubscriptionStatusCard({
    super.key,
    required this.subscription,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    // Só exibe o card se o status for de aviso (warning)
    if (subscription.status != 'warning') {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.amber.shade50,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.amber.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                subscription.warningMessage ?? 'Sua assinatura requer atenção.',
                style: TextStyle(
                  color: Colors.amber.shade900,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () {
                context.go('/store/$storeId/plans');
              },
              child: const Text('Verificar'),
            )
          ],
        ),
      ),
    );
  }
}