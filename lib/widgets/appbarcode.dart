import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../constdata/colorprovider.dart';
import '../core/di.dart';
import '../core/helpers/sidepanel.dart';
import '../cubits/auth_cubit.dart';
import '../cubits/store_manager_cubit.dart';
import '../cubits/store_manager_state.dart';
import '../core/helpers/navigation.dart';
import '../core/responsive_builder.dart';
import '../pages/operation_configuration/cubit/operation_config_cubit.dart';
import '../pages/orders/settings/orders_settings.dart';

class AppBarCode extends StatelessWidget implements PreferredSizeWidget {
  const AppBarCode({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    final currentPath = GoRouterState.of(context).uri.path;

    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded || state.activeStore == null) {
          return AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: const Text('Carregando...'),
          );
        }

        final store = state.activeStore!;
        final storeId = store.core.id!;
        final helper = StoreNavigationHelper(storeId);
        final pageTitle = helper.getTitleForPath(currentPath);

        return AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: kToolbarHeight,
          backgroundColor: Colors.white,
          elevation: 0.5,
          leadingWidth: isMobile ? 56 : null,
          leading:
              isMobile
                  ? IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black87),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  )
                  : null,
          centerTitle: isMobile,
          title:
              isMobile
                  ? Text(
                    pageTitle,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [_DesktopAlerts(store: store)],
                  ),
          actions: [
            if (ResponsiveBuilder.isMobile(context))
              _AlertsButton(store: store, isMobile: isMobile),
            const SizedBox(width: 8),
            Container(
              width: 1,
              height: 24,
              margin: const EdgeInsets.symmetric(vertical: 16),
              color: Colors.grey[300],
            ),
            const SizedBox(width: 8),
            _UserMenuButton(store: store, isMobile: isMobile),
            const SizedBox(width: 16),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ✅ FUNÇÃO GLOBAL PARA ABRIR SIDE PANEL (USANDO O PADRÃO)
// ═══════════════════════════════════════════════════════════
void _showStoreSettingsSidePanel(BuildContext context, int storeId) {
  showResponsiveSidePanel(
    context,
    // ✅ Provê o OperationConfigCubit para o painel
    BlocProvider<OperationConfigCubit>(
      create: (context) => getIt<OperationConfigCubit>(),
      child: StoreSettingsSidePanel(storeId: storeId),
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// ALERTAS DESKTOP (NO TITLE)
// ═══════════════════════════════════════════════════════════
class _DesktopAlerts extends StatelessWidget {
  final dynamic store;

  const _DesktopAlerts({required this.store});

  @override
  Widget build(BuildContext context) {
    final alerts = _getStoreAlerts(store);

    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    final criticalAlert = alerts.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: criticalAlert.backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: criticalAlert.backgroundColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            criticalAlert.icon,
            color: criticalAlert.backgroundColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              criticalAlert.message,
              style: TextStyle(
                color: criticalAlert.backgroundColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (criticalAlert.actionText != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => criticalAlert.onAction?.call(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                criticalAlert.actionText!,
                style: TextStyle(
                  color: criticalAlert.backgroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// BOTÃO DE ALERTAS (MOBILE E DESKTOP)
// ═══════════════════════════════════════════════════════════
class _AlertsButton extends StatelessWidget {
  final dynamic store;
  final bool isMobile;

  const _AlertsButton({required this.store, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final alerts = _getStoreAlerts(store);

    return IconButton(
      icon: Stack(
        children: [
          Icon(
            alerts.isEmpty
                ? Icons.notifications_outlined
                : Icons.warning_amber_rounded,
            color: alerts.isEmpty ? Colors.black87 : Colors.orange[700],
          ),
          if (alerts.isNotEmpty)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: _getHighestPriority(alerts).backgroundColor,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  '${alerts.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      onPressed: () {
        if (alerts.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhum alerta no momento'),
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          _showAlertsPanel(context, alerts, store.core.id!);
        }
      },
    );
  }

  void _showAlertsPanel(
    BuildContext context,
    List<StoreAlert> alerts,
    int storeId,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => _AlertsPanel(
            alerts: alerts,
            storeId: storeId, // ✅ Passa o storeId
          ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PAINEL DE ALERTAS (BOTTOM SHEET)
// ═══════════════════════════════════════════════════════════
class _AlertsPanel extends StatelessWidget {
  final List<StoreAlert> alerts;
  final int storeId; // ✅ Adiciona storeId

  const _AlertsPanel({required this.alerts, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alertas do Sistema',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: alerts.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return _AlertCard(
                  alert: alert,
                  storeId: storeId, // ✅ Passa o storeId
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// CARD DE ALERTA
// ═══════════════════════════════════════════════════════════
class _AlertCard extends StatelessWidget {
  final StoreAlert alert;
  final int storeId; // ✅ Adiciona storeId

  const _AlertCard({required this.alert, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alert.backgroundColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert.backgroundColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(alert.icon, color: alert.backgroundColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  alert.title,
                  style: TextStyle(
                    color: alert.backgroundColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            alert.message,
            style: TextStyle(color: Colors.grey[800], fontSize: 14),
          ),
          if (alert.actionText != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Fecha o bottom sheet
                  alert.onAction?.call(context); // Executa a ação
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: alert.backgroundColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(alert.actionText!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MENU DE USUÁRIO (SEM ALTERAÇÕES)
// ═══════════════════════════════════════════════════════════
class _UserMenuButton extends StatelessWidget {
  final dynamic store;
  final bool isMobile;

  const _UserMenuButton({required this.store, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final notifire = Provider.of<ColorNotifire>(context);
    final userName = context.read<AuthCubit>().getUserName() ?? 'Usuário';

    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Text(
              userName[0].toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  store.core.name,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          ],
        ],
      ),
      itemBuilder:
          (context) => [
            PopupMenuItem<String>(
              enabled: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store.core.name,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 12),
                  const Text('Meu Perfil'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'store-settings',
              child: Row(
                children: [
                  Icon(Icons.store_outlined, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 12),
                  const Text('Configurações da Loja'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'subscription',
              child: Row(
                children: [
                  Icon(
                    Icons.card_membership_outlined,
                    size: 20,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 12),
                  const Text('Minha Assinatura'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              enabled: false,
              child: Divider(height: 1),
            ),
            PopupMenuItem<String>(
              enabled: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.dark_mode_outlined,
                        size: 20,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 12),
                      const Text('Modo Escuro'),
                    ],
                  ),
                  Switch(
                    value: notifire.getIsDark,
                    onChanged: (value) {
                      notifire.isavalable(value);
                      Navigator.pop(context);
                    },
                    activeColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              enabled: false,
              child: Divider(height: 1),
            ),
            PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  const Icon(Icons.logout, size: 20, color: Colors.red),
                  const SizedBox(width: 12),
                  const Text('Sair', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
      onSelected: (value) async {
        final storeId = store.core.id!;

        switch (value) {
          case 'profile':
            context.go('/stores/$storeId/settings');
            break;
          case 'store-settings':
            context.go('/stores/$storeId/settings');
            break;
          case 'subscription':
            context.go('/stores/$storeId/manager');
            break;
          case 'logout':
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text('Confirmar Saída'),
                    content: const Text('Tem certeza que deseja sair?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Sair'),
                      ),
                    ],
                  ),
            );

            if (shouldLogout == true && context.mounted) {
              await context.read<AuthCubit>().logout();
              if (context.mounted) {
                context.go('/sign-in');
              }
            }
            break;
        }
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
// MODELO DE ALERTA
// ═══════════════════════════════════════════════════════════
class StoreAlert {
  final String title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final int priority; // 1 = crítico, 2 = aviso, 3 = info
  final String? actionText;
  final Function(BuildContext)? onAction;

  const StoreAlert({
    required this.title,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.priority,
    this.actionText,
    this.onAction,
  });
}

// ═══════════════════════════════════════════════════════════
// LÓGICA DE DETECÇÃO DE ALERTAS (VERSÃO FINAL CORRIGIDA)
// ═══════════════════════════════════════════════════════════
List<StoreAlert> _getStoreAlerts(dynamic store) {
  final alerts = <StoreAlert>[];

  try {
    final operationConfig = store.relations?.storeOperationConfig;
    final subscription = store.relations?.subscription;
    final storeId = store.core.id!;
    // ═══════════════════════════════════════════════════════════
    // 1️⃣ ASSINATURA (PRIORIDADE MÁXIMA)
    // ═══════════════════════════════════════════════════════════
    if (subscription != null) {
      try {
        // ✅ CAMPO CORRETO: current_period_end
        final periodEndStr = subscription.currentPeriodEnd?.toString() ?? '';

        if (periodEndStr.isNotEmpty) {
          final periodEnd = DateTime.tryParse(periodEndStr);

          if (periodEnd != null) {
            final daysRemaining = periodEnd.difference(DateTime.now()).inDays;
            final status = subscription.status?.toString() ?? '';

            // ❌ ASSINATURA EXPIRADA
            if (daysRemaining <= 0) {
              alerts.add(
                StoreAlert(
                  title: 'Assinatura Expirada',
                  message:
                      'Sua assinatura expirou. Renove para continuar usando',
                  icon: Icons.error_outline,
                  backgroundColor: Colors.red[700]!,
                  priority: 1,
                  actionText: 'Renovar Urgente',
                  onAction: (context) {
                    context.go('/stores/${store.core.id}/manager');
                  },
                ),
              );
            }
            // 🔴 CRÍTICO - 3 DIAS OU MENOS
            else if (daysRemaining <= 3) {
              final message =
                  status == 'trialing'
                      ? 'Seu período de teste termina em ${daysRemaining == 1 ? '1 dia' : '$daysRemaining dias'}'
                      : 'Sua assinatura expira em ${daysRemaining == 1 ? '1 dia' : '$daysRemaining dias'}';

              alerts.add(
                StoreAlert(
                  title:
                      daysRemaining == 1
                          ? 'Último Dia!'
                          : 'Expira em $daysRemaining Dias',
                  message: message,
                  icon: Icons.warning_amber_rounded,
                  backgroundColor: Colors.red[700]!,
                  priority: 1,
                  actionText:
                      status == 'trialing' ? 'Escolher Plano' : 'Renovar Agora',
                  onAction: (context) {
                    context.go('/stores/${store.core.id}/manager');
                  },
                ),
              );
            }
            // 🟠 AVISO - 7 DIAS OU MENOS
            else if (daysRemaining <= 7) {
              final message =
                  status == 'trialing'
                      ? 'Restam $daysRemaining dias de teste gratuito'
                      : 'Sua assinatura expira em $daysRemaining dias';

              alerts.add(
                StoreAlert(
                  title: 'Atenção',
                  message: message,
                  icon: Icons.info_outline,
                  backgroundColor: Colors.orange[700]!,
                  priority: 2,
                  actionText: 'Ver Planos',
                  onAction: (context) {
                    context.go('/stores/${store.core.id}/manager');
                  },
                ),
              );
            }
            // 🔵 PERÍODO DE TESTE (14+ DIAS)
            else if (status == 'trialing' && daysRemaining > 7) {
              alerts.add(
                StoreAlert(
                  title: 'Período de Teste Ativo',
                  message:
                      'Você está testando gratuitamente. Restam $daysRemaining dias.',
                  icon: Icons.celebration_outlined,
                  backgroundColor: Colors.blue[600]!,
                  priority: 3,
                  actionText: 'Conhecer Planos',
                  onAction: (context) {
                    context.go('/stores/${store.core.id}/manager');
                  },
                ),
              );
            }
          }
        }

        // ❌ PROBLEMA NO PAGAMENTO
        final status = subscription.status?.toString() ?? '';

        if (status == 'payment_failed' || status == 'past_due') {
          alerts.add(
            StoreAlert(
              title: 'Problema no Pagamento',
              message: 'Houve um problema com o pagamento da sua assinatura',
              icon: Icons.payment_outlined,
              backgroundColor: Colors.red[700]!,
              priority: 1,
              actionText: 'Atualizar Pagamento',
              onAction: (context) {
                context.go('/stores/${store.core.id}/manager');
              },
            ),
          );
        }

        // ⚠️ SEM MÉTODO DE PAGAMENTO (TESTE ACABANDO)
        final hasPaymentMethod = subscription.hasPaymentMethod ?? false;

        if (!hasPaymentMethod && status == 'trialing') {
          final periodEndStr = subscription.currentPeriodEnd?.toString() ?? '';
          final periodEnd = DateTime.tryParse(periodEndStr);

          if (periodEnd != null) {
            final daysRemaining = periodEnd.difference(DateTime.now()).inDays;

            // Só mostra se estiver perto do fim do teste (7 dias ou menos)
            if (daysRemaining <= 7 && daysRemaining > 0) {
              alerts.add(
                StoreAlert(
                  title: 'Adicione um Método de Pagamento',
                  message:
                      'Seu teste termina em $daysRemaining ${daysRemaining == 1 ? 'dia' : 'dias'}. Adicione um cartão para continuar sem interrupções.',
                  icon: Icons.credit_card_outlined,
                  backgroundColor: Colors.orange[600]!,
                  priority: 2,
                  actionText: 'Adicionar Cartão',
                  onAction: (context) {
                    context.go('/stores/${store.core.id}/manager');
                  },
                ),
              );
            }
          }
        }
      } catch (e) {
        debugPrint('⚠️ Erro ao verificar assinatura: $e');
      }
    }

    // ═══════════════════════════════════════════════════════════
    // 2️⃣ STATUS DA LOJA (ATUALIZADO PARA USAR SIDE PANEL PADRÃO)
    // ═══════════════════════════════════════════════════════════
    if (operationConfig != null) {
      // 🔴 LOJA FECHADA
      if (operationConfig.isStoreOpen == false) {
        alerts.add(
          StoreAlert(
            title: 'Loja Fechada',
            message: 'Sua loja está fechada e não está recebendo pedidos',
            icon: Icons.store_mall_directory_outlined,
            backgroundColor: Colors.red[700]!,
            priority: 1,
            actionText: 'Abrir Loja',
            onAction: (context) {
              // ✅ USA O SIDE PANEL PADRÃO
              _showStoreSettingsSidePanel(context, storeId);
            },
          ),
        );
      }

      // 🟠 DELIVERY DESATIVADO
      if (operationConfig.deliveryEnabled == false) {
        alerts.add(
          StoreAlert(
            title: 'Delivery Desativado',
            message: 'O serviço de delivery está desativado',
            icon: Icons.delivery_dining_outlined,
            backgroundColor: Colors.orange[700]!,
            priority: 2,
            actionText: 'Ativar Delivery',
            onAction: (context) {
              // ✅ USA O SIDE PANEL PADRÃO
              _showStoreSettingsSidePanel(context, storeId);
            },
          ),
        );
      }

      // 🟠 PICKUP DESATIVADO
      if (operationConfig.pickupEnabled == false) {
        alerts.add(
          StoreAlert(
            title: 'Retirada Desativada',
            message: 'O serviço de retirada está desativado',
            icon: Icons.shopping_bag_outlined,
            backgroundColor: Colors.orange[600]!,
            priority: 3,
            actionText: 'Ativar Retirada',
            onAction: (context) {
              // ✅ USA O SIDE PANEL PADRÃO
              _showStoreSettingsSidePanel(context, storeId);
            },
          ),
        );
      }

      // 🟠 MESAS DESATIVADAS
      if (operationConfig.tableEnabled == false) {
        alerts.add(
          StoreAlert(
            title: 'Consumo no Local Desativado',
            message: 'O serviço de mesas está desativado',
            icon: Icons.restaurant_outlined,
            backgroundColor: Colors.orange[600]!,
            priority: 3,
            actionText: 'Ativar Mesas',
            onAction: (context) {
              // ✅ USA O SIDE PANEL PADRÃO
              _showStoreSettingsSidePanel(context, storeId);
            },
          ),
        );
      }
    }
    // ═══════════════════════════════════════════════════════════
    // 3️⃣ PAUSAS PROGRAMADAS ATIVAS
    // ═══════════════════════════════════════════════════════════
    final scheduledPauses = store.relations?.scheduledPauses ?? [];
    final now = DateTime.now();

    for (var pause in scheduledPauses) {
      try {
        final startTime = DateTime.tryParse(pause.startTime?.toString() ?? '');
        final endTime = DateTime.tryParse(pause.endTime?.toString() ?? '');

        if (startTime != null && endTime != null) {
          if (now.isAfter(startTime) && now.isBefore(endTime)) {
            alerts.add(
              StoreAlert(
                title: 'Pausa Programada Ativa',
                message: 'Loja pausada até ${_formatTime(endTime)}',
                icon: Icons.pause_circle_outlined,
                backgroundColor: Colors.orange[700]!,
                priority: 2,
              ),
            );
            break;
          }
        }
      } catch (e) {
        debugPrint('⚠️ Erro ao verificar pausa: $e');
      }
    }
  } catch (e) {
    debugPrint('⚠️ Erro ao gerar alertas: $e');
  }

  // Ordena por prioridade (críticos primeiro)
  alerts.sort((a, b) => a.priority.compareTo(b.priority));

  return alerts;
}

// ═══════════════════════════════════════════════════════════
// HELPER: FORMATA HORA
// ═══════════════════════════════════════════════════════════
String _formatTime(DateTime dateTime) {
  return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

StoreAlert _getHighestPriority(List<StoreAlert> alerts) {
  if (alerts.isEmpty) {
    return const StoreAlert(
      title: 'Tudo OK',
      message: 'Sistema funcionando normalmente',
      icon: Icons.check_circle_outline,
      backgroundColor: Colors.green,
      priority: 999,
    );
  }
  return alerts.reduce((a, b) => a.priority < b.priority ? a : b);
}
