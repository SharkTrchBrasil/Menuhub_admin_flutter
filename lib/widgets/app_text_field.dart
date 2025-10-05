import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../ConstData/typography.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.title,
    required this.hint,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.isHidden = false,
    this.icon,
    this.formatters,
    this.keyboardType,
    this.readOnly = false,
    this.enabled = true,
    this.suffixIcon,
    this.focusNode,
    this.maxLength,
    this.maxLines,
    this.onTapOutside,
  });

  final String title;
  final String hint;
  final String? initialValue;
  final String? Function(String?)? validator;
  final Function(String?)? onChanged;
  final bool isHidden;
  final String? icon;
  final List<TextInputFormatter>? formatters;
  final TextInputType? keyboardType;
  final bool readOnly;
  final bool enabled;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final int? maxLength;
  final int? maxLines;
  final Function(PointerDownEvent)? onTapOutside;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;
  late bool obscure = widget.isHidden;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  // ✅✅✅ MÉTODO CORRIGIDO PARA EVITAR O ERRO 'setState called during build' ✅✅✅
  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newInitialValue = widget.initialValue ?? '';

    // A condição continua a mesma: só atualizamos se o valor mudou externamente.
    if (widget.initialValue != oldWidget.initialValue && newInitialValue != _controller.text) {
      // A solução: Agendamos a atualização do controller para DEPOIS que o build terminar.
      // Isso quebra o loop de reconstrução e evita o erro.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Verifica se o widget ainda está "montado" antes de mudar o controller.
        if (mounted) {
          _controller.text = newInitialValue;
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
          style: Typographyy.bodySmallMedium.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _controller,
          onChanged: widget.onChanged,
          focusNode: widget.focusNode,
          style: TextStyle(
            color: Theme.of(context).textTheme.displayLarge?.color,
            fontSize: 16,
          ),
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          obscureText: obscure,
          validator: widget.validator,
          onTapOutside: widget.onTapOutside,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.formatters,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines ?? 1,
          decoration: InputDecoration(
            filled: true,
            hintText: widget.hint,
            hintStyle: Theme.of(context).inputDecorationTheme.hintStyle?.copyWith(
              color: Colors.grey,
            ),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: Colors.grey, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: Colors.grey, width: 0.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            suffixIcon: widget.isHidden
                ? IconButton(
              icon: Icon(
                obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey.shade600,
              ),
              onPressed: () {
                setState(() {
                  obscure = !obscure;
                });
              },
            )
                : widget.suffixIcon ??
                (widget.icon != null
                    ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    widget.icon!,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      Colors.grey.shade600,
                      BlendMode.srcIn,
                    ),
                  ),
                )
                    : null),
          ),
        ),
      ],
    );
  }
}