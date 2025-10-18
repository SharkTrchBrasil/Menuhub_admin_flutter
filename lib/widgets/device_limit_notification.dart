import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:totem_pro_admin/repositories/realtime_repository.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart' as AppToasts;

class DeviceLimitListener extends StatefulWidget {
  final Widget child;

  const DeviceLimitListener({
    super.key,
    required this.child,
  });

  @override
  State<DeviceLimitListener> createState() => _DeviceLimitListenerState();
}

class _DeviceLimitListenerState extends State<DeviceLimitListener> {
  late final RealtimeRepository _realtimeRepo;
  StreamSubscription? _limitSubscription;

  @override
  void initState() {
    super.initState();
    _realtimeRepo = GetIt.I<RealtimeRepository>();

    _limitSubscription = _realtimeRepo.onDeviceLimitReached.listen((data) {
      final message = data['message'] as String;
      final maxDevices = data['max_devices'] as int;

      // Mostra dialog explicativo
      _showDeviceLimitDialog(message, maxDevices);
    });
  }

  void _showDeviceLimitDialog(String message, int maxDevices) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.devices, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Text('Limite de Dispositivos'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Você pode ter até $maxDevices dispositivos conectados simultaneamente.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Redireciona para a tela de login
              // context.go('/login');  // Descomente se usar GoRouter
            },
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _limitSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}