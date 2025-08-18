// lib/models/scheduled_pause.dart
class ScheduledPause {
  final int id;
  final String? reason;
  final DateTime startTime;
  final DateTime endTime;

  ScheduledPause({
    required this.id,
    this.reason,
    required this.startTime,
    required this.endTime,
  });

  factory ScheduledPause.fromJson(Map<String, dynamic> json) {
    return ScheduledPause(
      id: json['id'],
      reason: json['reason'],
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
    );
  }
}