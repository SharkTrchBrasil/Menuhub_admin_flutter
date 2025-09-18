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
    // ✅ 4. A LÓGICA PRINCIPAL AGORA É ENVOLVIDA PELO BLOCSELECTOR
    return BlocSelector<StoresManagerCubit, StoresManagerState, bool>(
      // O seletor retorna 'true' se estiver conectado.
      selector: (state) {
        // Se o botão não requer conexão, ele é sempre considerado "conectado" para fins de lógica.
        if (!requiresConnection) return true;

        return state is StoresManagerLoaded &&
            state.connectivityStatus == ConnectivityStatus.connected;
      },
      builder: (context, isConnected) {
        final colorScheme = Theme.of(context).colorScheme;
        final textStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.w600);

        // ✅ 5. DETERMINA O ESTADO FINAL DO onPresed
        // O botão é desabilitado se (isLoading for true) OU (se ele requer conexão e não está conectado).
        final bool isEffectivelyDisabled = isLoading || !isConnected;
        final VoidCallback? finalOnPressed = isEffectivelyDisabled ? null : onPressed;

        final baseStyle = ButtonStyle(
          // ... (o resto do seu `baseStyle` continua o mesmo)
          padding: MaterialStateProperty.all<EdgeInsets>(
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          ),
          maximumSize: MaterialStateProperty.all(minimumSize ?? const Size(190, 42)),
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
            );

        final finalChild = isLoading
            ? _ThreeDotsLoading(dotsColor: loadingDotsColor ?? _getEffectiveForegroundColor({}, colorScheme))
            : buttonContent;

        switch (style) {
          case DsButtonStyle.secondary:
            return OutlinedButton(
              onPressed: finalOnPressed, // ✅ Usa o onPressed final
              style: baseStyle.copyWith(
                side: MaterialStateProperty.all(
                  BorderSide(color: _getEffectiveBorderColor(colorScheme), width: 1),
                ),
              ),
              child: finalChild,
            );

          case DsButtonStyle.custom:
          case DsButtonStyle.primary:
          default:
            return ElevatedButton(
              onPressed: finalOnPressed, // ✅ Usa o onPressed final
              style: baseStyle.copyWith(
                side: style == DsButtonStyle.custom
                    ? MaterialStateProperty.all(
                  BorderSide(color: _getEffectiveBorderColor(colorScheme), width: 1),
                )
                    : null,
              ),
              child: finalChild,
            );
        }
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
  });

  final IconData? icon;
  final String label;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool useVerticalLayout = (icon != null && constraints.maxWidth < 150);

        Widget content;

        if (useVerticalLayout) {
          content = Row(

            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Flexible(child: Icon(icon, size: 20, color: textStyle.color)),
                const SizedBox(height: 4),
              ],
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: textStyle,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        } else {
          content = Row(

            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: textStyle.color),
                const SizedBox(width: 8),
              ],
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: textStyle,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }

        // ✅ CORREÇÃO: Usar Center em vez de IntrinsicWidth com stepHeight: 0
        return Center(
          child: content,
        );
      },
    );
  }
}