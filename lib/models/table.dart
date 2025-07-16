class Table {
  final int id;
  final int storeId;
  final String name;
  final String status; // Pode criar enum também se quiser
  final int maxCapacity;
  final int currentCapacity;
  final DateTime openedAt;
  final DateTime? closedAt;
  final bool isDeleted;
  final DateTime? deletedAt;
  final String? locationDescription;

  Table({
    required this.id,
    required this.storeId,
    required this.name,
    required this.status,
    required this.maxCapacity,
    required this.currentCapacity,
    required this.openedAt,
    this.closedAt,
    required this.isDeleted,
    this.deletedAt,
    this.locationDescription,
  });

  factory Table.fromJson(Map<String, dynamic> json) => Table(
    id: json['id'],
    storeId: json['store_id'],
    name: json['name'],
    status: json['status'],
    maxCapacity: json['max_capacity'],
    currentCapacity: json['current_capacity'],
    openedAt: DateTime.parse(json['opened_at']),
    closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at']) : null,
    isDeleted: json['is_deleted'],
    deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    locationDescription: json['location_description'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'store_id': storeId,
    'name': name,
    'status': status,
    'max_capacity': maxCapacity,
    'current_capacity': currentCapacity,
    'opened_at': openedAt.toIso8601String(),
    'closed_at': closedAt?.toIso8601String(),
    'is_deleted': isDeleted,
    'deleted_at': deletedAt?.toIso8601String(),
    'location_description': locationDescription,
  };
}