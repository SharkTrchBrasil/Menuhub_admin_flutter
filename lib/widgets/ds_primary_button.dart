import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/enums/connectivity_status.dart';
import '../cubits/store_manager_cubit.dart';
import '../cubits/store_manager_state.dart';

// ✨ Widget para a animação de "3 pontos"
class _ThreeDotsLoading extends StatefulWidget {
  final Color? dotsColor;

  const _ThreeDotsLoading({this.dotsColor});

  @override
  State<_ThreeDotsLoading> createState() => _ThreeDotsLoadingState();
}

class _ThreeDotsLoadingState extends State<_ThreeDotsLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Usa a cor personalizada se fornecida, senão usa a cor do tema
    final color = widget.dotsColor ??
        (ButtonTheme.of(context).colorScheme?.onPrimary ?? Colors.white);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return FadeTransition(
          opacity: DelayTween(
            begin: 0.2,
            end: 1.0,
            delay: index * 0.2,
          ).animate(_controller),
          child: Text(
            "●",
            style: TextStyle(
              fontSize: 14,
              color: color,
            ),
          ),
        );
      }),
    );
  }
}

// Helper para a animação escalonada
class DelayTween extends Tween<double> {
  final double delay;
  DelayTween({required super.begin, required super.end, required this.delay});

  @override
  double lerp(double t) {
    return super.lerp((t - delay).clamp(0.0, 1.0));
  }
}

enum DsButtonStyle {
  primary,
  secondary,
  custom,
}

class DsButton extends StatelessWidget {
  const DsButton({
    super.key,
    this.label,
    this.child,
    this.onPressed,
    this.style = DsButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.loadingDotsColor,
    this.padding,
    this.minimumSize,
    this.requiresConnection = true,
    this.maxWidth, // ✅ NOVO: Limitar largura máxima
    this.constrained = false, // ✅ NOVO: Controlar se deve limitar largura
  }) : assert(label != null || child != null,
  'É necessário fornecer ou uma "label" ou um "child".');

  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final DsButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final Color? loadingDotsColor;
  final EdgeInsets? padding;
  final Size? minimumSize;
  final bool requiresConnection;
  final double? maxWidth; // ✅ NOVO: Largura máxima
  final bool constrained; // ✅ NOVO: Se deve limitar a largura

  Color _getEffectiveBackgroundColor(Set<MaterialState> states, ColorScheme colorScheme) {
    if (states.contains(MaterialState.disabled)) {
      return disabledBackgroundColor ?? Colors.grey.shade300;
    }

    switch (style) {
      case DsButtonStyle.custom:
        return backgroundColor ?? colorScheme.primary;
      case DsButtonStyle.primary:
        return backgroundColor ?? colorScheme.primary;
      case DsButtonStyle.secondary:
        return Colors.transparent;
    }
  }

  Color _getEffectiveForegroundColor(Set<MaterialState> states, ColorScheme colorScheme) {
    if (states.contains(MaterialState.disabled)) {
      return disabledForegroundColor ?? Colors.grey.shade600;
    }

    switch (style) {
      case DsButtonStyle.custom:
        return foregroundColor ?? colorScheme.onPrimary;
      case DsButtonStyle.primary:
        return foregroundColor ?? colorScheme.onPrimary;
      case DsButtonStyle.secondary:
        return foregroundColor ?? colorScheme.primary;
    }
  }

  Color _getEffectiveBorderColor(ColorScheme colorScheme) {
    if (borderColor != null) return borderColor!;

    switch (style) {
      case DsButtonStyle.custom:
        return backgroundColor ?? colorScheme.primary;
      case DsButtonStyle.primary:
        return colorScheme.primary;
      case DsButtonStyle.secondary:
        return colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<StoresManagerCubit, StoresManagerState, bool>(
      selector: (state) {
        if (!requiresConnection) return true;
        return state is StoresManagerLoaded &&
            state.connectivityStatus == ConnectivityStatus.connected;
      },
      builder: (context, isConnected) {
        final colorScheme = Theme.of(context).colorScheme;
        final textStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.w600);

        final bool isEffectivelyDisabled = isLoading || !isConnected;
        final VoidCallback? finalOnPressed = isEffectivelyDisabled ? null : onPressed;

        final baseStyle = ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          ),
          minimumSize: MaterialStateProperty.all(minimumSize ?? const Size(80, 48)),
          maximumSize: MaterialStateProperty.all(
            // ✅ CORREÇÃO: Define tamanho máximo baseado no constrained
            constrained && maxWidth != null
                ? Size(maxWidth!, minimumSize?.height ?? 48)
                : Size(double.infinity, minimumSize?.height ?? 48),
          ),
          alignment: Alignment.center,
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          elevation: MaterialStateProperty.all(0),
          backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) => _getEffectiveBackgroundColor(states, colorScheme),
          ),
          foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) => _getEffectiveForegroundColor(states, colorScheme),
          ),
        );

        final buttonContent = child ??
            _ResponsiveButtonContent(
              icon: icon,
              label: label!,
              textStyle: textStyle.copyWith(
                color: _getEffectiveForegroundColor({}, colorScheme),
              ),
              constrained: constrained, // ✅ Passa a flag para o conteúdo
            );

        final finalChild = isLoading
            ? _ThreeDotsLoading(dotsColor: loadingDotsColor ?? _getEffectiveForegroundColor({}, colorScheme))
            : buttonContent;

        // ✅ WRAPPER para limitar largura quando necessário
        Widget buildButton() {
          switch (style) {
            case DsButtonStyle.secondary:
              return OutlinedButton(
                onPressed: finalOnPressed,
                style: baseStyle.copyWith(
                  side: MaterialStateProperty.all(
                    BorderSide(color: _getEffectiveBorderColor(colorScheme), width: 0.5),
                  ),
                ),
                child: finalChild,
              );

            case DsButtonStyle.custom:
            case DsButtonStyle.primary:
            default:
              return ElevatedButton(
                onPressed: finalOnPressed,
                style: baseStyle.copyWith(
                  side: style == DsButtonStyle.custom
                      ? MaterialStateProperty.all(
                    BorderSide(color: _getEffectiveBorderColor(colorScheme), width: 0.5),
                  )
                      : null,
                ),
                child: finalChild,
              );
          }
        }

        // ✅ Aplica constrain adicional se necessário
        return constrained && maxWidth != null
            ? ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: buildButton(),
        )
            : buildButton();
      },
    );
  }
}

// Widget interno responsivo - CORRIGIDO
class _ResponsiveButtonContent extends StatelessWidget {
  const _ResponsiveButtonContent({
    required this.icon,
    required this.label,
    required this.textStyle,
    this.constrained = false, // ✅ NOVO: Controla comportamento
  });

  final IconData? icon;
  final String label;
  final TextStyle textStyle;
  final bool constrained; // ✅ NOVO

  @override
  Widget build(BuildContext context) {
    // ✅ CORREÇÃO: Comportamento diferente baseado no constrained
    if (constrained) {
      // Modo constrained: layout horizontal fixo com texto limitado
      return Row(
        mainAxisSize: MainAxisSize.min, // ✅ Importante: não expandir
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: textStyle.color),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              label,
              style: textStyle,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    } else {
      // Modo normal: layout responsivo
      return LayoutBuilder(
        builder: (context, constraints) {
          final bool useVerticalLayout = (icon != null && constraints.maxWidth < 150);

          if (useVerticalLayout) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 20, color: textStyle.color),
                  const SizedBox(height: 4),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: textStyle,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            );
          } else {
            return Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: textStyle.color),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: textStyle,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            );
          }
        },
      );
    }
  }
}