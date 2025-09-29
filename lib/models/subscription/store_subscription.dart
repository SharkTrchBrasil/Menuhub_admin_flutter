// lib/models/store_subscription.dart

import 'package:totem_pro_admin/models/plans/plans.dart';


import '../plans/plans_addon.dart';

class StoreSubscription {
  final int id;
  final String status;
  final DateTime currentPeriodStart;
  final DateTime currentPeriodEnd;
  final Plans plan;
  final List<PlansAddon> subscribedAddons;

  const StoreSubscription({
    required this.id,
    required this.status,
    required this.currentPeriodStart,
    required this.currentPeriodEnd,
    required this.plan,
    required this.subscribedAddons,
  });

  factory StoreSubscription.fromJson(Map<String, dynamic> json) {
    return StoreSubscription(
      id: json['id'],
      status: json['status'],
      currentPeriodStart: DateTime.parse(json['current_period_start']),
      currentPeriodEnd: DateTime.parse(json['current_period_end']),
      plan: Plans.fromJson(json['plan']),
      subscribedAddons: (json['subscribed_addons'] as List<dynamic>? ?? [])
          .map((addonJson) => PlansAddon.fromJson(addonJson))
          .toList(),
    );
  }

  StoreSubscription copyWith({
    int? id,
    String? status,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    Plans? plan,
    List<PlansAddon>? subscribedAddons,
  }) {
    return StoreSubscription(
      id: id ?? this.id,
      status: status ?? this.status,
      currentPeriodStart: currentPeriodStart ?? this.currentPeriodStart,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      plan: plan ?? this.plan,
      subscribedAddons: subscribedAddons ?? this.subscribedAddons,
    );
  }
}