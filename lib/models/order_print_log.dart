class OrderPrintLog {
  final int id;
  final String printerDestination;
  final String status;

  OrderPrintLog({
    required this.id,
    required this.printerDestination,
    required this.status,
  });

  factory OrderPrintLog.fromJson(Map<String, dynamic> json) {
    return OrderPrintLog(
      id: json['id'] as int,
      // O backend envia 'printer_destination', então usamos esse nome aqui.
      printerDestination: json['printer_destination'] as String,
      status: json['status'] as String,
    );
  }
}