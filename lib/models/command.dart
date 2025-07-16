class Command {
  final int id;
  final int storeId;
  final int? tableId;
  final String? customerName;
  final String? customerContact;
  final String status; // Pode criar enum também
  final int? attendantId;
  final String? notes;

  Command({
    required this.id,
    required this.storeId,
    this.tableId,
    this.customerName,
    this.customerContact,
    required this.status,
    this.attendantId,
    this.notes,
  });

  factory Command.fromJson(Map<String, dynamic> json) => Command(
    id: json['id'],
    storeId: json['store_id'],
    tableId: json['table_id'],
    customerName: json['customer_name'],
    customerContact: json['customer_contact'],
    status: json['status'],
    attendantId: json['attendant_id'],
    notes: json['notes'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'store_id': storeId,
    'table_id': tableId,
    'customer_name': customerName,
    'customer_contact': customerContact,
    'status': status,
    'attendant_id': attendantId,
    'notes': notes,
  };
}