import 'package:flutter/material.dart';

// Switch personalizado com dimensões ajustadas
class CustomSizeSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;

  const CustomSizeSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 50.0, // Largura padrão aumentada
    this.height = 28.0, // Altura padrão reduzida
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        fit: BoxFit.contain,
        child: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}