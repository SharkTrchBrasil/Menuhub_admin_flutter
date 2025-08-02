import 'package:flutter/material.dart';
class SegmentedProgressBar extends StatelessWidget {
  final int totalSteps;
  final int currentStep;

  const SegmentedProgressBar({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).primaryColor;
    final inactiveColor = Colors.grey.shade300;

    return Row(
      children: List.generate(totalSteps, (index) {
        // Verifica se o segmento atual deve estar ativo
        final isActive = index < currentStep;

        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2.0), // Espaçamento entre as barras
            height: 8.0, // Altura das barras
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}