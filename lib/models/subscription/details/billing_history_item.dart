import 'package:equatable/equatable.dart';

/// Item de histórico de cobrança
class BillingHistoryItem extends Equatable {
  final String period;
  final double revenue;
  final double fee;
  final double rate;
  final String status;
  final String chargeDate;
  final String? benefitType;

  const BillingHistoryItem({
    required this.period,
    required this.revenue,
    required this.fee,
    required this.rate,
    required this.status,
    required this.chargeDate,
    this.benefitType,
  });

  factory BillingHistoryItem.fromJson(Map<String, dynamic> json) {
    return BillingHistoryItem(
      period: json['period'] as String,
      revenue: (json['revenue'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      status: json['status'] as String,
      chargeDate: json['charge_date'] as String,
      benefitType: json['benefit_type'] as String?,
    );
  }

  /// Cor do status
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'paid':
        return '#4CAF50';
      case 'pending':
        return '#FF9800';
      case 'failed':
        return '#F44336';
      default:
        return '#9E9E9E';
    }
  }

  /// Label amigável do status
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'paid':
        return 'Pago';
      case 'pending':
        return 'Pendente';
      case 'failed':
        return 'Falhou';
      default:
        return status;
    }
  }

  /// Se teve benefício aplicado
  bool get hasBenefit => benefitType != null && benefitType!.isNotEmpty;

  @override
  List<Object?> get props => [
    period,
    revenue,
    fee,
    rate,
    status,
    chargeDate,
    benefitType,
  ];
}