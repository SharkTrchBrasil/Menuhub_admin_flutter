class CouponRule {
  CouponRule({
    required this.ruleType,
    required this.value,
  });

  final String ruleType;
  final Map<String, dynamic> value;

  factory CouponRule.fromJson(Map<String, dynamic> json) {
    return CouponRule(
      // ✅ CORREÇÃO:
      // Pega o valor de 'ruleType'. Se for nulo, usa uma string vazia '' como padrão.
      ruleType: json['ruleType'] as String? ?? '',

      // ✅ BOA PRÁTICA: Adicionar a mesma segurança para o campo 'value'.
      // Pega o valor de 'value'. Se for nulo, usa um mapa vazio {} como padrão.
      value: json['value'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ruleType': ruleType,
      'value': value,
    };
  }
}