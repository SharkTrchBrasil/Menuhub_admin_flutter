// lib/models/tables/command.dart

import 'command_item.dart';

class Command {
  final int id;
  final int? storeId;  // ✅ MUDOU PARA OPCIONAL
  final int? tableId;
  final String? customerName;
  final String? customerContact;
  final String status;
  final int? attendantId;
  final String? notes;
  final DateTime? createdAt;  // ✅ TAMBÉM OPCIONAL
  final DateTime? updatedAt;   // ✅ TAMBÉM OPCIONAL
  final String? tableName;
  final int totalAmount;
  final List<CommandItem> items;

  Command({
    required this.id,
    this.storeId,  // ✅ REMOVIDO required
    this.tableId,
    this.customerName,
    this.customerContact,
    required this.status,
    this.attendantId,
    this.notes,
    this.createdAt,  // ✅ REMOVIDO required
    this.updatedAt,  // ✅ REMOVIDO required
    this.tableName,
    this.totalAmount = 0,
    this.items = const [],
  });

  factory Command.fromJson(Map<String, dynamic> json) {
    print('🔥🔥🔥 [COMMAND] Parseando JSON: $json');

    // ✅ CORREÇÃO: Parse seguro de datas
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          print('⚠️ [COMMAND] Erro ao parsear data: $value');
          return null;
        }
      }
      return null;
    }
    final itemsJson = json['items'] as List? ?? [];

    final items = itemsJson
        .map((item) => CommandItem.fromJson(item))
        .toList();

    final command = Command(
      id: json['id'],
      storeId: json['store_id'],  // ✅ Pode ser null
      tableId: json['table_id'],
      customerName: json['customer_name'],
      customerContact: json['customer_contact'],
      status: json['status'] ?? 'ACTIVE',  // ✅ Fallback
      attendantId: json['attendant_id'],
      notes: json['notes'],
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      tableName: json['table_name'],
      totalAmount: json['total_amount'] ?? 0,
      items: items,  // ✅ NOVO
        // ✅ Parse dos itens

    );

    print('🔥🔥🔥 [COMMAND] Comando criado: ID ${command.id}, Nome: ${command.customerName}');
    return command;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'store_id': storeId,
    'table_id': tableId,
    'customer_name': customerName,
    'customer_contact': customerContact,
    'status': status,
    'attendant_id': attendantId,
    'notes': notes,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'table_name': tableName,
    'total_amount': totalAmount,
  };

  bool get isActive => status == 'ACTIVE';
  bool get isClosed => status == 'CLOSED';
  bool get isStandalone => tableId == null;

  // ✅ NOVOS HELPERS
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
  double get totalInReais => totalAmount / 100;
  bool get hasItems => items.isNotEmpty;
}