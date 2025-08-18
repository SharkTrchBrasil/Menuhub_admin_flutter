// lib/pages/opening_hours/widgets/shift_row.dart

import 'package:flutter/material.dart';
import 'package:totem_pro_admin/models/store_hour.dart';

// O widget TimeInput (sem alterações)
class TimeInput extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final Function(TimeOfDay) onChanged;

  const TimeInput({
    super.key,
    required this.label,
    required this.time,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800])),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final newTime =
            await showTimePicker(context: context, initialTime: time);
            if (newTime != null) {
              onChanged(newTime);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(time.format(context), overflow: TextOverflow.ellipsis,)),
                const SizedBox(width: 4),
                Icon(Icons.access_time_filled,
                    color: Colors.grey[600], size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ShiftRow extends StatelessWidget {
  final StoreHour slot;
  final VoidCallback onRemove;
  final Function(TimeOfDay) onUpdateOpeningTime;
  final Function(TimeOfDay) onUpdateClosingTime;

  const ShiftRow({
    super.key,
    required this.slot,
    required this.onRemove,
    required this.onUpdateOpeningTime,
    required this.onUpdateClosingTime,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          // ✅ O PRIMEIRO CONTINUA FLEXIBLE
          Flexible(
            child: TimeInput(
              label: "Abertura",
              time: slot.openingTime ?? const TimeOfDay(hour: 9, minute: 0),
              onChanged: onUpdateOpeningTime,
            ),
          ),
          const SizedBox(width: 16),
          // ✅ O SEGUNDO VIRA EXPANDED
          // Ele vai ocupar todo o espaço restante, empurrando
          // o IconButton para o seu lugar sem causar overflow.
          Expanded(
            child: TimeInput(
              label: "Fechamento",
              time: slot.closingTime ?? const TimeOfDay(hour: 18, minute: 0),
              onChanged: onUpdateClosingTime,
            ),
          ),
          // O IconButton agora sempre terá seu espaço garantido.
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[700]),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}