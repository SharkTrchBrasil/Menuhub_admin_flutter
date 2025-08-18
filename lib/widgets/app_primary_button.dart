import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../ConstData/typography.dart'; // Mantenha seus imports corretos

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final double buttonWidth = isMobile ? screenWidth * 0.9 : 300;

    return Focus(
      onKey: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) {
          onPressed?.call();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: SizedBox(
        width: buttonWidth,
        // O height pode ser removido daqui, pois o estilo do botão vai controlá-lo
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),

            // ✅ A CORREÇÃO ESTÁ AQUI
            // Força o botão a ocupar toda a largura disponível (definida pelo SizedBox)
            // e define a altura como 40.
            minimumSize: const Size.fromHeight(45),

            elevation: 0,
            shadowColor: Colors.transparent,
          ),
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: Typographyy.bodyLargeSemiBold.copyWith( // Use seu estilo correto
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}