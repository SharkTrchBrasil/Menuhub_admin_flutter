import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';

import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/add_pause_dialog.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/add_shift_dialog.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/edit_shift_dialog.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/holidays_view.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/scheduled_pauses_view.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/visual_schedule_calendar.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';

import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/core/di.dart';

// Imports dos novos widgets
import '../../../cubits/store_manager_cubit.dart';
import '../../../models/holiday.dart';
import '../../../models/scheduled_pause.dart';
import '../../../models/store/store_hour.dart';
import '../../../widgets/app_toasts.dart' as AppToasts;
import 'widgets/action_and_summary_panel.dart';

class OpeningHoursPage extends StatefulWidget {
  final int storeId;
  final bool isInWizard;
  final List<StoreHour> initialHours;

  const OpeningHoursPage({
    super.key,
    required this.storeId,
    this.isInWizard = false,
    required this.initialHours,
  });

  @override
  State<OpeningHoursPage> createState() => OpeningHoursPageState();
}

class OpeningHoursPageState extends State<OpeningHoursPage>
    with TickerProviderStateMixin {
  final StoreRepository storeRepository = getIt();
  late TabController _tabController;

  final Map<int, List<StoreHour>> _openingHours = {
    for (var i = 0; i < 7; i++) i: [],
  };

  final Map<int, String> dayNames = {
    0: 'Domingo',
    1: 'Segunda',
    2: 'Terça',
    3: 'Quarta',
    4: 'Quinta',
    5: 'Sexta',
    6: 'Sábado',
  };
  final List<int> displayOrder = [1, 2, 3, 4, 5, 6, 0];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _populateHoursFromInitialData(widget.initialHours);
    _tabController.addListener(() {
      setState(() {});
    });
  }


  // ✅ ================== CORREÇÃO APLICADA AQUI ==================
  @override
  void didUpdateWidget(covariant OpeningHoursPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Esta condição verifica se a lista de horários que o widget está recebendo
    // mudou. Isso acontece quando o `StoresManagerCubit` é atualizado pelo
    // WebSocket e reconstrói a tela.
    if (widget.initialHours != oldWidget.initialHours) {
      // Se os dados mudaram, repopulamos o estado local da UI com os novos dados.
      _populateHoursFromInitialData(widget.initialHours);
    }
  }
  // ================== FIM DA CORREÇÃO ==================


  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _populateHoursFromInitialData(List<StoreHour> hours) {
    for (var i = 0; i < 7; i++) {
      _openingHours[i] = [];
    }
    for (final hour in hours) {
      if (_openingHours.containsKey(hour.dayOfWeek)) {
        _openingHours[hour.dayOfWeek]!.add(hour.copyWith());
      }
    }
    _openingHours.forEach((key, value) {
      value.sort((a, b) => a.openingTime!.hour.compareTo(b.openingTime!.hour));
      for (int i = 0; i < value.length; i++) {
        value[i] = value[i].copyWith(shiftNumber: i + 1);
      }
    });
  }

  Future<bool> save({bool showSuccessToast = true}) async {
    if (!_validateHours()) return false;
    final allSlots = _openingHours.values.expand((slots) => slots).toList();
    final result = await storeRepository.updateHours(widget.storeId, allSlots);
    if (!mounted) return false;

    return result.fold(
          (error) {
        AppToasts.showError('Erro ao salvar os horários.');
        return false;
      },
          (success) {
        if (showSuccessToast) {
          AppToasts.showSuccess('Horários salvos com sucesso!');
        }
        return true;
      },
    );
  }

  bool _validateHours() {
    for (var weekday in _openingHours.keys) {
      final slots = _openingHours[weekday]!;
      slots.sort((a, b) => a.openingTime!.hour.compareTo(b.openingTime!.hour));

      for (int i = 0; i < slots.length; i++) {
        final currentSlot = slots[i];
        if (currentSlot.openingTime == null || currentSlot.closingTime == null) {
          AppToasts.showError('Horário inválido em ${dayNames[weekday]}');
          return false;
        }

        final openingMinutes = currentSlot.openingTime!.hour * 60 + currentSlot.openingTime!.minute;
        final closingMinutes = currentSlot.closingTime!.hour * 60 + currentSlot.closingTime!.minute;

        if (openingMinutes >= closingMinutes) {
          AppToasts.showError('Abertura deve ser antes do fechamento em ${dayNames[weekday]}');
          return false;
        }

        if (i > 0) {
          final previousSlot = slots[i - 1];
          final previousClosingMinutes = previousSlot.closingTime!.hour * 60 + previousSlot.closingTime!.minute;
          if (openingMinutes < previousClosingMinutes) {
            AppToasts.showError('Sobreposição de horários em ${dayNames[weekday]}');
            return false;
          }
        }
      }
    }
    return true;
  }

  void _removeSlot(int weekday, StoreHour slotToRemove) {
    setState(() {
      _openingHours[weekday]!.remove(slotToRemove);
    });
  }

  void _updateOpeningTime(int weekday, int shiftIndex, TimeOfDay newTime) {
    setState(() {
      final slot = _openingHours[weekday]![shiftIndex];
      _openingHours[weekday]![shiftIndex] = slot.copyWith(openingTime: newTime);
    });
  }

  void _updateClosingTime(int weekday, int shiftIndex, TimeOfDay newTime) {
    setState(() {
      final slot = _openingHours[weekday]![shiftIndex];
      _openingHours[weekday]![shiftIndex] = slot.copyWith(closingTime: newTime);
    });
  }

  void _addSpecificSlot(int weekday, TimeOfDay openingTime, TimeOfDay closingTime) {
    _openingHours[weekday]!.add(
      StoreHour(
        dayOfWeek: weekday,
        openingTime: openingTime,
        closingTime: closingTime,
        shiftNumber: _openingHours[weekday]!.length + 1,
        isActive: true,
      ),
    );
  }

  Future<void> _showAddShiftDialog({int? day, TimeOfDay? time}) async {
    final result = await showDialog<AddShiftResult>(
      context: context,
      builder: (context) => AddShiftDialog(
        initialDay: day ?? 1, // Padrão: Segunda-feira
        initialTime: time ?? const TimeOfDay(hour: 9, minute: 0), // Padrão: 09:00
        dayNames: dayNames,
        displayOrder: displayOrder,
      ),
    );

    if (result == null) return;

    setState(() {
      for (final selectedDay in result.selectedDays) {
        _addSpecificSlot(selectedDay, result.openingTime, result.closingTime);
      }
    });

    final bool success = await save(showSuccessToast: false);
    if (success && mounted) {
      AppToasts.showSuccess('Novo(s) horário(s) salvo(s) com sucesso!');
    }
  }

  Future<void> _showHolidayPauseDialog(Holiday holiday, ScheduledPause? existingPause) async {
    final result = await showDialog<AddPauseResult>(
      context: context,
      builder: (context) => AddPauseDialog(
        holiday: holiday,
        existingPause: existingPause,
      ),
    );

    if (result == null) return;

    if (existingPause != null) {
      // TODO: Lógica de atualização
    } else {
      final success = await context.read<StoresManagerCubit>().addPause(
        storeId: widget.storeId,
        reason: (result.reason != null && result.reason!.isNotEmpty) ? result.reason : holiday.name,
        startTime: result.startTime,
        endTime: result.endTime,
      );
      if (success && mounted) {
        AppToasts.showSuccess('Feriado configurado com sucesso!');
      }
    }
  }

  Future<void> _showEditShiftDialog(StoreHour shiftToEdit) async {
    final result = await showDialog<EditShiftResult>(
      context: context,
      builder: (context) => EditShiftDialog(
        initialShift: shiftToEdit,
        dayName: dayNames[shiftToEdit.dayOfWeek]!,
      ),
    );

    if (result == null) return;

    setState(() {
      final daySlots = _openingHours[shiftToEdit.dayOfWeek]!;
      final shiftIndex = daySlots.indexWhere((s) => s.shiftNumber == shiftToEdit.shiftNumber);
      if (shiftIndex == -1) return;

      if (result.deleted) {
        _removeSlot(shiftToEdit.dayOfWeek!, shiftToEdit);
      } else {
        if (result.openingTime != null) {
          _updateOpeningTime(shiftToEdit.dayOfWeek!, shiftIndex, result.openingTime!);
        }
        if (result.closingTime != null) {
          _updateClosingTime(shiftToEdit.dayOfWeek!, shiftIndex, result.closingTime!);
        }
      }
    });

    await save();
  }

  Future<void> _showAddPauseDialog() async {
    final result = await showDialog<AddPauseResult>(
      context: context,
      builder: (context) => const AddPauseDialog(),
    );

    if (result == null) return;

    final success = await context.read<StoresManagerCubit>().addPause(
      storeId: widget.storeId,
      reason: result.reason,
      startTime: result.startTime,
      endTime: result.endTime,
    );

    if (success) {
      AppToasts.showSuccess('Pausa programada criada com sucesso!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isInWizard ? _buildContent() : _buildStandalonePage();
  }

  Widget _buildStandalonePage() {
    return Scaffold(body: _buildContent());
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveBuilder.isMobile(context) ? 14 : 24.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isInWizard)
            FixedHeader(
              title: 'Horário de funcionamento',
              subtitle: 'Escolha os dias e horários que sua loja receberá pedidos.',
            ),
          const SizedBox(height: 25),
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).primaryColor,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            tabs: const [
              Tab(text: 'Horários'),
              Tab(text: 'Pausa programada'),
              Tab(text: 'Feriados'),
            ],
          ),
          const SizedBox(height: 24),
          [
            _buildSchedulesView(),
            ScheduledPausesView(onAddPause: _showAddPauseDialog),
            HolidaysView(onConfigureHoliday: _showHolidayPauseDialog),
          ][_tabController.index],
        ],
      ),
    );
  }

  // ✅ MÉTODO ATUALIZADO PARA SER INTELIGENTE
  Widget _buildSchedulesView() {
    // Verifica se há algum horário cadastrado em qualquer dia
    final bool isScheduleEmpty = _openingHours.values.every((list) => list.isEmpty);

    if (isScheduleEmpty) {
      // Se estiver vazio, mostra a tela de boas-vindas com o botão de ação
      return _buildEmptyScheduleState();
    } else {
      // Se houver horários, mostra a UI completa com o calendário
      return _buildPopulatedScheduleState();
    }
  }

  // ✅ NOVO WIDGET: UI para quando NÃO HÁ horários cadastrados
  Widget _buildEmptyScheduleState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.timer_off_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Sua loja ainda não tem horários',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Clique no botão abaixo para definir os dias e horas em que sua loja estará aberta para receber pedidos.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            DsButton(
              label: 'Cadastrar primeiro horário',
              onPressed: () => _showAddShiftDialog(), // Chama o diálogo diretamente
              icon: Icons.add_alarm,
            ),
          ],
        ),
      ),
    );
  }

  // ✅ NOVO WIDGET: UI para quando HÁ horários cadastrados (código anterior)
  Widget _buildPopulatedScheduleState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActionAndSummaryPanel(openingHours: _openingHours),
        const SizedBox(height: 20),
        const SizedBox(height: 20),
        VisualScheduleCalendar(
          openingHours: _openingHours,
          dayNames: dayNames,
          displayOrder: displayOrder,
          onShiftTap: (slot) {
            _showEditShiftDialog(slot);
          },
          onEmptySpaceTap: (day, time) {
            _showAddShiftDialog(day: day, time: time);
          },
        ),
      ],
    );
  }
}