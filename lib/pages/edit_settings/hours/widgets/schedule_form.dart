// lib/pages/opening_hours/widgets/schedule_form.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/store_hour.dart';
import 'day_schedule_card.dart';

class ScheduleForm extends StatelessWidget {
  final Map<int, List<StoreHour>> openingHours;
  final Map<int, String> dayNames;
  final List<int> displayOrder;
  final Function(int) onAddSlot;
  final Function(int, StoreHour) onRemoveSlot;
  final Function(int, int, TimeOfDay) onUpdateOpeningTime;
  final Function(int, int, TimeOfDay) onUpdateClosingTime;
  final Function(int, bool) onToggleDayClosed;

  const ScheduleForm({
    super.key,
    required this.openingHours,
    required this.dayNames,
    required this.displayOrder,
    required this.onAddSlot,
    required this.onRemoveSlot,
    required this.onUpdateOpeningTime,
    required this.onUpdateClosingTime,
    required this.onToggleDayClosed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey[300]!)),
      color: Colors.white,
      child: Column(
        children: displayOrder.map((dayIndex) {
          return DayScheduleCard(
            dayName: dayNames[dayIndex]!,
            slots: openingHours[dayIndex]!,
            onToggleClosed: (isClosed) => onToggleDayClosed(dayIndex, isClosed),
            onAddSlot: () => onAddSlot(dayIndex),
            onRemoveSlot: (slot) => onRemoveSlot(dayIndex, slot),
            onUpdateOpeningTime: (index, time) =>
                onUpdateOpeningTime(dayIndex, index, time),
            onUpdateClosingTime: (index, time) =>
                onUpdateClosingTime(dayIndex, index, time),
          );
        }).toList(),
      ),
    );
  }
}