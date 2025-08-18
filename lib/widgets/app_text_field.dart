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
    this.controller,
    this.readOnly = false,
    this.enabled = true,
    this.suffixIcon, // ✅ Renomeado de 'suffix' para 'suffixIcon'
    this.focusNode,
    this.maxLength, // ✅ novo
    this.maxLines,  // ✅ novo// ✅ Adicionado o novo parâmetro 'focusNode'
  });

  final String title;
  final String hint;
  final String? initialValue;
  final String? Function(String?)? validator;
  final Function(String?)? onChanged;
  final bool isHidden;
  final String? icon;
  final List<TextInputFormatter>? formatters;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool readOnly;
  final bool enabled;
  final Widget? suffixIcon; // ✅ Renomeado de 'suffix' para 'suffixIcon'
  final FocusNode? focusNode; // ✅ Adicionado o novo parâmetro 'focusNode'
// ✅ NOVOS PARÂMETROS
  final int? maxLength;
  final int? maxLines;
  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool obscure = widget.isHidden;

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
          focusNode: widget.focusNode, // ✅ Passa o focusNode para o TextFormField
          style: TextStyle(
            color: Theme.of(context).textTheme.displayLarge?.color,
            fontSize: 16,
          ),
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          controller: widget.controller,
          obscureText: obscure,
          validator: widget.validator,
          initialValue: widget.initialValue,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.formatters,
          maxLength: widget.maxLength,
          maxLines: widget.maxLines ?? 1,

          cursorColor: const Color(0xFFF39C12),
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
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: const BorderSide(color: Color(0xFFF39C12), width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            // ✅ Lógica do ícone de sufixo atualizada
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
                : widget.suffixIcon ?? // Prioriza o novo 'suffixIcon'
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