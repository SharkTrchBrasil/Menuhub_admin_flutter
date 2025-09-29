// lib/models/plans/plans.dart

import 'package:flutter/foundation.dart';
import 'package:totem_pro_admin/models/feature.dart';

class Plans {
  final int id;
  final String planName;
  final bool available;
  final String? supportType;

  // --- ESTRUTURA DE PREÇOS DINÂMICOS ---
  final int minimumFee; // Em centavos
  final double revenuePercentage; // Ex: 0.029 para 2.9%
  final int? revenueCapFee; // Em centavos
  final int? percentageTierStart; // Em centavos
  final int? percentageTierEnd; // Em centavos

  // --- BENEFÍCIOS PROMOCIONAIS ---
  final bool firstMonthFree;
  final double secondMonthDiscount; // Ex: 0.50 para 50%
  final double thirdMonthDiscount; // Ex: 0.75 para 25%

  // --- FEATURES ---
  final List<Feature> features;

  const Plans({
    required this.id,
    required this.planName,
    required this.available,
    this.supportType,
    required this.minimumFee,
    required this.revenuePercentage,
    this.revenueCapFee,
    this.percentageTierStart,
    this.percentageTierEnd,
    required this.firstMonthFree,
    required this.secondMonthDiscount,
    required this.thirdMonthDiscount,
    required this.features,
  });

  factory Plans.fromJson(Map<String, dynamic> json) {
    // Função auxiliar para converter de forma segura
    double safeParseDouble(dynamic value) {
      if (value is num) {
        return value.toDouble();
      } else if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return Plans(
      id: json['id'] ?? 0,
      planName: json['plan_name'] ?? '',
      available: json['available'] ?? true,
      supportType: json['support_type'],
      minimumFee: json['minimum_fee'] ?? 0,
      revenuePercentage: safeParseDouble(json['revenue_percentage']),
      revenueCapFee: json['revenue_cap_fee'],
      percentageTierStart: json['percentage_tier_start'],
      percentageTierEnd: json['percentage_tier_end'],
      firstMonthFree: json['first_month_free'] ?? false,
      secondMonthDiscount: safeParseDouble(json['second_month_discount']),
      thirdMonthDiscount: safeParseDouble(json['third_month_discount']),
      features: (json['features'] as List<dynamic>? ?? [])
          .map((featureJson) => Feature.fromJson(featureJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plan_name': planName,
      'available': available,
      'support_type': supportType,
      'minimum_fee': minimumFee,
      'revenue_percentage': revenuePercentage,
      'revenue_cap_fee': revenueCapFee,
      'percentage_tier_start': percentageTierStart,
      'percentage_tier_end': percentageTierEnd,
      'first_month_free': firstMonthFree,
      'second_month_discount': secondMonthDiscount,
      'third_month_discount': thirdMonthDiscount,
      'features': features.map((feature) => feature.toJson()).toList(),
    };
  }

  Plans copyWith({
    int? id,
    String? planName,
    bool? available,
    String? supportType,
    int? minimumFee,
    double? revenuePercentage,
    int? revenueCapFee,
    int? percentageTierStart,
    int? percentageTierEnd,
    bool? firstMonthFree,
    double? secondMonthDiscount,
    double? thirdMonthDiscount,
    List<Feature>? features,
  }) {
    return Plans(
      id: id ?? this.id,
      planName: planName ?? this.planName,
      available: available ?? this.available,
      supportType: supportType ?? this.supportType,
      minimumFee: minimumFee ?? this.minimumFee,
      revenuePercentage: revenuePercentage ?? this.revenuePercentage,
      revenueCapFee: revenueCapFee ?? this.revenueCapFee,
      percentageTierStart: percentageTierStart ?? this.percentageTierStart,
      percentageTierEnd: percentageTierEnd ?? this.percentageTierEnd,
      firstMonthFree: firstMonthFree ?? this.firstMonthFree,
      secondMonthDiscount: secondMonthDiscount ?? this.secondMonthDiscount,
      thirdMonthDiscount: thirdMonthDiscount ?? this.thirdMonthDiscount,
      features: features ?? this.features,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Plans &&
        other.id == id &&
        other.planName == planName &&
        other.available == available &&
        other.supportType == supportType &&
        other.minimumFee == minimumFee &&
        other.revenuePercentage == revenuePercentage &&
        other.revenueCapFee == revenueCapFee &&
        other.percentageTierStart == percentageTierStart &&
        other.percentageTierEnd == percentageTierEnd &&
        other.firstMonthFree == firstMonthFree &&
        other.secondMonthDiscount == secondMonthDiscount &&
        other.thirdMonthDiscount == thirdMonthDiscount &&
        listEquals(other.features, features);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      planName,
      available,
      supportType,
      minimumFee,
      revenuePercentage,
      revenueCapFee,
      percentageTierStart,
      percentageTierEnd,
      firstMonthFree,
      secondMonthDiscount,
      thirdMonthDiscount,
      Object.hashAll(features),
    );
  }

  @override
  String toString() {
    return 'Plans{id: $id, planName: $planName, available: $available, supportType: $supportType, minimumFee: $minimumFee, revenuePercentage: $revenuePercentage, revenueCapFee: $revenueCapFee, percentageTierStart: $percentageTierStart, percentageTierEnd: $percentageTierEnd, firstMonthFree: $firstMonthFree, secondMonthDiscount: $secondMonthDiscount, thirdMonthDiscount: $thirdMonthDiscount, features: $features}';
  }
}