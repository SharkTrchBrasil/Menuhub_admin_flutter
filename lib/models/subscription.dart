// lib/models/subscription.dart

// Classe auxiliar para as regras de preço
class PricingRules {
  final int minimumFee;
  final double revenuePercentage;
  final int? revenueCapFee;
  final int? percentageTierStart;
  final int? percentageTierEnd;

  const PricingRules({
    required this.minimumFee,
    required this.revenuePercentage,
    this.revenueCapFee,
    this.percentageTierStart,
    this.percentageTierEnd,
  });

  factory PricingRules.fromJson(Map<String, dynamic> json) {
    return PricingRules(
      minimumFee: json['minimum_fee'] ?? 0,
      revenuePercentage: (json['revenue_percentage'] as num?)?.toDouble() ?? 0.0,
      revenueCapFee: json['revenue_cap_fee'],
      percentageTierStart: json['percentage_tier_start'],
      percentageTierEnd: json['percentage_tier_end'],
    );
  }
}

class Subscription {
  final int planId;
  final String planName;
  // Status dinâmicos: 'active', 'warning', 'past_due', 'expired', 'inactive'
  final String status;
  final bool isBlocked;
  final String? warningMessage;
  // Apenas as chaves das features, para verificações rápidas
  final List<String> features;
  final PricingRules pricingRules;

  const Subscription({
    required this.planId,
    required this.planName,
    required this.status,
    required this.isBlocked,
    this.warningMessage,
    required this.features,
    required this.pricingRules,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      planId: json['plan_id'] ?? 0,
      planName: json['plan_name'] ?? 'N/A',
      status: json['status'] ?? 'inactive',
      isBlocked: json['is_blocked'] ?? true,
      warningMessage: json['warning_message'],
      features: List<String>.from(json['features'] ?? []),
      pricingRules: PricingRules.fromJson(json['pricing_rules'] ?? {}),
    );
  }


  // ✅ ADICIONANDO copyWith PARA BOAS PRÁTICAS
  Subscription copyWith({
    int? planId,
    String? planName,
    String? status,
    bool? isBlocked,
    String? warningMessage,
    List<String>? features,
    PricingRules? pricingRules,
  }) {
    return Subscription(
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      status: status ?? this.status,
      isBlocked: isBlocked ?? this.isBlocked,
      // Para o warningMessage, permite definir como nulo
      warningMessage: warningMessage,
      features: features ?? this.features,
      pricingRules: pricingRules ?? this.pricingRules,
    );
  }


// Implemente copyWith, == e hashCode para consistência, se necessário
}




extension SubscriptionAccess on Subscription {
  /// Verifica se a assinatura atual dá acesso a uma funcionalidade específica (feature).
  /// Retorna `false` se a assinatura não estiver ativa.
  bool canAccess(String featureKey) {
    // O acesso só é válido se o status for 'active' (ou 'warning')
    // e a feature estiver na lista.
    if (status != 'active' && status != 'warning') {
      return false;
    }
    return features.contains(featureKey);
  }
}