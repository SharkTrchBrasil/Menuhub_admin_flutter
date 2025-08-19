// lib/pages/opening_hours/widgets/pause_list_item_card.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:totem_pro_admin/models/scheduled_pause.dart';

class PauseListItemCard extends StatelessWidget {
  final ScheduledPause pause;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const PauseListItemCard({
    super.key,
    required this.pause,
    required this.onDelete,
    required this.onEdit,
  });

  String _getDuration(DateTime start, DateTime end) {
    final duration = end.difference(start);
    if (duration.inDays > 0) {
      final days = duration.inDays;
      final hours = duration.inHours % 24;
      if (hours == 0) return 'Fechado por $days dia(s)';
      return 'Fechado por $days dia(s) e $hours hora(s)';
    }
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes == 0) return 'Fechado por $hours hora(s)';
      return 'Fechado por $hours hora(s) e $minutes minuto(s)';
    }
    return 'Fechado por ${duration.inMinutes} minuto(s)';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 650;

    return InkWell(
      onTap: onEdit,
      borderRadius: BorderRadius.circular(8),
      child: isMobile
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pause.reason ?? 'Pausa Programada',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                _getDuration(pause.startTime, pause.endTime),
                style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 5,
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd/MM/yy').format(pause.startTime.toLocal()),
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'de ${DateFormat('HH:mm').format(pause.startTime.toLocal())}',
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(Icons.arrow_forward, color: Colors.grey[400]),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd/MM/yy').format(pause.endTime.toLocal()),
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'até ${DateFormat('HH:mm').format(pause.endTime.toLocal())}',
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                onPressed: onDelete,
                tooltip: 'Remover Pausa',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ LAYOUT MOBILE CORRIGIDO E MAIS ROBUSTO
  Widget _buildMobileLayout(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Linha superior com título e botão de deletar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pause.reason ?? 'Pausa Programada',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getDuration(pause.startTime, pause.endTime),
                    style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            // Adicionamos um SizedBox para garantir que o botão não cause overflow
            SizedBox(
              width: 48,
              child: IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
                onPressed: onDelete,
                tooltip: 'Remover Pausa',
              ),
            ),
          ],
        ),
        SizedBox(height: 18,),

        // Seção inferior com detalhes de data/hora
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Envolvemos as colunas de data/hora em Expanded
            // para que elas dividam o espaço de forma flexível.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd/MM/yy').format(pause.startTime.toLocal()),
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'de ${DateFormat('HH:mm').format(pause.startTime.toLocal())}',
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.arrow_forward, color: Colors.grey[500], size: 20),
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('dd/MM/yy').format(pause.endTime.toLocal()),
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'até ${DateFormat('HH:mm').format(pause.endTime.toLocal())}',
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}