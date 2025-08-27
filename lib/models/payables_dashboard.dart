// lib/models/payables_dashboard.dart

// Modelo para uma única conta a pagar na lista "próximas a vencer"
class PayableResponseModel {
  final int id;
  final String title;
  final int amount; // Em centavos
  final int finalAmount; // Em centavos
  final DateTime dueDate;
  final String status;

  PayableResponseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.finalAmount,
    required this.dueDate,
    required this.status,
  });

  factory PayableResponseModel.fromJson(Map<String, dynamic> json) {
    return PayableResponseModel(
      id: json['id'],
      title: json['title'],
      amount: json['amount'],
      finalAmount: json['final_amount'],
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
    );
  }
}

// Modelo principal para as métricas do dashboard de contas a pagar
class PayablesDashboardMetrics {
  final int totalPending; // Em centavos
  final int totalOverdue; // Em centavos
  final int totalPaidMonth; // Em centavos
  final int pendingCount;
  final int overdueCount;
  final List<PayableResponseModel> nextDuePayables;

  PayablesDashboardMetrics({
    required this.totalPending,
    required this.totalOverdue,
    required this.totalPaidMonth,
    required this.pendingCount,
    required this.overdueCount,
    required this.nextDuePayables,
  });

  factory PayablesDashboardMetrics.fromJson(Map<String, dynamic> json) {
    var payablesList = json['next_due_payables'] as List;
    List<PayableResponseModel> duePayables = payablesList
        .map((i) => PayableResponseModel.fromJson(i))
        .toList();

    return PayablesDashboardMetrics(
      totalPending: json['total_pending'],
      totalOverdue: json['total_overdue'],
      totalPaidMonth: json['total_paid_month'],
      pendingCount: json['pending_count'],
      overdueCount: json['overdue_count'],
      nextDuePayables: duePayables,
    );
  }
}