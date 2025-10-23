// [Arquivo: ifood_header.dart]

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/store/store.dart';

// Imports necessários para os Alertas
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/helpers/sidepanel.dart';
import 'package:totem_pro_admin/pages/operation_configuration/cubit/operation_config_cubit.dart';
import 'package:totem_pro_admin/pages/orders/settings/orders_settings.dart';


class IfoodHeader extends StatelessWidget {
  final Store? activeStore;

  const IfoodHeader({super.key, required this.activeStore});

  @override
  Widget build(BuildContext context) {
    // ✅ 1. Calculamos os alertas aqui usando a loja ativa
    final alerts = _getStoreAlerts(activeStore);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ✅ Logo iFood no START
          _buildLogo(),
          const SizedBox(width: 30),
          // ✅ Informações do usuário + Popup Trocador de Loja
          BlocBuilder<StoresManagerCubit, StoresManagerState>(
            builder: (context, state) {
              if (state is! StoresManagerLoaded) {
                return _buildUserInfo(context, false, false);
              }

              return PopupMenuButton<int>(
                offset: const Offset(0, 56),
                tooltip: 'Trocar de loja',
                onSelected: (storeId) {
                  context.read<StoresManagerCubit>().changeActiveStore(storeId);
                },
                itemBuilder: (context) => _buildStoreSwitcherEntries(
                  context,
                  state.stores.values.toList(),
                  state.activeStoreId,
                ),
                child: _buildUserInfo(
                  context,
                  true,
                  state.stores.length > 1,
                ),
              );
            },
          ),

          // ✅ Spacer para empurrar todo o resto para o END
          const Spacer(),

          // ✅ Restante do conteúdo no END
          Row(
            children: [
              // ✅ Alertas Desktop
              if (alerts.isNotEmpty)
                _DesktopAlerts(alerts: alerts, storeId: activeStore?.core.id ?? 0),




              const SizedBox(width: 16),

              // ✅ Ícones de ação com botão de Alertas
              _buildActionIcons(context, alerts),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFEA1D2C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.restaurant,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, bool showArrow, bool isClickable) {
    final operationConfig = activeStore?.relations.storeOperationConfig;
    final isStoreOpen = operationConfig?.isStoreOpen ?? false;

    return Tooltip(
      message: isClickable ? 'Clique para trocar de loja' : '',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(6),
          color: isClickable ? Colors.white : Colors.transparent,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: activeStore?.media?.image?.url != null
                  ? NetworkImage(activeStore!.media!.image!.url!)
                  : null,
              backgroundColor: Colors.grey[200],
              child: activeStore?.media?.image?.url == null
                  ? const Icon(Icons.store, size: 18)
                  : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  activeStore?.core.name ?? 'Carregando...',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isStoreOpen ? Colors.green[600] : Colors.red[600],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isStoreOpen ? 'Loja aberta' : 'Loja fechada',
                      style: TextStyle(
                        fontSize: 10,
                        color: isStoreOpen ? Colors.green[700] : Colors.red[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (showArrow) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down, size: 16),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildActionIcons(BuildContext context, List<StoreAlert> alerts) {
    return Row(
      children: [
        const SizedBox(width: 12),
        _buildHeaderIcon(context, Icons.chat_bubble_outline, 'Chatbot'),


      ],
    );
  }

  Widget _buildHeaderIcon(BuildContext context, IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {

        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: Colors.grey[700]),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // LÓGICA DO TROCADOR DE LOJA
  // ═══════════════════════════════════════════════════════════

  List<PopupMenuEntry<int>> _buildStoreSwitcherEntries(
      BuildContext context,
      List<dynamic> stores,
      int? activeStoreId,
      ) {
    return stores.map((storeData) {
      final store = storeData.store;
      final subscription = store.relations.subscription;
      final bool isActive = store.core.id == activeStoreId;
      final bool hasIssue = _hasSubscriptionIssue(subscription);

      return PopupMenuItem<int>(
        value: store.core.id,
        enabled: !isActive,
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).primaryColor.withOpacity(0.05)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: store.media?.image?.url != null
                    ? NetworkImage(store.media!.image!.url!)
                    : null,
                backgroundColor: Colors.grey[200],
                child: store.media?.image?.url == null
                    ? const Icon(Icons.store, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.core.name,
                      style: TextStyle(
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildSubscriptionBadge(subscription),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (isActive)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                )
              else if (hasIssue)
                Icon(
                  Icons.error_outline,
                  color: Colors.red[700],
                  size: 20,
                ),
            ],
          ),
        ),
      );
    }).toList();
  }

  bool _hasSubscriptionIssue(dynamic subscription) {
    if (subscription == null) return true;
    if (subscription.isBlocked) return true;
    final problematicStatuses = ['expired', 'past_due', 'canceled'];
    if (problematicStatuses.contains(subscription.status)) {
      return true;
    }
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
      case 'canceled':
        return _buildBadge(
          'Expirada/Cancelada',
          Colors.red.shade50,
          Colors.red.shade700,
          Icons.block,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// ✅ ALERTA DESKTOP NO CENTER (IGUAL APPBARCODE.DART)
// ═══════════════════════════════════════════════════════════
class _DesktopAlerts extends StatelessWidget {
  final List<StoreAlert> alerts;
  final int storeId;

  const _DesktopAlerts({required this.alerts, required this.storeId});

  @override
  Widget build(BuildContext context) {
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
// PAINEL DE ALERTAS (CLONADO DE APPBARCODE.DART)
// ═══════════════════════════════════════════════════════════
class _AlertsPanel extends StatelessWidget {
  final List<StoreAlert> alerts;
  final int storeId;

  const _AlertsPanel({required this.alerts, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Alertas da Loja',
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
                  storeId: storeId,
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
// CARD DE ALERTA (CLONADO DE APPBARCODE.DART)
// ═══════════════════════════════════════════════════════════
class _AlertCard extends StatelessWidget {
  final StoreAlert alert;
  final int storeId;

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
                  Navigator.pop(context);
                  alert.onAction?.call(context);
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
// ✅ FUNÇÃO GLOBAL PARA ABRIR SIDE PANEL (CLONADO DE APPBARCODE.DART)
// ═══════════════════════════════════════════════════════════
void _showStoreSettingsSidePanel(BuildContext context, int storeId) {
  showResponsiveSidePanel(
    context,
    BlocProvider<OperationConfigCubit>(
      create: (context) => getIt<OperationConfigCubit>(),
      child: StoreSettingsSidePanel(storeId: storeId),
    ),
  );
}

// ═══════════════════════════════════════════════════════════
// ✅ MODELO DE ALERTA (CLONADO DE APPBARCODE.DART)
// ═══════════════════════════════════════════════════════════
class StoreAlert {
  final String title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final int priority;
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
// ✅ LÓGICA COMPLETA DE DETECÇÃO DE ALERTAS (CLONADO DE APPBARCODE.DART)
// ═══════════════════════════════════════════════════════════
List<StoreAlert> _getStoreAlerts(dynamic store) {
  if (store == null) return [];

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
                  message: 'Sua assinatura expirou. Renove para continuar usando',
                  icon: Icons.error_outline,
                  backgroundColor: Colors.red[700]!,
                  priority: 1,
                  actionText: 'Renovar Urgente',
                  onAction: (context) {
                    context.go('/stores/$storeId/manager');
                  },
                ),
              );
            }
            // 🔴 CRÍTICO - 3 DIAS OU MENOS
            else if (daysRemaining <= 3) {
              final message = status == 'trialing'
                  ? 'Seu período de teste termina em ${daysRemaining == 1 ? '1 dia' : '$daysRemaining dias'}'
                  : 'Sua assinatura expira em ${daysRemaining == 1 ? '1 dia' : '$daysRemaining dias'}';

              alerts.add(
                StoreAlert(
                  title: daysRemaining == 1 ? 'Último Dia!' : 'Expira em $daysRemaining Dias',
                  message: message,
                  icon: Icons.warning_amber_rounded,
                  backgroundColor: Colors.red[700]!,
                  priority: 1,
                  actionText: status == 'trialing' ? 'Escolher Plano' : 'Renovar Agora',
                  onAction: (context) {
                    context.go('/stores/$storeId/manager');
                  },
                ),
              );
            }
            // 🟠 AVISO - 7 DIAS OU MENOS
            else if (daysRemaining <= 7) {
              final message = status == 'trialing'
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
                    context.go('/stores/$storeId/manager');
                  },
                ),
              );
            }
            // 🔵 PERÍODO DE TESTE (14+ DIAS)
            else if (status == 'trialing' && daysRemaining > 7) {
              alerts.add(
                StoreAlert(
                  title: 'Período de Teste Ativo',
                  message: 'Você está testando gratuitamente. Restam $daysRemaining dias.',
                  icon: Icons.celebration_outlined,
                  backgroundColor: Colors.blue[600]!,
                  priority: 3,
                  actionText: 'Conhecer Planos',
                  onAction: (context) {
                    context.go('/stores/$storeId/manager');
                  },
                ),
              );
            }
          }
        }

        final status = subscription.status?.toString() ?? '';

        // ❌ PROBLEMA NO PAGAMENTO
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
                context.go('/stores/$storeId/manager');
              },
            ),
          );
        }

        // ⚠️ SEM MÉTODO DE PAGAMENTO
        final hasPaymentMethod = subscription.hasPaymentMethod ?? false;

        if (!hasPaymentMethod && status == 'trialing') {
          final periodEndStr = subscription.currentPeriodEnd?.toString() ?? '';
          final periodEnd = DateTime.tryParse(periodEndStr);

          if (periodEnd != null) {
            final daysRemaining = periodEnd.difference(DateTime.now()).inDays;

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
                    context.go('/stores/$storeId/manager');
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
    // 2️⃣ STATUS DA LOJA
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
// HELPERS
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