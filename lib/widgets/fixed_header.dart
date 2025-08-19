import 'package:flutter/material.dart';

class FixedHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  const FixedHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ✅ 1. DETECTA O TAMANHO DA TELA
    // Usamos um breakpoint comum. Se a largura for menor que 600 pixels, consideramos mobile.
    final isMobile = MediaQuery.of(context).size.width < 600;

    // Define os tamanhos de fonte com base no tamanho da tela
    final titleFontSize = isMobile ? 22.0 : 28.0;
    final subtitleFontSize = isMobile ? 14.0 : 16.0;

    // O layout principal agora se adapta.
    // Se for mobile, usa uma Coluna. Se não, usa a Linha original.
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: isMobile
          ? _buildMobileLayout(theme, titleFontSize, subtitleFontSize)
          : _buildDesktopLayout(theme, titleFontSize, subtitleFontSize),
    );
  }

  // ✅ 2. LAYOUT PARA DESKTOP (O SEU LAYOUT ORIGINAL, MAS MAIS ROBUSTO)
  Widget _buildDesktopLayout(ThemeData theme, double titleFontSize, double subtitleFontSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Adicionado `Expanded` para garantir que o texto quebre a linha corretamente
        // e não cause overflow quando o título for muito grande.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: titleFontSize,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  // ✅ 3. CONTROLE DE QUEBRA DE LINHA DO SUBTÍTULO
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Spacer foi removido porque o Expanded já faz o trabalho de empurrar.
        // Adicionamos um SizedBox para garantir um espaçamento mínimo.
        const SizedBox(width: 24),
        if (actions != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: actions!,
          ),
      ],
    );
  }

  // ✅ 4. NOVO LAYOUT PARA MOBILE (ELEMENTOS EMPILHADOS)
  Widget _buildMobileLayout(ThemeData theme, double titleFontSize, double subtitleFontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título e subtítulo ocupam a parte de cima
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: titleFontSize,
              ),
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                // ✅ 3. CONTROLE DE QUEBRA DE LINHA DO SUBTÍTULO
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        // Se houver ações, adiciona um espaço e as exibe abaixo.
        if (actions != null && actions!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            // As ações podem ficar à direita ou ocupar a largura toda
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions!,
          ),
        ],
      ],
    );
  }
}