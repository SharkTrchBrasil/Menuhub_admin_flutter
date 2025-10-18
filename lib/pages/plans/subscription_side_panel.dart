// lib/widgets/subscription_side_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/pages/plans/plans_page.dart';
import 'package:totem_pro_admin/pages/plans/reactivate_subscription_page.dart';
import 'package:totem_pro_admin/pages/plans/manage_subscription_page.dart';

class SubscriptionSidePanel extends StatelessWidget {
  final int storeId;
  final StoresManagerCubit storesManagerCubit; // ✅ ADICIONAR

  const SubscriptionSidePanel({
    super.key,
    required this.storeId,
    required this.storesManagerCubit, // ✅ ADICIONAR
  });

  @override
  Widget build(BuildContext context) {
    // ✅ ENVOLVER COM BlocProvider.value
    return BlocProvider.value(
      value: storesManagerCubit,
      child: BlocBuilder<StoresManagerCubit, StoresManagerState>(
        builder: (context, state) {
          if (state is! StoresManagerLoaded) {
            return const Center(child: CircularProgressIndicator());
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
            return _buildPanelWrapper(
              context,

              child: EditSubscriptionPage(storeId: storeId),
            );
          }

          // CASO 2: Cancelada mas ainda tem dias → Reativar
          if (subscription.status == 'canceled') {
            final now = DateTime.now();
            final endDate = subscription.currentPeriodEnd;
            final hasAccess = endDate != null && now.isBefore(endDate);

            if (hasAccess) {
              return _buildPanelWrapper(
                context,

                child: ReactivateSubscriptionPage(storeId: storeId),
              );
            } else {
              // Cancelada e expirada → Escolher plano novamente
              return _buildPanelWrapper(
                context,

                child: EditSubscriptionPage(storeId: storeId),
              );
            }
          }

          // CASO 3: Ativa → Gerenciar
          if (subscription.status == 'active' || subscription.status == 'trialing') {
            return _buildPanelWrapper(
              context,

              child: ManageSubscriptionPage(storeId: storeId),
            );
          }

          // CASO 4: Status desconhecido → Erro
          return _buildError(
            context,
            'Status de assinatura desconhecido: ${subscription.status}',
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // WRAPPER DO PAINEL
  // ═══════════════════════════════════════════════════════════

  Widget _buildPanelWrapper(
      BuildContext context, {

        required Widget child,
      }) {


    return Expanded(
      child: child,
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ESTADO DE ERRO
  // ═══════════════════════════════════════════════════════════

  Widget _buildError(BuildContext context, String message) {
    return Container(
      width: 500,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}