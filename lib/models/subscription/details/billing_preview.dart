import 'package:equatable/equatable.dart';

/// Preview de faturamento atual e projetado
class BillingPreview extends Equatable {
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
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      revenueSoFar: (json['revenue_so_far'] as num).toDouble(),
      ordersSoFar: json['orders_so_far'] as int,
      feeSoFar: (json['fee_so_far'] as num).toDouble(),
      projectedRevenue: (json['projected_revenue'] as num).toDouble(),
      projectedFee: (json['projected_fee'] as num).toDouble(),
    );
  }

  /// Percentual de taxa efetiva atual
  double get currentRate {
    if (revenueSoFar == 0) return 0;
    return (feeSoFar / revenueSoFar) * 100;
  }

  /// Percentual de taxa efetiva projetada
  double get projectedRate {
    if (projectedRevenue == 0) return 0;
    return (projectedFee / projectedRevenue) * 100;
  }

  /// Dias restantes no período
  int get daysRemaining {
    return periodEnd.difference(DateTime.now()).inDays;
  }

  /// Dias totais no período
  int get totalDays {
    return periodEnd.difference(periodStart).inDays;
  }

  /// Percentual do período que já passou
  double get periodProgress {
    final daysPassed = DateTime.now().difference(periodStart).inDays;
    return (daysPassed / totalDays).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
    periodStart,
    periodEnd,
    revenueSoFar,
    ordersSoFar,
    feeSoFar,
    projectedRevenue,
    projectedFee,
  ];
}