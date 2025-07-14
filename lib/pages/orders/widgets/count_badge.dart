import 'package:flutter/material.dart';


class CountBadge extends StatelessWidget {
  final int count;

  const CountBadge({
    Key? key,
    required this.count,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20, // Tamanho fixo
      height: 20, // Tamanho fixo
      decoration: const BoxDecoration(
        color: Colors.red, // Cor padrão
        shape: BoxShape.circle, // Formato circular
      ),
      child: Center(
        child: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white, // Cor do texto padrão
            fontSize: 12, // Tamanho do texto padrão
            fontWeight: FontWeight.bold, // Negrito
          ),
        ),
      ),
    );
  }
}