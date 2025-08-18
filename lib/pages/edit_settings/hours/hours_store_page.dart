

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totem_pro_admin/core/responsive_builder.dart';
import 'package:totem_pro_admin/models/store_hour.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/add_pause_dialog.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/add_shift_dialog.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/edit_shift_dialog.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/scheduled_pauses_view.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/visual_schedule_calendar.dart';
import 'package:totem_pro_admin/repositories/store_repository.dart';

import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/core/di.dart';

// Imports dos novos widgets
import '../../../cubits/store_manager_cubit.dart';
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
    0: 'Domingo', 1: 'Segunda', 2: 'Terça', 3: 'Quarta',
    4: 'Quinta', 5: 'Sexta', 6: 'Sábado',
  };
  final List<int> displayOrder = [1, 2, 3, 4, 5, 6, 0];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _populateHoursFromInitialData(widget.initialHours);

    // ✅ 1. ADICIONA O LISTENER
    // Isso fará com que a UI se atualize sempre que uma nova aba for selecionada.
    _tabController.addListener(() {
      setState(() {});
    });
  }

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



  Future<bool> save({bool showSuccessToast = true}) async { // ✅ Adiciona parâmetro opcional
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
        // ✅ Mostra o toast apenas se solicitado
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
        if (currentSlot.openingTime == null ||
            currentSlot.closingTime == null) {
          AppToasts.showError('Horário inválido em ${dayNames[weekday]}');
          return false;
        }

        final openingMinutes =
            currentSlot.openingTime!.hour * 60 + currentSlot.openingTime!.minute;
        final closingMinutes = currentSlot.closingTime!.hour * 60 +
            currentSlot.closingTime!.minute;

        if (openingMinutes >= closingMinutes) {
          AppToasts.showError(
              'Abertura deve ser antes do fechamento em ${dayNames[weekday]}');
          return false;
        }

        if (i > 0) {
          final previousSlot = slots[i - 1];
          final previousClosingMinutes = previousSlot.closingTime!.hour * 60 +
              previousSlot.closingTime!.minute;
          if (openingMinutes < previousClosingMinutes) {
            AppToasts.showError(
                'Sobreposição de horários em ${dayNames[weekday]}');
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
      _openingHours[weekday]![shiftIndex] =
          slot.copyWith(openingTime: newTime);
    });
  }

  void _updateClosingTime(int weekday, int shiftIndex, TimeOfDay newTime) {
    setState(() {
      final slot = _openingHours[weekday]![shiftIndex];
      _openingHours[weekday]![shiftIndex] =
          slot.copyWith(closingTime: newTime);
    });
  }


  // ✅ 1. CRIE UMA NOVA FUNÇÃO PARA ADICIONAR UM TURNO ESPECÍFICO
  void _addSpecificSlot(int weekday, TimeOfDay openingTime, TimeOfDay closingTime) {
    // Não precisa de setState aqui, pois será chamado dentro de um
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

  // ✅ 2. CRIE A FUNÇÃO PARA MOSTRAR O DIÁLOGO DE ADIÇÃO
  Future<void> _showAddShiftDialog(int day, TimeOfDay time) async {
    final result = await showDialog<AddShiftResult>(
      context: context,
      builder: (context) => AddShiftDialog(
        initialDay: day,
        initialTime: time,
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

    // Salva automaticamente após adicionar
  //  setState(() { _isSaving = true; });

    final bool success = await save(showSuccessToast: false);
    if (mounted) {

    //  setState(() { _isSaving = false; });

    }
    if (success && mounted) {
      AppToasts.showSuccess('Novo(s) horário(s) salvo(s) com sucesso!');
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

    // Atualiza o estado local primeiro para uma resposta de UI imediata
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



    await save(); // Salva no banco de dados


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
    return Scaffold(
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding:  EdgeInsets.symmetric(horizontal:  ResponsiveBuilder.isMobile(context) ? 8 : 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.isInWizard)
            FixedHeader(
              title: 'Horário de funcionamento',
              subtitle:
              'Escolha os dias e horários que sua loja receberá pedidos.',

            ),

          SizedBox(height: 25,),
          TabBar(

            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Horários'),
              Tab(text: 'Pausa programada'),
              Tab(text: 'Feriados'),
            ],
          ),
          const SizedBox(height: 24),

          [
            _buildSchedulesView(), // Conteúdo da Aba 0
            ScheduledPausesView(onAddPause: _showAddPauseDialog),
            const Center(child: Text('Funcionalidade de Feriados em breve.')), // Aba 2
          ][_tabController.index], // Seleciona o widget com base no índice da aba



          // TabBarView(
          //   controller: _tabController,
          //   children: [
          //     _buildSchedulesView(),
          //     const Center(
          //         child: Text('Funcionalidade de Pausa Programada em breve.')),
          //     const Center(child: Text('Funcionalidade de Feriados em breve.')),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildSchedulesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        ActionAndSummaryPanel(openingHours: _openingHours),
        const SizedBox(height: 20),
        // O widget refatorado é chamado aqui
      //  const InfoAlert(),
        const SizedBox(height: 20),

        VisualScheduleCalendar(
          openingHours: _openingHours,
          dayNames: dayNames,
          displayOrder: displayOrder,
          onShiftTap: (slot) {
            _showEditShiftDialog(slot);
          },
          onEmptySpaceTap: (day, time) {

            _showAddShiftDialog(day, time);
          },
        ),

      ],
    );
  }
}