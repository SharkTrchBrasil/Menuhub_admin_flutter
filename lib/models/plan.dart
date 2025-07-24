// lib/models/plan.dart

import 'package:totem_pro_admin/models/feature.dart';

class Plan {
  final int id;
  final String planName;
  final int price;
  final int interval;
  final bool available;
  final List<Feature> features; // O backend já unifica e manda a lista de features

  const Plan({
    required this.id,
    required this.planName,
    required this.price,
    required this.interval,
    required this.available,
    required this.features,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'],
      planName: json['plan_name'],
      price: json['price'],
      interval: json['interval'],
      available: json['available'] ?? true,
      // Converte a lista de JSONs de features em uma lista de objetos Feature
      features: (json['included_features'] as List<dynamic>? ?? [])
          .map((featureJson) => Feature.fromJson(featureJson['feature']))
          .toList(),
    );
  }

  Plan copyWith({
    int? id,
    String? planName,
    int? price,
    int? interval,
    bool? available,
    List<Feature>? features,
  }) {
    return Plan(
      id: id ?? this.id,
      planName: planName ?? this.planName,
      price: price ?? this.price,
      interval: interval ?? this.interval,
      available: available ?? this.available,
      features: features ?? this.features,
    );
  }
}