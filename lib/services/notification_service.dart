import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Torna esta classe um Singleton para ter uma única instância
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Configurações para Android
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // Use o ícone do seu app

    // Configurações para iOS (solicita permissão)
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNewOrderNotification(String orderId, String customerName) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'new_order_channel', // ID do canal
      'Novos Pedidos',      // Nome do canal
      channelDescription: 'Notificações para novos pedidos recebidos.',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0, // ID da notificação
      'Novo Pedido Recebido!',
      'Pedido #${orderId} de $customerName aguardando aceite.',
      platformDetails,
    );
  }
}