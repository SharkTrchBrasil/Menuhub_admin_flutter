import 'package:flutter/material.dart';

enum DsButtonStyle {
  primary,
  secondary,
}

class DsButton extends StatelessWidget {
  const DsButton({
    super.key,
    this.label,
    this.child,
    this.onPressed,
    this.style = DsButtonStyle.primary,
    this.icon,
  }) : assert(label != null || child != null,
  'É necessário fornecer ou uma "label" ou um "child".');

  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final DsButtonStyle style;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final textStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    final baseStyle = ButtonStyle(
      padding: MaterialStateProperty.all<EdgeInsets>(
        const EdgeInsets.symmetric(horizontal: 24, vertical: 16), // Ajustamos o padding vertical
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      elevation: MaterialStateProperty.all(0),
    );

    // ✅ USA O NOVO WIDGET RESPONSIVO PARA O CONTEÚDO
    final buttonChild = child ??
        _ResponsiveButtonContent(
          icon: icon,
          label: label!,
          textStyle: textStyle,
        );

    switch (style) {
      case DsButtonStyle.secondary:
        return OutlinedButton(
          onPressed: onPressed,
          style: baseStyle.copyWith(
            backgroundColor: MaterialStateProperty.all(Colors.transparent),
            foregroundColor: MaterialStateProperty.all(colorScheme.primary),
            side: MaterialStateProperty.all(
              BorderSide(color: colorScheme.primary, width: 1.5),
            ),
          ),
          child: buttonChild,
        );

      case DsButtonStyle.primary:
      default:
        return ElevatedButton(
          onPressed: onPressed,
          style: baseStyle.copyWith(
            backgroundColor: MaterialStateProperty.all(colorScheme.primary),
            foregroundColor: MaterialStateProperty.all(colorScheme.onPrimary),
          ),
          child: buttonChild,
        );
    }
  }
}

// ✅ NOVO WIDGET INTERNO E RESPONSIVO
class _ResponsiveButtonContent extends StatelessWidget {
  const _ResponsiveButtonContent({
    required this.icon,
    required this.label,
    required this.textStyle,
  });

  final IconData? icon;
  final String label;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder nos dá as restrições de espaço do pai do widget.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Define um ponto de quebra. Se a largura disponível for menor que 150,
        // o layout muda para coluna.
        final bool useVerticalLayout = (icon != null && constraints.maxWidth < 150);

        if (useVerticalLayout) {
          // Layout em Coluna para telas pequenas
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(height: 4),
              ],
              Text(
                label,
                style: textStyle,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        } else {
          // Layout em Linha para telas maiores
          return Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              // Flexible garante que o texto não cause overflow
              Flexible(
                child: Text(
                  label,
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }
      },
    );
  }
}