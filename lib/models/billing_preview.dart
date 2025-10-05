class BillingPreview {
  final DateTime periodStart;
  final DateTime periodEnd;
  final double revenueSoFar;
  final int ordersSoFar;
  final double feeSoFar;
  final double projectedRevenue;
  final double projectedFee;

  const BillingPreview({
    required this.periodStart,
    required this.periodEnd,
    required this.revenueSoFar,
    required this.ordersSoFar,
    required this.feeSoFar,
    required this.projectedRevenue,
    required this.projectedFee,
  });

  factory BillingPreview.fromJson(Map<String, dynamic> json) {
    return BillingPreview(
      periodStart: DateTime.tryParse(json['period_start'] ?? '') ?? DateTime.now(),
      periodEnd: DateTime.tryParse(json['period_end'] ?? '') ?? DateTime.now(),
      revenueSoFar: (json['revenue_so_far'] as num?)?.toDouble() ?? 0.0,
      ordersSoFar: json['orders_so_far'] as int? ?? 0,
      feeSoFar: (json['fee_so_far'] as num?)?.toDouble() ?? 0.0,
      projectedRevenue: (json['projected_revenue'] as num?)?.toDouble() ?? 0.0,
      projectedFee: (json['projected_fee'] as num?)?.toDouble() ?? 0.0,
    );
  }
}