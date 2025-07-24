class SubscriptionSummary {
  final int planId; // 👈 novo campo
  final String planName;
  final String status;
  final DateTime? expiryDate;
  final List<String> features;
  final String? warningMessage;

  const SubscriptionSummary({
    required this.planId,
    required this.planName,
    required this.status,
    this.expiryDate,
    required this.features,
    this.warningMessage,
  });

  factory SubscriptionSummary.fromJson(Map<String, dynamic> json) {
    return SubscriptionSummary(
      planId: json['plan_id'] ?? 0, // 👈 novo campo
      planName: json['plan_name'] ?? 'N/A',
      status: json['status'] ?? 'unknown',
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      features: (json['features'] as List<dynamic>? ?? [])
          .map((feature) => feature.toString())
          .toList(),
      warningMessage: json['warning_message'],
    );
  }
}
