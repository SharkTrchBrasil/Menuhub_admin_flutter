import 'package:flutter/material.dart';
import 'package:totem_pro_admin/pages/store_wizard/store_wizard_page.dart';

class StoreWizardProgressBar extends StatelessWidget {
  final Map<StoreConfigStep, bool> stepStatus;
  final int currentStepIndex;
  final int totalSteps;
  final Function(StoreConfigStep) onStepTapped;

  const StoreWizardProgressBar({
    super.key,
    required this.stepStatus,
    required this.currentStepIndex,
    required this.totalSteps,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final currentColor = Theme.of(context).primaryColor;
    final completedColor = Colors.green;
    final inactiveColor = Colors.grey.shade300;

    final relevantSteps = StoreConfigStep.values.toList();
    final currentRelevantIndex = currentStepIndex;

    return Row(
      children: List.generate(relevantSteps.length, (index) {
        final step = relevantSteps[index];
        final isCompleted = stepStatus[step] ?? false;
        final isCurrent = index == currentRelevantIndex;
        final isPast = index < currentRelevantIndex;

        Color segmentColor;
        if (isCurrent) {
          segmentColor = currentColor;
        } else if (isPast || isCompleted) {
          segmentColor = completedColor;
        } else {
          segmentColor = inactiveColor;
        }

        return Expanded(
          child: GestureDetector(
            onTap: () => onStepTapped(step),
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
        );
      }),
    );
  }
}