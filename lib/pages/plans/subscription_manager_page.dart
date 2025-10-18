// lib/pages/plans/subscription_manager_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/pages/plans/plans_page.dart';
import 'package:totem_pro_admin/pages/plans/manage_subscription_page.dart';
import 'package:totem_pro_admin/pages/plans/reactivate_subscription_page.dart';

/// ✅ Página de gerenciamento de assinatura
/// Decide qual tela mostrar baseado no status da assinatura
class SubscriptionManagerPage extends StatelessWidget {
  final int storeId;

  const SubscriptionManagerPage({
    super.key,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final storeWithRole = state.stores[storeId];
        if (storeWithRole == null) {
          return _buildError(context, 'Loja não encontrada');
        }

        final subscription = storeWithRole.store.relations.subscription;

        // ═══════════════════════════════════════════════════════════
        // DECISÃO DE QUAL TELA MOSTRAR
        // ═══════════════════════════════════════════════════════════

        // CASO 1: Sem assinatura ou bloqueada → Criar/Escolher plano
        if (subscription == null || subscription.isBlocked) {
          return EditSubscriptionPage(storeId: storeId);
        }

        // CASO 2: Cancelada mas ainda tem dias → Reativar
        if (subscription.status == 'canceled') {
          final now = DateTime.now();
          final endDate = subscription.currentPeriodEnd;
          final hasAccess = endDate != null && now.isBefore(endDate);

          if (hasAccess) {
            return ReactivateSubscriptionPage(storeId: storeId);
          } else {
            // Cancelada e expirada → Escolher plano novamente
            return EditSubscriptionPage(storeId: storeId);
          }
        }

        // CASO 3: Ativa ou Trial → Gerenciar
        if (subscription.status == 'active' || subscription.status == 'trialing') {
          return ManageSubscriptionPage(storeId: storeId);
        }

        // CASO 4: Status desconhecido → Erro
        return _buildError(
          context,
          'Status de assinatura desconhecido: ${subscription.status}',
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TELA DE ERRO
  // ═══════════════════════════════════════════════════════════

  Widget _buildError(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Assinatura'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}