import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


// ✅ WIDGET ATUALIZADO COM A LÓGICA DE CORES CORRIGIDA
class EmptyOrdersView extends StatelessWidget {
  final Color? color; // Cor para o tema do widget

  const EmptyOrdersView({super.key, this.color});

  @override
  Widget build(BuildContext context) {
return
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        color: color,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/empty.json',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nenhum item encontrado.',
                  style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
