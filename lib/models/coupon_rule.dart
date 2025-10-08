// lib/models/coupon_rule.dart
class CouponRule {
  CouponRule({
    required this.ruleType,
    required this.value,
  });

  final String ruleType;
  final Map<String, dynamic> value;

  factory CouponRule.fromJson(Map<String, dynamic> json) {
    return CouponRule(
      // A chave no JSON do backend é 'ruleType'
      ruleType: json['ruleType'] as String? ?? '',
      value: json['value'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // Enviamos para o backend como 'ruleType'
      'ruleType': ruleType,
      'value': value,
    };
  }
}