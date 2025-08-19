// lib/pages/opening_hours/widgets/holidays_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:totem_pro_admin/cubits/store_manager_cubit.dart';
import 'package:totem_pro_admin/cubits/store_manager_state.dart';
import 'package:totem_pro_admin/models/holiday.dart';
import 'package:totem_pro_admin/models/scheduled_pause.dart';
import 'package:totem_pro_admin/widgets/app_toasts.dart';
import '../../../../widgets/app_toasts.dart' as AppToasts;
import 'pause_list_item_card.dart';

class HolidaysView extends StatelessWidget {
  final Function(Holiday holiday, ScheduledPause? existingPause) onConfigureHoliday;

  const HolidaysView({super.key, required this.onConfigureHoliday});

  @override
  Widget build(BuildContext context) {
    context.read<StoresManagerCubit>().fetchHolidays();

    return BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded || state.holidays == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final holidays = state.holidays!;
        final pauses = state.activeStore!.scheduledPauses;
        final Map<String, List<Holiday>> holidaysByMonth = {};
        for (var holiday in holidays) {
          final monthKey = DateFormat('MMMM yyyy', 'pt_BR').format(holiday.date.toLocal());
          if (holidaysByMonth[monthKey] == null) {
            holidaysByMonth[monthKey] = [];
          }
          holidaysByMonth[monthKey]!.add(holiday);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ CABEÇALHO ADICIONADO
            Text('Calendário de feriados',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Text(
              'Configure os horários de pausa da sua loja nos próximos feriados.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
SizedBox(height: 38,),
            ListView.separated(
              itemCount: holidaysByMonth.keys.length,
              // ✅ SEPARADOR (DIVIDER) ENTRE OS MESES
              separatorBuilder: (context, index) =>  Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Divider(height: 1, color: Colors.grey[300]),
              ),


              primary: false,
              shrinkWrap: true,

              itemBuilder: (context, index) {

                final monthAndYearKey = holidaysByMonth.keys.elementAt(index);
                final monthHolidays = holidaysByMonth[monthAndYearKey]!;

                // ✅ LÓGICA PARA EXIBIR APENAS O NOME DO MÊS
                final monthName = DateFormat('MMMM', 'pt_BR').format(monthHolidays.first.date.toLocal());

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0, left: 4),
                      child: Text(
                        monthName[0].toUpperCase() + monthName.substring(1),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                      ),
                    ),
                    ...monthHolidays.map((holiday) {
                      ScheduledPause? existingPause;
                      try {
                        existingPause = pauses.firstWhere(
                              (p) => DateUtils.isSameDay(p.startTime.toLocal(), holiday.date),
                        );
                      } catch (e) {
                        existingPause = null;
                      }
                      if (existingPause != null) {
                        return PauseListItemCard(
                          pause: existingPause,
                          onEdit: () => onConfigureHoliday(holiday, existingPause),
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Confirmar Exclusão'),
                                content: const Text('Tem certeza que deseja remover esta pausa programada?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: const Text('Remover', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              final success = await context.read<StoresManagerCubit>().deletePause(pauseId: existingPause!.id);
                              if (success && context.mounted) {
                                AppToasts.showSuccess('Pausa removida com sucesso!');
                              }
                            }
                          },
                        );
                      } else {
                        // ✅ USA O NOVO WIDGET RESPONSIVO
                        return _HolidayListItem(
                          holiday: holiday,
                          onConfigure: () => onConfigureHoliday(holiday, null),
                        );
                      }
                    }).toList(),
                    const SizedBox(height: 24),
                  ],
                );
              },
            )
          ],
        );
      },
    );
  }
}

// ✅ WIDGET ATUALIZADO PARA SER RESPONSIVO
class _HolidayListItem extends StatelessWidget {
  final Holiday holiday;
  final VoidCallback onConfigure;

  const _HolidayListItem({
    required this.holiday,
    required this.onConfigure,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: isMobile
          ? _buildMobileLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  // Layout para Desktop (Linha)
  Widget _buildDesktopLayout(BuildContext context) {
    final dayName = DateFormat('EEEE', 'pt_BR').format(holiday.date);
    final formattedDate = DateFormat('dd/MM/yyyy').format(holiday.date);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(holiday.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text('$dayName, $formattedDate', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
        TextButton(
          onPressed: () => Future.delayed(Duration.zero, onConfigure),
          child: const Text('Configurar horário'),
        )
      ],
    );
  }

  // Layout para Mobile (Coluna)
  Widget _buildMobileLayout(BuildContext context) {
    final dayName = DateFormat('EEEE', 'pt_BR').format(holiday.date);
    final formattedDate = DateFormat('dd/MM/yyyy').format(holiday.date);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(holiday.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text('$dayName, $formattedDate', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Future.delayed(Duration.zero, onConfigure),
            child: const Text('Configurar horário'),
          ),
        )
      ],
    );
  }
}