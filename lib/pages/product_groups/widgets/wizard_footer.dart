import 'package:flutter/material.dart';
import '../../../widgets/ds_primary_button.dart';

class WizardFooter extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final String continueLabel;
  final bool isLoading;
  final bool showBackButton;

  const WizardFooter({
    super.key,
    this.onBack,
    this.onContinue,
    this.continueLabel = "Continuar",
    this.isLoading = false,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasBackButton = showBackButton && onBack != null;

    // A mágica está aqui:
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0,),
        child: Row(
          mainAxisAlignment: hasBackButton
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.end,
          children: [
            if (hasBackButton)
              TextButton(
                onPressed: onBack,
                child: const Text("Voltar"),
              ),
            if (hasBackButton) const SizedBox(width: 16),
            DsButton(
              onPressed: onContinue,
              isLoading: isLoading,
              label: continueLabel,
            ),
          ],
        ),
      ),
    );
  }
}