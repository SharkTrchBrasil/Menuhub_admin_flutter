import 'package:flutter/material.dart';

class SubscriptionBlockedCard extends StatelessWidget {
  final String storeName;
  const SubscriptionBlockedCard({super.key, required this.storeName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock, size: 64, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(
                'Assinatura vencida',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.red),
              ),
              const SizedBox(height: 12),
              Text(
                'Renove seu plano para continuar visualizando os pedidos da loja "$storeName".',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
