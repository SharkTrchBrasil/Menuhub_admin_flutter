import 'package:flutter/material.dart';

import '../../../core/responsive_builder.dart';


class WizardHeader extends StatelessWidget {
  final String title;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onClose;

  const WizardHeader({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveBuilder.isMobile(context) ? 14 : 24.0,
        vertical: 14
      ),
      // 1. A estrutura principal agora é uma Column
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LINHA 1: Título e Botão de Fechar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),

                ),
              ),
              if (onClose != null)
                IconButton(

                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
            ],
          ),
          // Só mostra a parte de progresso se houver mais de 0 passos
          if (totalSteps > 0) ...[
            const SizedBox(height: 16), // Espaçamento entre título e barras

            // LINHA 2: Barras de Progresso
            Row(
              children: [
                // Geramos as barras com um laço for para adicionar espaçamento
                for (int i = 0; i < totalSteps; i++) ...[
                  // ✨ Cada barra agora é Expanded para preencher o espaço
                  Expanded(
                    child: _buildStepIndicator(
                      context: context,
                      isActive: i < currentStep,
                    ),
                  ),
                  // Adiciona um espaço entre as barras, exceto na última
                  if (i < totalSteps - 1)
                    const SizedBox(width: 4),
                ]
              ],
            ),
            const SizedBox(height: 8), // Espaçamento entre barras e texto

            // LINHA 3: Texto do Passo
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Passo $currentStep de $totalSteps",
                style: TextStyle(fontWeight: FontWeight.bold),

              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Widget auxiliar para o indicador de passo (as barrinhas)
  /// ❗️ REMOVEMOS A MARGEM DAQUI
  Widget _buildStepIndicator({required BuildContext context, required bool isActive}) {
    return Container(
      // margin: const EdgeInsets.only(right: 4), // Margem removida
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.red : Colors.grey,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}