// lib/widgets/store_switcher_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/store/store.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';

import '../core/di.dart';
import '../core/helpers/sidepanel.dart';
import '../pages/plans/subscription_side_panel.dart';

class StoreSwitcherPanel extends StatelessWidget {
  final StoresManagerCubit storesManagerCubit;
  final bool isInSidePanel;

  const StoreSwitcherPanel({
    super.key,
    required this.storesManagerCubit,
    this.isInSidePanel = false,
  });

  void _navigateToHubAfterSelection(BuildContext context, Store store) {
    final storeId = store.core.id!;

    if (isInSidePanel) {
      Navigator.of(context).pop();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/stores/$storeId/dashboard');
        }
      });
    } else {
      context.go('/stores/$storeId/dashboard');
    }
  }

  void _createNewStore(BuildContext context) {
    if (isInSidePanel) {
      Navigator.of(context).pop();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/stores/new/wizard');
        }
      });
    } else {
      context.go('/stores/new/wizard');
    }
  }

  Future<void> _openSubscriptionPanel(BuildContext context, int storeId) async {
    if (isInSidePanel) {
      Navigator.of(context).pop();
      await Future.delayed(const Duration(milliseconds: 150));
    }

    if (context.mounted) {
      await showResponsiveSidePanel(
        context,
        SubscriptionSidePanel(
          storesManagerCubit: storesManagerCubit,
          storeId: storeId,
        ),
      );
    }
  }


  bool _hasSubscriptionIssue(dynamic subscription) {
    // Se não tem subscription, tem problema
    if (subscription == null) return true;

    // Se está bloqueada, tem problema
    if (subscription.isBlocked) return true;


    final problematicStatuses = ['expired', 'past_due', 'canceled'];

    // Se status é problemático E está bloqueada
    if (problematicStatuses.contains(subscription.status)) {
      return true;
    }

    // ✅ Status válidos que NÃO têm problema: 'active', 'trialing', 'warning'
    return false;
  }


  Widget _buildSubscriptionBadge(dynamic subscription) {
    if (subscription == null) {
      return _buildBadge(
        'Sem Assinatura',
        Colors.red.shade50,
        Colors.red.shade700,
        Icons.error_outline,
      );
    }

    // ✅ CORREÇÃO: Badges por status
    switch (subscription.status) {
      case 'active':
        return _buildBadge(
          'Ativa',
          Colors.green.shade50,
          Colors.green.shade700,
          Icons.check_circle,
        );

      case 'trialing':
        return _buildBadge(
          'Período de Teste',
          Colors.blue.shade50,
          Colors.blue.shade700,
          Icons.timer,
        );

      case 'warning':
        return _buildBadge(
          'Atenção',
          Colors.orange.shade50,
          Colors.orange.shade700,
          Icons.warning_amber,
        );

      case 'past_due':
        return _buildBadge(
          'Pagamento Pendente',
          Colors.red.shade50,
          Colors.red.shade700,
          Icons.payment,
        );

      case 'expired':
        return _buildBadge(
          'Expirada',
          Colors.red.shade50,
          Colors.red.shade700,
          Icons.block,
        );

      case 'canceled':
        return _buildBadge(
          'Cancelada',
          Colors.grey.shade50,
          Colors.grey.shade700,
          Icons.cancel,
        );

      default:
        return _buildBadge(
          subscription.status,
          Colors.grey.shade50,
          Colors.grey.shade700,
          Icons.help_outline,
        );
    }
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return isMobile
        ? _buildMobileLayout(context)
        : _buildDesktopLayout(context);
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Column(
          children: [
            FixedHeader(
              showActionsOnMobile: true,
              title: 'Trocar de Loja',
              subtitle: 'Selecione uma loja para gerenciar',
              actions: [
                // DsButton(
                //   label: 'Nova Loja',
                //   style: DsButtonStyle.secondary,
                //   onPressed: () => _createNewStore(context),
                // )
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _buildStoresContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 600,
        ),
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: FixedHeader(
                  showActionsOnMobile: true,
                  title: 'Trocar de Loja',
                  subtitle: 'Selecione uma loja para gerenciar',
                  actions: [
                    DsButton(
                      label: 'Nova Loja',
                      style: DsButtonStyle.secondary,
                      onPressed: () => _createNewStore(context),
                    )
                  ],
                ),
              ),
              Expanded(
                child: _buildStoresContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoresContent(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      bloc: storesManagerCubit,
      builder: (context, state) {
        if (state is! StoresManagerLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final stores = state.stores.values.toList();
        final activeStoreId = state.activeStore?.core.id;

        if (stores.isEmpty) {
          return _buildEmptyState(context);
        }

        return _buildStoresList(
          context,
          stores: stores,
          activeStoreId: activeStoreId,
          isMobile: isMobile,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.store_mall_directory_outlined,
            size: isMobile ? 64 : 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma loja encontrada',
            style: TextStyle(
              fontSize: isMobile ? 18 : 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comece criando sua primeira loja',
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: isMobile ? double.infinity : 200,
            child: DsButton(
              onPressed: () => _createNewStore(context),
              label: 'Criar Primeira Loja',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoresList(
      BuildContext context, {
        required List<dynamic> stores,
        required int? activeStoreId,
        required bool isMobile,
      }) {
    return ListView.builder(
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        final subscription = store.store.relations.subscription;
        final bool isActive = store.store.core.id == activeStoreId;

        // ✅ CORREÇÃO: Usa a nova função de validação
        final bool hasIssue = _hasSubscriptionIssue(subscription);

        return Container(
          margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (hasIssue) {
                  _openSubscriptionPanel(context, store.store.core.id!);
                } else {
                  _navigateToHubAfterSelection(context, store.store);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive
                        ? Theme.of(context).primaryColor
                        : (hasIssue ? Colors.red.shade300 : Colors.grey.shade200),
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Row(
                  children: [
                    Container(
                      width: isMobile ? 50 : 60,
                      height: isMobile ? 50 : 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.storefront,
                        size: isMobile ? 24 : 28,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(width: isMobile ? 16 : 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.store.core.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 16 : 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // ✅ CORREÇÃO: Usa a nova função de badge
                          _buildSubscriptionBadge(subscription),
                        ],
                      ),
                    ),
                    Icon(
                      hasIssue ? Icons.arrow_forward : Icons.chevron_right,
                      color: hasIssue ? Colors.red : Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StoreSwitcherPanelWrapper extends StatelessWidget {
  const StoreSwitcherPanelWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StoreSwitcherPanel(
        storesManagerCubit: getIt<StoresManagerCubit>(),
        isInSidePanel: false,
      ),
    );
  }
}