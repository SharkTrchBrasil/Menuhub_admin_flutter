// lib/pages/opening_hours/widgets/day_schedule_card.dart

import 'package:flutter/material.dart';

import '../../../../models/store/store_hour.dart';
import 'shift_row.dart';

class DayScheduleCard extends StatelessWidget {
  final String dayName;
  final List<StoreHour> slots;
  final Function(bool) onToggleClosed;
  final VoidCallback onAddSlot;
  final Function(StoreHour) onRemoveSlot;
  final Function(int, TimeOfDay) onUpdateOpeningTime;
  final Function(int, TimeOfDay) onUpdateClosingTime;

  const DayScheduleCard({
    super.key,
    required this.dayName,
    required this.slots,
    required this.onToggleClosed,
    required this.onAddSlot,
    required this.onRemoveSlot,
    required this.onUpdateOpeningTime,
    required this.onUpdateClosingTime,
  });

  @override
  Widget build(BuildContext context) {
    bool isClosed = slots.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dayName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Checkbox(
                    value: isClosed,
                    onChanged: (val) => onToggleClosed(val!),
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  const Text('Fechado'),
                ],
              ),
            ],
          ),
          if (!isClosed) ...[
            const SizedBox(height: 16),
            ...slots.asMap().entries.map((entry) {
              int index = entry.key;
              StoreHour slot = entry.value;
              return ShiftRow(
                slot: slot,
                onRemove: () => onRemoveSlot(slot),
                onUpdateOpeningTime: (time) => onUpdateOpeningTime(index, time),
                onUpdateClosingTime: (time) => onUpdateClosingTime(index, time),
              );
            }).toList(),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAddSlot,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text("Adicionar outro horário"),
              ),
            ),
          ]
        ],
      ),
    );
  }
}