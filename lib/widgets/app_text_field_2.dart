import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField2 extends StatelessWidget {
  const AppTextField2({
    super.key,
    required this.title,
    required this.hint,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.formatters,
    this.suffixText,
    this.description,
    this.keyboardType,
  });

  final String title;
  final String hint;
  final String? initialValue;
  final String? Function(String?)? validator;
  final Function(String?)? onChanged;
  final List<TextInputFormatter>? formatters;
  final String? suffixText;
  final String? description;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: initialValue,
          validator: validator,
          onChanged: onChanged,
          inputFormatters: formatters,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffixText,
            contentPadding: const EdgeInsets.all(16),
            fillColor: Colors.blue.withAlpha(80),
            filled: true,
            enabledBorder: InputBorder.none,
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: Colors.red, width: 2),
            ),
          ),
        ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              description!,
              style: const TextStyle(fontSize: 12),
            ),
          ),
      ],
    );
  }
}
