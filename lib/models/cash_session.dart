class CashierSession {
  final int? id;

  final int userOpenedId;

  final int? userClosedId;
  final DateTime openedAt;
  final DateTime? closedAt;
  final double openingAmount;
  final double cashAdded;
  final double cashRemoved;



  final double cashDifference;
  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  CashierSession(


       {
    this.id,

         required this.userOpenedId,

    this.userClosedId,
    required this.openedAt,
    this.closedAt,
    required this.openingAmount,
    required this.cashAdded,
    required this.cashRemoved,

    required this.cashDifference,
    required this.status,

    this.createdAt,
    this.updatedAt,
  });

  factory CashierSession.fromJson(Map<String, dynamic> json) {

    return CashierSession(
      id: json['id'],

      userOpenedId: json['user_opened_id'],
      userClosedId: json['user_closed_id'],
      openedAt: DateTime.parse(json['opened_at']),
      closedAt: json['closed_at'] != null ? DateTime.parse(json['closed_at']) : null,

      openingAmount: (json['opening_amount'] ?? 0) is num ? (json['opening_amount'] as num).toDouble() : 0.0,
      cashAdded: (json['cash_added'] ?? 0) is num ? (json['cash_added'] as num).toDouble() : 0.0,
      cashRemoved: (json['cash_removed'] ?? 0) is num ? (json['cash_removed'] as num).toDouble() : 0.0,

      cashDifference: (json['cash_difference'] ?? 0) is num ? (json['cash_difference'] as num).toDouble() : 0.0,




      status: json['status'],

      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,


    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      if (id != null) 'id': id,

      'user_opened_id': userOpenedId,
      'user_closed_id': userClosedId,
      'opened_at': openedAt.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'opening_amount': openingAmount,
      'cash_added': cashAdded,
      'cash_removed': cashRemoved,



      'cash_difference': cashDifference,
      'status': status,

      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
    return map;
  }
}
