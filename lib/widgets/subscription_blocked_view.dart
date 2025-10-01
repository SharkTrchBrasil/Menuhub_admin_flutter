import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/models/subscription.dart'; // Importe seu modelo de assinatura

class SubscriptionBlockedView extends StatelessWidget {
  final Subscription subscription;
  final int storeId;

  const SubscriptionBlockedView({
    super.key,
    required this.subscription,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.credit_card_off_outlined,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 24),
              Text(
                'Acesso Suspenso',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                subscription.warningMessage ?? 'Sua assinatura precisa de atenção.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // ✅ Navega para a tela de gerenciamento de assinatura/reativação
                  // Ajuste a rota conforme a sua configuração no GoRouter
                  context.go('/billing/$storeId');
                },
                icon: const Icon(Icons.payment),
                label: const Text('Regularizar Assinatura'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}