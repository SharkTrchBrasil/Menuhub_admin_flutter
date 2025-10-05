// lib/models/subscription.dart (Anteriormente subscription.dart)
import 'package:equatable/equatable.dart';
import 'package:totem_pro_admin/models/plans/plans.dart';
import 'package:totem_pro_admin/models/plans/plans_addon.dart';

class Subscription extends Equatable {
  final int id;
  final String status;
  final bool isBlocked;
  final String? warningMessage;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final Plans? plan;
  final List<PlansAddon> subscribedAddons;

  const Subscription({
    required this.id,
    required this.status,
    required this.isBlocked,
    this.warningMessage,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    this.plan,
    required this.subscribedAddons,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as int,
      status: json['status'] as String,
      // ✅✅✅ CORREÇÃO DE SEGURANÇA ✅✅✅
      // Se 'is_blocked' for nulo, assume 'true' como padrão de segurança.
      isBlocked: json['is_blocked'] as bool? ?? true,
      warningMessage: json['warning_message'] as String?,
      currentPeriodStart: DateTime.parse(json['current_period_start'] as String),
      currentPeriodEnd: DateTime.parse(json['current_period_end'] as String),
      plan: json['plan'] != null ? Plans.fromJson(json['plan']) : null,
      subscribedAddons: (json['subscribed_addons'] as List<dynamic>?)
          ?.map((e) => PlansAddon.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  @override
  List<Object?> get props => [
    id,
    status,
    isBlocked,
    warningMessage,
    currentPeriodStart,
    currentPeriodEnd,
    plan,
    subscribedAddons
  ];
}