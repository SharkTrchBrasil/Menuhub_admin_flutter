import 'package:flutter/material.dart';

class WizardFooter extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final String continueLabel;
  final bool isLoading;
  // 1. Adicionamos a nova propriedade para controlar a visibilidade
  final bool showBackButton;

  const WizardFooter({
    super.key,
    this.onBack,
    this.onContinue,
    this.continueLabel = "Continuar",
    this.isLoading = false,
    // 2. Adicionamos ao construtor com valor padrão 'true'
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 3. Atualizamos a condição para verificar a nova propriedade E se onBack existe
          if (showBackButton && onBack != null)
            TextButton(
              onPressed: onBack,
              child: const Text("Voltar"),
            ),

          // A mesma condição se aplica ao SizedBox para não criar um espaço vazio
          if (showBackButton && onBack != null)
            const SizedBox(width: 16),

          // Botão principal (Continuar/Concluir) - sem alterações
          ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 44),
            ),
            child: isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(continueLabel),
          ),
        ],
      ),
    );
  }
}