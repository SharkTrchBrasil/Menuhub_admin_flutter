import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/responsive_builder.dart';
import '../../../widgets/ds_primary_button.dart';

class PersistentFilterBar extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback onFilterTap;

  const PersistentFilterBar({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onFilterTap,
  });

  String _getPeriodLabel() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    if (start == today.subtract(const Duration(days: 6)) && end == today) {
      return "Últ. 7 dias";
    }
    if (start == today.subtract(const Duration(days: 29)) && end == today) {
      return "Últ. 30 dias";
    }
    if (start == end) {
      if (start == today) return "Hoje";
      if (start == yesterday) return "Ontem";
      return DateFormat('dd/MM/yy').format(start);
    }

    return "${DateFormat('dd/MM').format(start)} - ${DateFormat('dd/MM').format(end)}";
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBuilder.isMobile(context);

    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 38, // 🔹 padding menor no mobile
        vertical: 8,
      ),
      child: Row(
        children: [
          if (!isMobile) // 🔹 só aparece no desktop
            Text(
              "Filtros aplicados:",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          if (!isMobile) const SizedBox(width: 8),
          Chip(
            backgroundColor: Colors.red,
            label: Text(
              _getPeriodLabel(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
          ),
          const Spacer(),
          DsButton(
            onPressed: onFilterTap,
            icon: Icons.filter_list,
            label: "Filtros",
          ),
        ],
      ),
    );
  }
}
