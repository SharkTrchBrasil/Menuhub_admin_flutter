// lib/models/plans_addon.dart

import 'package:totem_pro_admin/models/feature.dart';

class PlansAddon {
  final int id;
  final int priceAtSubscription;
  final DateTime subscribedAt;
  final Feature feature;

  const PlansAddon({
    required this.id,
    required this.priceAtSubscription,
    required this.subscribedAt,
    required this.feature,
  });

  factory PlansAddon.fromJson(Map<String, dynamic> json) {
    return PlansAddon(
      id: json['id'],
      priceAtSubscription: json['price_at_subscription'],
      subscribedAt: DateTime.parse(json['subscribed_at']),
      feature: Feature.fromJson(json['feature']),
    );
  }

  PlansAddon copyWith({
    int? id,
    int? priceAtSubscription,
    DateTime? subscribedAt,
    Feature? feature,
  }) {
    return PlansAddon(
      id: id ?? this.id,
      priceAtSubscription: priceAtSubscription ?? this.priceAtSubscription,
      subscribedAt: subscribedAt ?? this.subscribedAt,
      feature: feature ?? this.feature,
    );
  }
}