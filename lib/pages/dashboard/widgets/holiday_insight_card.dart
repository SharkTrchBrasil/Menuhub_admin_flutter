import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:totem_pro_admin/models/dashboard_insight.dart';

class HolidayInsightCard extends StatelessWidget {
  final HolidayInsightDetails details;

  const HolidayInsightCard({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting('pt_BR', null);
    final formattedDate = DateFormat("d 'de' MMMM", 'pt_BR').format(details.holidayDate);
    final weekDay = DateFormat("EEEE", 'pt_BR').format(details.holidayDate);

    return Card(
      elevation: 4.0,
      shadowColor: Colors.deepPurple.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.celebration_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Text('Feriado à Vista!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${details.holidayName} está chegando no(a) próximo(a) $weekDay, $formattedDate.',
              style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9), height: 1.5),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () { /* TODO: Navegar para promoções */ },
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('Criar Promoção')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () { /* TODO: Navegar para horários */ },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.deepPurple),
                  child: const Text('Ajustar Horário'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}