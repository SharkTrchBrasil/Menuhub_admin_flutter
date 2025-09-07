import 'package:flutter/material.dart';

/// Um widget simples e reutilizável para exibir um cabeçalho padronizado
/// dentro de uma aba ou seção, contendo um título e um subtítulo.
class TabHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon; // Parâmetro opcional para adicionar um ícone

  const TabHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // O Row permite adicionar um ícone ao lado do título facilmente
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Só mostra o ícone se ele for fornecido
            if (icon != null) ...[
              Icon(
                icon,
                color: Theme.of(context).textTheme.headlineSmall?.color,
                size: 28, // Tamanho do ícone um pouco menor que o texto
              ),
              const SizedBox(width: 12),
            ],
            // Usamos Flexible para o texto quebrar a linha corretamente se for muito grande
            Flexible(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}