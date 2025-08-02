class SubscriptionSummary {
  // --- Campos Básicos da Assinatura ---
  final int planId;
  final String planName;
  final String status;
  final DateTime? expiryDate;
  final List<String> features;
  final String? warningMessage;

  // --- NOVOS CAMPOS: Limites e Benefícios do Plano ---
  // Um valor nulo (null) significa "ilimitado".
  final int? productLimit;
  final int? categoryLimit;
  final int? userLimit;
  final int? monthlyOrderLimit;
  final int? locationLimit;
  final int? bannerLimit;
  final int? maxActiveDevices;
  final String? supportType;

  const SubscriptionSummary({
    required this.planId,
    required this.planName,
    required this.status,
    this.expiryDate,
    required this.features,
    this.warningMessage,
    // Adiciona os novos campos ao construtor
    this.productLimit,
    this.categoryLimit,
    this.userLimit,
    this.monthlyOrderLimit,
    this.locationLimit,
    this.bannerLimit,
    this.maxActiveDevices,
    this.supportType,
  });

  factory SubscriptionSummary.fromJson(Map<String, dynamic> json) {
    // A API pode retornar os detalhes do plano aninhados ou não.
    // Esta abordagem lida com ambos os casos.
    final planData = json['plan'] as Map<String, dynamic>? ?? json;

    // ✅ CORREÇÃO APLICADA AQUI
    // A lista de features vem do JSON principal, como uma lista de strings.
    final featuresList = (json['features'] as List<dynamic>? ?? [])
        .map((feature) => feature.toString())
        .toList();

    return SubscriptionSummary(
      planId: json['plan_id'] ?? 0,
      planName: json['plan_name'] ?? 'N/A',
      status: json['status'] ?? 'unknown',
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,

      features: featuresList, // <-- Usa a lista corrigida

      warningMessage: json['warning_message'],

      // Os limites continuam sendo lidos do planData para flexibilidade
      productLimit: planData['product_limit'],
      categoryLimit: planData['category_limit'],
      userLimit: planData['user_limit'],
      monthlyOrderLimit: planData['monthly_order_limit'],
      locationLimit: planData['location_limit'],
      bannerLimit: planData['banner_limit'],
      maxActiveDevices: planData['max_active_devices'],
      supportType: planData['support_type'],
    );
  }
}
