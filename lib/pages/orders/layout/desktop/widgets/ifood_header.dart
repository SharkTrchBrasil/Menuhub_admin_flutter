// [Arquivo: ifood_header.dart]

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/store/store.dart';

// Imports necessários para os Alertas (copiados de appbarcode.dart)
import 'package:totem_pro_admin/core/di.dart';
import 'package:totem_pro_admin/core/helpers/sidepanel.dart';
import 'package:totem_pro_admin/pages/operation_configuration/cubit/operation_config_cubit.dart';
import 'package:totem_pro_admin/pages/orders/settings/orders_settings.dart'; // (Verifique este import)


class IfoodHeader extends StatelessWidget {
  final Store? activeStore;

  const IfoodHeader({super.key, required this.activeStore});

  @override
  Widget build(BuildContext context) {
    // 1. Calculamos os alertas aqui
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
        children: [
          // Logo iFood (simulada)
          _buildLogo(),

          const Spacer(),

          // 2. Informações do usuário + Popup Trocador de Loja
          BlocBuilder<StoresManagerCubit, StoresManagerState>(
            builder: (context, state) {
              // Se o estado não estiver carregado, mostre o widget de usuário padrão sem popup
              if (state is! StoresManagerLoaded) {
                return _buildUserInfo(context, false, false);
              }

              return PopupMenuButton<int>(
                offset: const Offset(0, 56), // Posição do popup
                tooltip: 'Trocar de loja',
                onSelected: (storeId) {
                  // 3. AÇÃO PRINCIPAL: Troca a loja ativa sem navegar
                  context.read<StoresManagerCubit>().changeActiveStore(storeId);
                },
                // 4. Constrói os itens do menu
                itemBuilder: (context) => _buildStoreSwitcherEntries(
                  context,
                  state.stores.values.toList(),
                  state.activeStoreId,
                ),
                // 5. O "botão" que abre o popup
                child: _buildUserInfo(
                  context,
                  true, // Mostra a seta de dropdown
                  state.stores.length > 1, // Só é clicável se houver > 1 loja
                ),
              );
            },
          ),

          const SizedBox(width: 16),

          // 6. Ícones de ação (agora com o botão de Alertas)
          _buildActionIcons(context, alerts),
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
    // Pega o status da loja (aberta/fechada) do activeStore
    final operationConfig = activeStore?.relations.storeOperationConfig;
    final isStoreOpen = operationConfig?.isStoreOpen ?? false;

    return Tooltip(
      message: isClickable ? 'Clique para trocar de loja' : '',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(20),
          color: isClickable ? Colors.grey[50] : Colors.transparent,
        ),
        child: Row(
          children: [
             CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(

                activeStore?.media?.image?.url ?? 'https://static-images.ifood.com.br/image/upload/f_auto,t_thumbnail/logosgde/3900c306-26fe-4d16-acac-1b57791c6dda/202507301031_Nu4W_f.jpg',
              ),
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
                        // Usa o status real da loja
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
        _buildHeaderIcon(context, Icons.headset_mic, 'Atendimentos'),
        const SizedBox(width: 12),
        _buildHeaderIcon(context, Icons.chat_bubble_outline, 'Conversas'),
        const SizedBox(width: 12),
        // 7. Botão de Alertas (lógica copiada de appbarcode.dart)
        _AlertsButton(alerts: alerts),
      ],
    );
  }

  Widget _buildHeaderIcon(BuildContext context, IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          // TODO: Adicionar ações
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
  // LÓGICA DO TROCADOR DE LOJA (adaptado de store_switcher_panel.dart)
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
        // Desabilita o clique se for a loja que já está ativa
        enabled: !isActive,
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? Theme.of(context).primaryColor.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                child:    CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(

                    store?.media?.image?.url ?? 'https://static-images.ifood.com.br/image/upload/f_auto,t_thumbnail/logosgde/3900c306-26fe-4d16-acac-1b57791c6dda/202507301031_Nu4W_f.jpg',
                  ),
                ),
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

  // --- Helpers de Assinatura (copiados de store_switcher_panel.dart) ---
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

  Widget _buildBadge(
      String text, Color bgColor, Color textColor, IconData icon) {
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
// BOTÃO DE ALERTAS (copiado de appbarcode.dart)
// ═══════════════════════════════════════════════════════════
class _AlertsButton extends StatelessWidget {
  final List<StoreAlert> alerts;

  const _AlertsButton({required this.alerts});

  @override
  Widget build(BuildContext context) {
    final hasAlerts = alerts.isNotEmpty;
    final highestPriority = hasAlerts ? _getHighestPriority(alerts) : null;

    return Tooltip(
      message: hasAlerts ? 'Você tem ${alerts.length} alertas' : 'Nenhum alerta',
      child: InkWell(
        onTap: () {
          final storeId = context.read<StoresManagerCubit>().state.activeStore!.core.id;
          if (storeId == null) return;

          if (alerts.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Nenhum alerta no momento'),
                duration: Duration(seconds: 1),
              ),
            );
          } else {
            _showAlertsPanel(context, alerts, storeId);
          }
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            shape: BoxShape.circle,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Icon(
                  hasAlerts ? Icons.warning_amber_rounded : Icons.notifications_none,
                  size: 20,
                  color: hasAlerts ? highestPriority!.backgroundColor : Colors.grey[700],
                ),
              ),
              if (hasAlerts)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: highestPriority!.backgroundColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 10, minHeight: 10),
                    child: Center(
                      child: Text(
                        '${alerts.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlertsPanel(
      BuildContext context,
      List<StoreAlert> alerts,
      int storeId,
      ) {
    // Mostra como um Dialog flutuante (melhor para desktop)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titlePadding: const EdgeInsets.all(0),
        contentPadding: const EdgeInsets.all(0),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: _AlertsPanel(
            alerts: alerts,
            storeId: storeId,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// PAINEL DE ALERTAS (copiado de appbarcode.dart)
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
// CARD DE ALERTA (copiado de appbarcode.dart)
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
                  Navigator.pop(context); // Fecha o dialog
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
// LÓGICA DE DETECÇÃO DE ALERTAS (copiada de appbarcode.dart)
// ═══════════════════════════════════════════════════════════

// --- Helper de Abertura do Painel de Configurações ---
void _showStoreSettingsSidePanel(BuildContext context, int storeId) {
  showResponsiveSidePanel(
    context,
    BlocProvider<OperationConfigCubit>(
      create: (context) => getIt<OperationConfigCubit>(),
      // Ajuste este nome se 'StoreSettingsSidePanel' não for o correto
      child: StoreSettingsSidePanel(storeId: storeId),
    ),
  );
}

// --- Modelo de Alerta ---
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

// --- Função Principal de Alertas ---
List<StoreAlert> _getStoreAlerts(dynamic store) {
  if (store == null) return []; // Retorna lista vazia se a loja for nula

  final alerts = <StoreAlert>[];

  try {
    final operationConfig = store.relations?.storeOperationConfig;
    final subscription = store.relations?.subscription;
    final storeId = store.core.id!;

    // 1. Assinatura
    if (subscription != null) {
      // (Lógica de assinatura copiada de appbarcode.dart)
      final periodEndStr = subscription.currentPeriodEnd?.toString() ?? '';
      if (periodEndStr.isNotEmpty) {
        final periodEnd = DateTime.tryParse(periodEndStr);
        if (periodEnd != null) {
          final daysRemaining = periodEnd.difference(DateTime.now()).inDays;
          final status = subscription.status?.toString() ?? '';

          if (daysRemaining <= 0) {
            alerts.add(StoreAlert(title: 'Assinatura Expirada', message: 'Sua assinatura expirou. Renove para continuar usando', icon: Icons.error_outline, backgroundColor: Colors.red[700]!, priority: 1, actionText: 'Renovar Urgente', onAction: (context) { context.go('/stores/${store.core.id}/manager'); },));
          } else if (daysRemaining <= 3) {
            final message = status == 'trialing' ? 'Seu período de teste termina em ${daysRemaining == 1 ? '1 dia' : '$daysRemaining dias'}' : 'Sua assinatura expira em ${daysRemaining == 1 ? '1 dia' : '$daysRemaining dias'}';
            alerts.add(StoreAlert(title: daysRemaining == 1 ? 'Último Dia!' : 'Expira em $daysRemaining Dias', message: message, icon: Icons.warning_amber_rounded, backgroundColor: Colors.red[700]!, priority: 1, actionText: status == 'trialing' ? 'Escolher Plano' : 'Renovar Agora', onAction: (context) { context.go('/stores/${store.core.id}/manager'); },));
          } else if (daysRemaining <= 7) {
            // ... (outros alertas de assinatura)
          }
        }
      }
      final status = subscription.status?.toString() ?? '';
      if (status == 'payment_failed' || status == 'past_due') {
        alerts.add(StoreAlert(title: 'Problema no Pagamento', message: 'Houve um problema com o pagamento da sua assinatura', icon: Icons.payment_outlined, backgroundColor: Colors.red[700]!, priority: 1, actionText: 'Atualizar Pagamento', onAction: (context) { context.go('/stores/${store.core.id}/manager'); },));
      }
    }

    // 2. Status da Loja
    if (operationConfig != null) {
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
      // ... (outros alertas de operação)
    }

    // 3. Pausas Programadas
    // ... (lógica de pausas)

  } catch (e) {
    debugPrint('⚠️ Erro ao gerar alertas no IfoodHeader: $e');
  }

  alerts.sort((a, b) => a.priority.compareTo(b.priority));
  return alerts;
}

// --- Helpers de Prioridade e Formatação ---
String _formatTime(DateTime dateTime) {
  return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
}

StoreAlert _getHighestPriority(List<StoreAlert> alerts) {
  if (alerts.isEmpty) {
    return const StoreAlert(title: 'Tudo OK', message: 'Sistema funcionando normalmente', icon: Icons.check_circle_outline, backgroundColor: Colors.green, priority: 999,);
  }
  return alerts.reduce((a, b) => a.priority < b.priority ? a : b);
}