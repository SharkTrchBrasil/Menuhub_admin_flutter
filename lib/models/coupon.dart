import 'package:totem_pro_admin/models/coupon_rule.dart'; // ✅ Importe o novo modelo

class Coupon {
  Coupon({
    this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    this.maxDiscountAmount,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.rules = const [], // ✅ ADICIONADO: Lista de regras
  });

  final int? id;
  final String code;
  final String description; // ✅ ADICIONADO
  final String discountType; // 'PERCENTAGE', 'FIXED_AMOUNT', 'FREE_DELIVERY'
  final double discountValue; // ✅ ALTERADO para double para consistência
  final int? maxDiscountAmount; // ✅ ADICIONADO (em centavos)
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final List<CouponRule> rules; // ✅ ADICIONADO

  // ❌ CAMPOS REMOVIDOS:
  // maxUses, used, maxUsesPerCustomer, minOrderValue, onlyFirstPurchase, product
  // Tudo isso agora está dentro da lista 'rules'!

  factory Coupon.fromJson(Map<String, dynamic> json) {
    // Lógica para parsear a lista de regras do JSON
    var rulesList = <CouponRule>[];
    if (json['rules'] != null && json['rules'] is List) {
      rulesList = (json['rules'] as List)
          .map((ruleJson) => CouponRule.fromJson(ruleJson))
          .toList();
    }

    return Coupon(
      id: json['id'] as int?,

      // ✅ CORREÇÃO APLICADA AQUI
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      discountType: json['discountType'] as String? ?? 'FIXED_AMOUNT', // Padrão seguro


      // O 'as num? ?? 0' é para o caso do valor ser nulo
      discountValue: (json['discountValue'] as num? ?? 0).toDouble(),

      maxDiscountAmount: json['maxDiscountAmount'] as int?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      rules: rulesList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'maxDiscountAmount': maxDiscountAmount,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'rules': rules.map((rule) => rule.toJson()).toList(),
    };
  }

  // ✅ ADICIONADO: Método copyWith completo para imutabilidade.
  Coupon copyWith({
    int? id,
    String? code,
    String? description,
    String? discountType,
    double? discountValue,
    int? maxDiscountAmount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    List<CouponRule>? rules,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      rules: rules ?? this.rules,
    );
  }


  // --- GETTERS AUXILIARES ---
  int? get minOrderValue {
    try {
      final rule = rules.firstWhere((r) => r.ruleType == 'MIN_SUBTOTAL');
      return rule.value['value'] as int?;
    } catch (e) {
      return null;
    }
  }

  bool get isForFirstOrder {
    return rules.any((r) => r.ruleType == 'FIRST_ORDER');
  }

  int? get maxUsesPerCustomer {
    try {
      final rule = rules.firstWhere((r) => r.ruleType == 'MAX_USES_PER_CUSTOMER');
      return rule.value['limit'] as int?;
    } catch (e) {
      return null;
    }
  }

  // ✅ ADICIONADO: Getter para usos totais, para consistência.
  int? get maxUsesTotal {
    try {
      final rule = rules.firstWhere((r) => r.ruleType == 'MAX_USES_TOTAL');
      return rule.value['limit'] as int?;
    } catch (e) {
      return null;
    }
  }

  int? get targetProductId {
    try {
      final rule = rules.firstWhere((r) => r.ruleType == 'TARGET_PRODUCT');
      return rule.value['product_id'] as int?;
    } catch (e) {
      return null;
    }
  }
}