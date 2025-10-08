import 'package:flutter/material.dart';
import 'package:totem_pro_admin/pages/store_wizard/store_wizard_page.dart';

class StoreWizardProgressBar extends StatelessWidget {
  final Map<StoreConfigStep, bool> stepStatus;
  final int currentStepIndex;
  final Function(StoreConfigStep) onStepTapped;

  const StoreWizardProgressBar({
    super.key,
    required this.stepStatus,
    required this.currentStepIndex,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.green;
    final completedColor = Colors.green;
    final inactiveColor = Colors.grey.shade300;

    // Filtra apenas as etapas de trabalho (exclui a final)
    final workSteps = StoreConfigStep.values.where((s) => s != StoreConfigStep.finish).toList();

    return Column(
      children: [
        Row(
          children: List.generate(workSteps.length, (index) {
            final step = workSteps[index];
            final isCompleted = stepStatus[step] ?? false;
            final isCurrent = index == currentStepIndex;
            final isPast = index < currentStepIndex;

            Color segmentColor;

            // ✅ ALTERAÇÃO: A lógica de cores e de clique foi simplificada
            // para corresponder melhor à navegação do usuário.

            // Uma etapa é "clicável" se for a atual ou qualquer uma anterior.
            final isClickable = isCurrent || isPast;

            if (isCurrent) {
              segmentColor = primaryColor; // A etapa atual sempre tem a cor primária
            } else if (isPast) {
              // Etapas passadas usam a cor de "completado" para indicar progresso
              segmentColor = completedColor;
            } else {
              // Etapas futuras ficam inativas
              segmentColor = inactiveColor;
            }

            return Expanded(
              child: GestureDetector(
                onTap: isClickable ? () => onStepTapped(step) : null,
                child: MouseRegion(
                  cursor: isClickable ? SystemMouseCursors.click : SystemMouseCursors.basic,
                  child: Tooltip(
                    message: _getStepName(step),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      height: 8.0,
                      decoration: BoxDecoration(
                        color: segmentColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),

      ],
    );
  }

  String _getStepName(StoreConfigStep step) {
    switch (step) {
      case StoreConfigStep.profile: return 'Perfil da Loja';
      case StoreConfigStep.paymentMethods: return 'Pagamentos';
      case StoreConfigStep.deliveryArea: return 'Área de Entrega';
      case StoreConfigStep.openingHours: return 'Horários';
      case StoreConfigStep.productCatalog: return 'Cardápio';
      case StoreConfigStep.finish: return 'Finalizar';
    }
  }
}