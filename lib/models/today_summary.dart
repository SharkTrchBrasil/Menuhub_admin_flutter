class TodaySummary {
  final int completedSales;
  final double totalValue;
  final double averageTicket;

  TodaySummary({required this.completedSales, required this.totalValue, required this.averageTicket});

  factory TodaySummary.fromJson(Map<String, dynamic> json) {
    return TodaySummary(
      completedSales: json['completed_sales'],
      totalValue: (json['total_value'] as num).toDouble(),
      averageTicket: (json['average_ticket'] as num).toDouble(),
    );
  }
}