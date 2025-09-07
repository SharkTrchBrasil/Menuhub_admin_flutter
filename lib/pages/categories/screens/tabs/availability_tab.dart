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
    return BlocBuilder<CategoryWizardCubit, CategoryWizardState>(
      buildWhen: (p, c) => p.availabilityType != c.availabilityType || p.schedules != c.schedules,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ✅ 2. SUBSTITUA O TEXTO ANTIGO PELO NOVO WIDGET
              TabHeader(
                title: 'Disponibilidade',
                subtitle:  'Defina quando os itens desta categoria poderão ser comprados',

              ),


              const SizedBox(height: 16),
              _buildTypeSelector(context, state.availabilityType),
              const SizedBox(height: 24),
              // O ListView agora sempre terá o que mostrar quando 'scheduled' for selecionado
              if (state.availabilityType == AvailabilityType.scheduled)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.schedules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    return _ScheduleRuleCard(
                      key: ValueKey(state.schedules[index].id),
                      rule: state.schedules[index],
                      ruleIndex: index,
                    );
                  },
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
          activeColor: const Color(0xFFEA1D2C),
        ),
        RadioListTile<AvailabilityType>(
          title: const Text('Dias e horários específicos'),
          subtitle: const Text('Defina períodos específicos de disponibilidade.'),
          value: AvailabilityType.scheduled,
          groupValue: currentType,
          onChanged: (value) => cubit.availabilityTypeChanged(value!),
          activeColor: const Color(0xFFEA1D2C),
        ),
      ],
    );
  }
}

// Widget para o card de uma regra de horário
class _ScheduleRuleCard extends StatelessWidget {
  final ScheduleRule rule;
  final int ruleIndex;
  const _ScheduleRuleCard({super.key, required this.rule, required this.ruleIndex});

  @override
  Widget build(BuildContext context) {
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
          const Text('Dias da semana', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _WeekDaySelector(
            selectedDays: rule.days,
            onDayToggled: (dayIndex) {
              context.read<CategoryWizardCubit>().toggleDay(ruleIndex, dayIndex);
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Horários', style: TextStyle(fontWeight: FontWeight.bold)),
              Flexible(
                child: TextButton.icon(
                  onPressed: () => context.read<CategoryWizardCubit>().addShift(ruleIndex),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Adicionar turno', overflow: TextOverflow.ellipsis,),
                ),
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
                ruleIndex: ruleIndex,
                shiftIndex: shiftIndex,
              );
            },
          ),
        ],
      ),
    );
  }
}



// --- NOVO SELETOR DE HORÁRIO COM DROPDOWNS ---
class _TimeShiftSelector extends StatelessWidget {
  final TimeShift shift;
  final int ruleIndex;
  final int shiftIndex;

  const _TimeShiftSelector({
    required this.shift,
    required this.ruleIndex,
    required this.shiftIndex,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CategoryWizardCubit>();
    // Geramos a lista de horários com intervalo de 10 minutos
    final timeSlots = _generateTimeSlots(10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${shiftIndex + 1}º turno', style: const TextStyle(fontWeight: FontWeight.bold)),
            if (cubit.state.schedules[ruleIndex].shifts.length > 1)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                onPressed: () => cubit.removeShift(ruleIndex, shiftIndex),
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
                    cubit.updateShiftTime(ruleIndex, shiftIndex, time, isStart: true);
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
                    cubit.updateShiftTime(ruleIndex, shiftIndex, time, isStart: false);
                  }
                },
                // ✅ VALIDAÇÃO PARA O HORÁRIO FINAL
                validator: (endTime) {
                  if (shift.startTime != null && endTime != null) {
                    final startMinutes = shift.startTime!.hour * 60 + shift.startTime!.minute;
                    final endMinutes = endTime.hour * 60 + endTime.minute;
                    if (endMinutes <= startMinutes) {
                      return 'Inválido'; // A mensagem de erro principal já está na UI
                    }
                  }
                  return null; // Válido
                },
              ),
            ),
          ],
        ),
        // Mensagem de erro que aparece abaixo dos dropdowns
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

