import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/dashboard_insight.dart';

class LowMoverInsightCard extends StatelessWidget {
  final LowMoverInsightDetails details;

  const LowMoverInsightCard({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmall = size.width < 400; // mobile pequeno

    return Card(
      elevation: 4.0,
      shadowColor: Colors.blue.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: const Color(0xFFEFF8FF), // Azul claro
      child: Padding(
        padding: EdgeInsets.all(isSmall ? 12.0 : 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com Ícone e Título
            Row(
              children: [
                Icon(
                  Icons.insights_rounded,
                  color: Colors.blue.shade700,
                  size: isSmall ? 22 : 28,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Oportunidade de Otimização',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmall ? 16 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Mensagem Detalhada
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: isSmall ? 13 : 15,
                  color: Colors.black87,
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Notamos que o item "'),
                  TextSpan(
                    text: details.productName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '" não é vendido há mais de '),
                  TextSpan(
                    text: '${details.daysSinceLastSale} dias',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Botões de Ação (responsivo com Wrap)
            Align(
              alignment: Alignment.center,
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Remover do Cardápio'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmall ? 12 : 16,
                        vertical: isSmall ? 10 : 14,
                      ),
                    ),
                    child: const Text('Criar Promoção'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
