class OrderNotification {
  final int storeId;
  final int orderId;
  final String storeName;
  final String notificationUuid; // ✨

  OrderNotification({
    required this.storeId,
    required this.orderId,
    required this.storeName,
    required this.notificationUuid, //
  });

  factory OrderNotification.fromJson(Map<String, dynamic> json) {
    return OrderNotification(
      storeId: json['store_id'] as int,
      orderId: json['order_id'] as int,
      storeName: json['store_name'] as String,
      notificationUuid: json['notification_uuid'] as String,
    );
  }
}