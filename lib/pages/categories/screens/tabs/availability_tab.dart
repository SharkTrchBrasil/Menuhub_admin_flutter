import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/widgets/tab_header.dart';
import '../../../../core/enums/available_type.dart';

import 'package:totem_pro_admin/pages/categories/cubit/category_wizard_cubit.dart';

import '../../../../models/availability_model.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/pages/categories/screens/tabs/widgets/tab_header.dart';
import '../../../../core/enums/available_type.dart';
import 'package:totem_pro_admin/pages/categories/cubit/category_wizard_cubit.dart';
import '../../../../models/availability_model.dart';

class AvailabilityTab extends StatelessWidget {
  const AvailabilityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryWizardCubit>();

    return BlocBuilder<CategoryWizardCubit, CategoryWizardState>(
      // Otimização para reconstruir apenas quando os dados de disponibilidade mudarem
      buildWhen: (p, c) => p.availabilityType != c.availabilityType || p.schedules != c.schedules,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TabHeader(
                title: 'Disponibilidade',
                subtitle: 'Defina quando os itens desta categoria poderão ser comprados',
              ),
              const SizedBox(height: 24),
              _buildTypeSelector(context, state.availabilityType),
              const SizedBox(height: 24),
              if (state.availabilityType == AvailabilityType.scheduled)
                Column(
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.schedules.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        final rule = state.schedules[index];
                        return _ScheduleRuleCard(
                          // Passa a regra inteira, que contém o localId
                          key: ValueKey(rule.localId),
                          rule: rule,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    // Botão para adicionar novas regras de horário
                    OutlinedButton.icon(
                      onPressed: cubit.addScheduleRule,
                      icon: const Icon(Icons.add),
                      label: const Text("Adicionar outra regra de horário"),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeSelector(BuildContext context, AvailabilityType currentType) {
    final cubit = context.read<CategoryWizardCubit>();
    return Column(
      children: [
        RadioListTile<AvailabilityType>(
          title: const Text('Sempre disponível'),
          subtitle: const Text('Disponível sempre que o restaurante estiver aberto.'),
          value: AvailabilityType.always,
          groupValue: currentType,
          onChanged: (value) => cubit.availabilityTypeChanged(value!),
          activeColor: Theme.of(context).primaryColor,
        ),
        RadioListTile<AvailabilityType>(
          title: const Text('Dias e horários específicos'),
          subtitle: const Text('Defina períodos específicos de disponibilidade.'),
          value: AvailabilityType.scheduled,
          groupValue: currentType,
          onChanged: (value) => cubit.availabilityTypeChanged(value!),
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
}

// Widget para o card de uma regra de horário
class _ScheduleRuleCard extends StatelessWidget {
  final ScheduleRule rule;
  // ✅ REMOVIDO: Não precisamos mais do índice
  // final int ruleIndex;

  const _ScheduleRuleCard({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryWizardCubit>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Dias da semana', style: TextStyle(fontWeight: FontWeight.bold)),
              // Botão para remover a regra inteira
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey),
                onPressed: () => cubit.removeScheduleRule(rule.localId!),
                tooltip: 'Remover esta regra de horário',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _WeekDaySelector(
            selectedDays: rule.days,
            onDayToggled: (dayIndex) {
              // ✅ CORRIGIDO: Passa o localId da regra
              cubit.toggleDay(rule.localId, dayIndex);
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Horários', style: TextStyle(fontWeight: FontWeight.bold)),
              TextButton.icon(
                // ✅ CORRIGIDO: Passa o localId da regra
                onPressed: () => cubit.addShift(rule.localId),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Adicionar turno', overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rule.shifts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, shiftIndex) {
              return _TimeShiftSelector(
                shift: rule.shifts[shiftIndex],
                // ✅ CORRIGIDO: Passa o localId da regra
                ruleLocalId: rule.localId,
                shiftIndex: shiftIndex,
              );
            },
          ),
        ],
      ),
    );
  }
}

// Em: availability_tab.dart

// Seletor de horário
class _TimeShiftSelector extends StatelessWidget {
  final TimeShift shift;
  final String ruleLocalId;
  final int shiftIndex;

  const _TimeShiftSelector({
    required this.shift,
    required this.ruleLocalId,
    required this.shiftIndex,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryWizardCubit>();
    // Geramos a lista de horários. (Esta função auxiliar deve estar no arquivo)
    final timeSlots = _generateTimeSlots(10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${shiftIndex + 1}º turno', style: const TextStyle(fontWeight: FontWeight.bold)),

            // ✅ CORREÇÃO LÓGICA: Encontra a regra pelo localId para verificar o tamanho da lista de turnos
            if (context.watch<CategoryWizardCubit>().state.schedules.firstWhere((r) => r.localId == ruleLocalId).shifts.length > 1)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                onPressed: () => cubit.removeShift(ruleLocalId, shiftIndex),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TimePickerDropdown(
                selectedValue: shift.startTime,
                timeSlots: timeSlots,
                onChanged: (time) {
                  if (time != null) {
                    // ✅ CORREÇÃO DO ERRO: Passa o 'ruleLocalId' em vez de 'ruleIndex'
                    cubit.updateShiftTime(ruleLocalId, shiftIndex, time, isStart: true);
                  }
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('às'),
            ),
            Expanded(
              child: TimePickerDropdown(
                selectedValue: shift.endTime,
                timeSlots: timeSlots,
                onChanged: (time) {
                  if (time != null) {
                    // ✅ CORREÇÃO DO ERRO: Passa o 'ruleLocalId' em vez de 'ruleIndex'
                    cubit.updateShiftTime(ruleLocalId, shiftIndex, time, isStart: false);
                  }
                },
                validator: (endTime) {
                  // A validação está correta
                  if (shift.startTime != null && endTime != null) {
                    final startMinutes = shift.startTime!.hour * 60 + shift.startTime!.minute;
                    final endMinutes = endTime.hour * 60 + endTime.minute;
                    if (endMinutes <= startMinutes) {
                      return 'Inválido';
                    }
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        // A mensagem de erro está correta
        if (shift.startTime != null && shift.endTime != null &&
            (shift.endTime!.hour * 60 + shift.endTime!.minute) <= (shift.startTime!.hour * 60 + shift.startTime!.minute))
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              '❗️Final do turno deve ser maior que o início.',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}


class TimePickerDropdown extends StatelessWidget {
  final TimeOfDay? selectedValue;
  final ValueChanged<TimeOfDay?> onChanged;
  final List<TimeOfDay> timeSlots;
  final String hintText;
  final FormFieldValidator<TimeOfDay>? validator;

  const TimePickerDropdown({
    super.key,
    this.selectedValue,
    required this.onChanged,
    required this.timeSlots,
    this.hintText = 'Selecionar',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TimeOfDay>(
      value: selectedValue,
      hint: Text(hintText),
      isExpanded: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: timeSlots.map((time) {
        return DropdownMenuItem<TimeOfDay>(
          value: time,
          child: Text(time.format(context)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}



List<TimeOfDay> _generateTimeSlots(int intervalInMinutes) {
  final List<TimeOfDay> slots = [];
  int hour = 0;
  int minute = 0;

  while (hour < 24) {
    slots.add(TimeOfDay(hour: hour, minute: minute));
    minute += intervalInMinutes;
    if (minute >= 60) {
      hour++;
      minute = 0;
    }
  }
  return slots;
}



// Em availability_tab.dart

class _WeekDaySelector extends StatelessWidget {
  final List<bool> selectedDays;
  final ValueChanged<int> onDayToggled;
  final List<String> _dayLabels = const ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

  const _WeekDaySelector({required this.selectedDays, required this.onDayToggled});

  @override
  Widget build(BuildContext context) {
    // ✅ CORREÇÃO: Substituímos Row por Wrap
    return Wrap(
      spacing: 8.0, // Espaço horizontal entre os círculos
      runSpacing: 8.0, // Espaço vertical entre as linhas (quando quebrar)
      alignment: WrapAlignment.spaceBetween, // Distribui o espaço
      children: List.generate(7, (index) {
        final isSelected = selectedDays[index];
        return GestureDetector(
          onTap: () => onDayToggled(index),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEA1D2C) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: isSelected ? const Color(0xFFEA1D2C) : Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                _dayLabels[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

