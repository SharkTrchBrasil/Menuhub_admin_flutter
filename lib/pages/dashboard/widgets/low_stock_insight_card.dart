import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/dashboard_insight.dart';

class LowStockInsightCard extends StatelessWidget {
  final LowStockInsightDetails details;

  const LowStockInsightCard({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shadowColor: Colors.red.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: const Color(0xFFFFF0F0), // Um tom de vermelho bem claro
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cabeçalho com Ícone e Título
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Alerta de Estoque Baixo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB71C1C), // Vermelho escuro
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Mensagem Detalhada
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'O produto "'),
                  TextSpan(
                    text: details.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: '" está acabando! Restam apenas '),
                  TextSpan(
                    text: '${details.currentStock} unidades',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const TextSpan(text: '.'),
                  if (details.isTopSeller)
                    const TextSpan(
                      text: '\nEste é um dos seus itens mais vendidos!',
                      style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black54),
                    ),
                ],
              ),
            ),
            const Spacer(), // Ocupa o espaço restante e empurra os botões para baixo

            // Botões de Ação
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () { /* TODO: Navegar para a tela do produto */ },
                  child: const Text('Ver Produto'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () { /* TODO: Implementar lógica para indisponibilizar */ },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Indisponibilizar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}