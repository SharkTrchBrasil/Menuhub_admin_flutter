import 'package:flutter/material.dart';

class FixedHeaderSmall extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showActionsOnMobile; // ✅ flag adicionada

  const FixedHeaderSmall({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showActionsOnMobile = false, // ✅ por padrão não mostra no mobile
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    final titleFontSize = isMobile ? 18.0 : 26.0;
    final subtitleFontSize = isMobile ? 14.0 : 16.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: isMobile
          ? _buildMobileLayout(theme, titleFontSize, subtitleFontSize)
          : _buildDesktopLayout(theme, titleFontSize, subtitleFontSize),
    );
  }

  Widget _buildDesktopLayout(
      ThemeData theme, double titleFontSize, double subtitleFontSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: titleFontSize,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 24),
        if (actions != null && actions!.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: actions!,
          ),
      ],
    );
  }

  Widget _buildMobileLayout(
      ThemeData theme, double titleFontSize, double subtitleFontSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        // ✅ Só mostra no mobile se showActionsOnMobile = true
        if (showActionsOnMobile && actions != null && actions!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: actions!,
          ),
        ],
      ],
    );
  }
}
