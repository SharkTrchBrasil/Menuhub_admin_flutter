// lib/models/subscription/subscription.dart

import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/billing_preview.dart';
import 'package:totem_pro_admin/models/plans/plans.dart';
import 'package:totem_pro_admin/models/plans/plans_addon.dart';

import 'package:totem_pro_admin/models/subscription/details/billing_history_item.dart';

import 'details/card_info.dart';

class Subscription extends Equatable {
  final int id;
  final String status;
  final bool isBlocked;
  final String? warningMessage;
  final bool hasPaymentMethod;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final DateTime? canceledAt;
  final String? gatewaySubscriptionId;
  final Plans? plan;
  final List<PlansAddon> subscribedAddons;

  // ✅ NOVOS CAMPOS ADICIONADOS
  final BillingPreview? billingPreview;
  final CardInfo? cardInfo;
  final List<BillingHistoryItem> billingHistory;
  final bool canCancel;
  final bool canReactivate;

  const Subscription({
    required this.id,
    required this.status,
    required this.isBlocked,
    this.warningMessage,
    required this.hasPaymentMethod,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    this.canceledAt,
    this.gatewaySubscriptionId,
    this.plan,
    required this.subscribedAddons,
    // ✅ Novos parâmetros
    this.billingPreview,
    this.cardInfo,
    this.billingHistory = const [],
    this.canCancel = false,
    this.canReactivate = false,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as int,
      status: json['status'] as String,
      isBlocked: json['is_blocked'] as bool? ?? true,
      warningMessage: json['warning_message'] as String?,
      hasPaymentMethod: json['has_payment_method'] ?? false,
      currentPeriodStart: DateTime.parse(json['current_period_start'] as String),
      currentPeriodEnd: DateTime.parse(json['current_period_end'] as String),
      canceledAt: json['canceled_at'] != null
          ? DateTime.parse(json['canceled_at'] as String)
          : null,
      gatewaySubscriptionId: json['gateway_subscription_id'] as String?,
      plan: json['plan'] != null ? Plans.fromJson(json['plan']) : null,
      subscribedAddons: (json['subscribed_addons'] as List<dynamic>?)
          ?.map((e) => PlansAddon.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],

      // ✅ PARSE DOS NOVOS CAMPOS
      billingPreview: json['billing_preview'] != null
          ? BillingPreview.fromJson(json['billing_preview'] as Map<String, dynamic>)
          : null,
      cardInfo: json['card_info'] != null
          ? CardInfo.fromJson(json['card_info'] as Map<String, dynamic>)
          : null,
      billingHistory: (json['billing_history'] as List<dynamic>?)
          ?.map((e) => BillingHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      canCancel: json['can_cancel'] as bool? ?? false,
      canReactivate: json['can_reactivate'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
    id,
    status,
    isBlocked,
    warningMessage,
    hasPaymentMethod,
    currentPeriodStart,
    currentPeriodEnd,
    canceledAt,
    gatewaySubscriptionId,
    plan,
    subscribedAddons,
    billingPreview,
    cardInfo,
    billingHistory,
    canCancel,
    canReactivate,
  ];

  // ═══════════════════════════════════════════════════════════
  // HELPER METHODS (mantidos e melhorados)
  // ═══════════════════════════════════════════════════════════

  bool get isTrialing => status == 'trialing';
  bool get isActive => status == 'active';
  bool get isPastDue => status == 'past_due';
  bool get isExpired => status == 'expired';
  bool get isCanceled => status == 'canceled';

  int get daysUntilExpiration {
    return currentPeriodEnd.difference(DateTime.now()).inDays;
  }

  bool get isNearExpiration {
    return daysUntilExpiration <= 7 && daysUntilExpiration >= 0;
  }

  String get statusMessage {
    switch (status) {
      case 'trialing':
        return 'Período de teste';
      case 'active':
        return 'Ativa';
      case 'past_due':
        return 'Pagamento pendente';
      case 'expired':
        return 'Expirada';
      case 'canceled':
        return 'Cancelada';
      default:
        return status;
    }
  }

  String get statusColor {
    switch (status) {
      case 'trialing':
        return '#2196F3';
      case 'active':
        return '#4CAF50';
      case 'past_due':
        return '#FF9800';
      case 'expired':
        return '#F44336';
      case 'canceled':
        return '#9E9E9E';
      default:
        return '#000000';
    }
  }

  @override
  String toString() =>
      'Subscription(id: $id, status: $status, isBlocked: $isBlocked, hasPayment: $hasPaymentMethod)';
}