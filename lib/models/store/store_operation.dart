// store_operation.dart
class StoreOperation {
  final int? averagePreparationTime;
  final String? orderNumberPrefix;
  final DateTime? manualCloseUntil;
  final String? responsibleName;
  final String? responsiblePhone;

  StoreOperation({
    this.averagePreparationTime,
    this.orderNumberPrefix,
    this.manualCloseUntil,
    this.responsibleName,
    this.responsiblePhone,
  });

  factory StoreOperation.fromJson(Map<String, dynamic> json) {
    return StoreOperation(
      averagePreparationTime: json['average_preparation_time'] as int?,
      orderNumberPrefix: json['order_number_prefix'],
      manualCloseUntil: json['manual_close_until'] != null
          ? DateTime.parse(json['manual_close_until'])
          : null,
      responsibleName: json['responsible_name'],
      responsiblePhone: json['responsible_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average_preparation_time': averagePreparationTime,
      'order_number_prefix': orderNumberPrefix,
      'manual_close_until': manualCloseUntil?.toIso8601String(),
      'responsible_name': responsibleName,
      'responsible_phone': responsiblePhone,
    };
  }
}