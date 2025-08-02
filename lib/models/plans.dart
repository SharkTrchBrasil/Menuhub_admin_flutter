// lib/models/plans.dart

import 'package:totem_pro_admin/models/feature.dart';

class Plans {
  final int id;
  final String planName;
  final int price;
  final int interval;
  final bool available;
  final List<Feature> features;

  // ✅ CAMPOS DE LIMITE E OUTROS ADICIONADOS
  final int? repeats;
  final int? productLimit;
  final int? categoryLimit;
  final int? userLimit;
  final int? monthlyOrderLimit;
  final int? locationLimit;
  final int? bannerLimit;
  final int? maxActiveDevices;
  final String? supportType;

  const Plans({
    required this.id,
    required this.planName,
    required this.price,
    required this.interval,
    required this.available,
    required this.features,

    // ✅ ADICIONADOS AO CONSTRUTOR
    this.repeats,
    this.productLimit,
    this.categoryLimit,
    this.userLimit,
    this.monthlyOrderLimit,
    this.locationLimit,
    this.bannerLimit,
    this.maxActiveDevices,
    this.supportType,
  });

  factory Plans.fromJson(Map<String, dynamic> json) {
    return Plans(
      id: json['id'],
      planName: json['plan_name'],
      price: json['price'],
      interval: json['interval'],
      available: json['available'] ?? true,

      // Converte a lista de JSONs de features em uma lista de objetos Feature
      features: (json['included_features'] as List<dynamic>? ?? [])
          .map((featureJson) => Feature.fromJson(featureJson['feature']))
          .toList(),

      // ✅ MAPEAMENTO DOS NOVOS CAMPOS A PARTIR DO JSON
      repeats: json['repeats'],
      productLimit: json['product_limit'],
      categoryLimit: json['category_limit'],
      userLimit: json['user_limit'],
      monthlyOrderLimit: json['monthly_order_limit'],
      locationLimit: json['location_limit'],
      bannerLimit: json['banner_limit'],
      maxActiveDevices: json['max_active_devices'],
      supportType: json['support_type'],
    );
  }

  Plans copyWith({
    int? id,
    String? planName,
    int? price,
    int? interval,
    bool? available,
    List<Feature>? features,

    // ✅ ADICIONADOS AO `copyWith`
    int? repeats,
    int? productLimit,
    int? categoryLimit,
    int? userLimit,
    int? monthlyOrderLimit,
    int? locationLimit,
    int? bannerLimit,
    int? maxActiveDevices,
    String? supportType,
  }) {
    return Plans(
      id: id ?? this.id,
      planName: planName ?? this.planName,
      price: price ?? this.price,
      interval: interval ?? this.interval,
      available: available ?? this.available,
      features: features ?? this.features,

      // ✅ ATUALIZAÇÃO DOS NOVOS CAMPOS
      repeats: repeats ?? this.repeats,
      productLimit: productLimit ?? this.productLimit,
      categoryLimit: categoryLimit ?? this.categoryLimit,
      userLimit: userLimit ?? this.userLimit,
      monthlyOrderLimit: monthlyOrderLimit ?? this.monthlyOrderLimit,
      locationLimit: locationLimit ?? this.locationLimit,
      bannerLimit: bannerLimit ?? this.bannerLimit,
      maxActiveDevices: maxActiveDevices ?? this.maxActiveDevices,
      supportType: supportType ?? this.supportType,
    );
  }
}