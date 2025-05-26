class Totem {
  Totem({required this.id, required this.name, required this.createdAt});

  final int id;
  final String name;
  final DateTime createdAt;

  factory Totem.fromJson(Map<String, dynamic> json) {
    return Totem(
      id: json['id'] as int,
      name: json['totem_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
