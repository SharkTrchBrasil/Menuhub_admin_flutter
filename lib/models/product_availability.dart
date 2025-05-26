class ProductAvailability {
  final int? id;
  final int weekday; // 0 = domingo, 6 = sábado
  final String startTime; // formato: "08:00:00"
  final String endTime;

  ProductAvailability({
    this.id,
    required this.weekday,
    required this.startTime,
    required this.endTime,
  });

  factory ProductAvailability.fromJson(Map<String, dynamic> json) {
    return ProductAvailability(
      id: json['id'],
      weekday: json['weekday'],
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekday': weekday,
      'start_time': startTime,
      'end_time': endTime,
    };
  }
}
