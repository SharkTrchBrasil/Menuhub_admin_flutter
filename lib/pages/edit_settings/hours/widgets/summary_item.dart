// lib/pages/opening_hours/widgets/summary_item.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';

class SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final bool hasWarning;

  const SummaryItem({
    super.key,
    required this.value,
    required this.label,
    this.hasWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBuilder.isMobile(context);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style:
                 TextStyle(fontSize: isMobile ? 18 :24, fontWeight: isMobile ? FontWeight.bold: FontWeight.w900)),
            if (hasWarning) ...[
              const SizedBox(width: 4),
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange[700], size: 16),
            ]
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}