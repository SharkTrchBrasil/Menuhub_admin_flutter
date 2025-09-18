// lib/widgets/connectivity_overlay.dart

import 'package:flutter/material.dart';

class ConnectivityOverlay extends StatelessWidget {
  const ConnectivityOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 1. Usamos um Scaffold para ter uma base sólida com fundo branco.
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              // ✅ 2. Cor do ícone alterada para ser visível no fundo branco
              color: Colors.grey[700],
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'Sem Conexão',
              style: TextStyle(
                // ✅ 3. Cor do texto alterada
                color: Colors.grey[800],
                fontSize: 22,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verifique sua conexão com a internet\ne tente novamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                // ✅ 4. Cor do texto alterada
                color: Colors.grey[600],
                fontSize: 16,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}