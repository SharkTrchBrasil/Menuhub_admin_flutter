// lib/models/holiday.dart

class Holiday {
  final DateTime date;
  final String name;

  Holiday({required this.date, required this.name});

  factory Holiday.fromJson(Map<String, dynamic> json) {
    return Holiday(
      date: DateTime.parse(json['date']),
      name: json['name'],
    );
  }
}