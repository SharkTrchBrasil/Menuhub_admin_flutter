import 'package:flutter/material.dart';

class FinishStepContent extends StatelessWidget {
  const FinishStepContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
            SizedBox(height: 24),
            Text(
              'Parabéns!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              'Sua loja foi configurada com sucesso e seu cardápio inicial está pronto. Clique abaixo para ir ao seu painel e começar a vender!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, height: 1.5, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}