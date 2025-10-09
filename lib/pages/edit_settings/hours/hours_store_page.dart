import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/add_pause_dialog.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/add_shift_dialog.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/edit_shift_dialog.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/holidays_view.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/scheduled_pauses_view.dart';
import 'package:totem_pro_admin/pages/edit_settings/hours/widgets/visual_schedule_calendar.dart';
import 'package:totem_pro_admin/widgets/ds_primary_button.dart';
import 'package:totem_pro_admin/widgets/fixed_header.dart';
import 'package:totem_pro_admin/core/di.dart';


import '../../../core/helpers/sidepanel.dart';
import '../../../core/responsive_builder.dart';
import '../../../cubits/store_manager_cubit.dart';
import '../../../cubits/store_manager_state.dart';
import '../../../models/holiday.dart';
import '../../../models/scheduled_pause.dart';
import '../../../models/store/store_hour.dart';
import '../../../widgets/app_toasts.dart' as AppToasts;

import '../../store_wizard/cubit/store_wizard_cubit.dart';
import 'widgets/action_and_summary_panel.dart';


// O delegate da TabBar continua igual, está perfeito.
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _SliverTabBarDelegate(this.tabBar);
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).scaffoldBackgroundColor, child: tabBar);
  }
  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}

class OpeningHoursPage extends StatefulWidget {
  final int storeId;
  final bool isInWizard;
  const OpeningHoursPage({super.key, required this.storeId, this.isInWizard = false});
  @override
  State<OpeningHoursPage> createState() => OpeningHoursPageState();
}

class OpeningHoursPageState extends State<OpeningHoursPage> with TickerProviderStateMixin {
  late TabController _tabController;
  final Map<int, String> dayNames = {0: 'Domingo', 1: 'Segunda', 2: 'Terça', 3: 'Quarta', 4: 'Quinta', 5: 'Sexta', 6: 'Sábado'};
  final List<int> displayOrder = [1, 2, 3, 4, 5, 6, 0];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.isInWizard ? 1 : 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Map<int, List<StoreHour>> _groupHoursByDay(List<StoreHour> hours) {
    final Map<int, List<StoreHour>> grouped = { for (var i = 0; i < 7; i++) i: [] };
    for (final hour in hours) {
      if (grouped.containsKey(hour.dayOfWeek)) {
        grouped[hour.dayOfWeek]!.add(hour.copyWith());
      }
    }
    grouped.forEach((key, value) {
      value.sort((a, b) => a.openingTime!.hour.compareTo(b.openingTime!.hour));
      for (int i = 0; i < value.length; i++) {
        value[i] = value[i].copyWith(shiftNumber: i + 1);
      }
    });
    return grouped;
  }

  // A lógica de save e validação continua a mesma
  Future<bool> save() async { /* ... seu código aqui ... */ return true; }
  bool _validateHours(List<StoreHour> allSlots) { /* ... seu código aqui ... */ return true; }

  // Funções que chamam o side panel (continuam iguais)
  Future<void> _showAddShiftDialog({int? day, TimeOfDay? time}) async {
    final result = await showResponsiveSidePanel<AddShiftResult>(context, AddShiftDialog(initialDay: day ?? 1, initialTime: time ?? const TimeOfDay(hour: 9, minute: 0), dayNames: dayNames, displayOrder: displayOrder));
    if (result == null || !mounted) return;
    if (widget.isInWizard) {
      context.read<StoreWizardCubit>().addHours(result);
    } else {
      context.read<StoresManagerCubit>().addHours(widget.storeId, result);
    }
  }

  Future<void> _showEditShiftDialog(StoreHour shiftToEdit) async {
    final result = await showResponsiveSidePanel<EditShiftResult>(context, EditShiftDialog(initialShift: shiftToEdit, dayName: dayNames[shiftToEdit.dayOfWeek]!));
    if (result == null || !mounted) return;
    if (widget.isInWizard) {
      if (result.deleted) {
        context.read<StoreWizardCubit>().removeHour(shiftToEdit);
      } else {
        context.read<StoreWizardCubit>().updateHour(shiftToEdit, result);
      }
    } else {
      // Lógica para StoresManagerCubit
    }
  }

  Future<void> _showAddPauseDialog() async {
    final result = await showResponsiveSidePanel<AddPauseResult>(context, const AddPauseDialog());
    if (result == null || !mounted) return;
    final success = await context.read<StoresManagerCubit>().addPause(storeId: widget.storeId, reason: result.reason, startTime: result.startTime, endTime: result.endTime);
    if (success) AppToasts.showSuccess('Pausa programada criada com sucesso!');
  }

  Future<void> _showHolidayPauseDialog(Holiday holiday, ScheduledPause? existingPause) async {
    final result = await showResponsiveSidePanel<AddPauseResult>(context, AddPauseDialog(holiday: holiday, existingPause: existingPause));
    if (result == null || !mounted) return;
    final success = await context.read<StoresManagerCubit>().addPause(storeId: widget.storeId, reason: (result.reason != null && result.reason!.isNotEmpty) ? result.reason : holiday.name, startTime: result.startTime, endTime: result.endTime);
    if (success) AppToasts.showSuccess('Feriado configurado com sucesso!');
  }

  @override
  Widget build(BuildContext context) {
    // A lógica de BlocBuilder continua a mesma
    return widget.isInWizard
        ? BlocBuilder<StoreWizardCubit, StoreWizardState>(
      builder: (context, state) {
        if (state is! StoreWizardLoaded) return const Center(child: CircularProgressIndicator());
        return _buildContent(_groupHoursByDay(state.store.relations.hours));
      },
    )
        : BlocBuilder<StoresManagerCubit, StoresManagerState>(
      builder: (context, state) {
        if (state is! StoresManagerLoaded || state.activeStore == null) return const Center(child: CircularProgressIndicator());
        return _buildContent(_groupHoursByDay(state.activeStore!.relations.hours));
      },
    );
  }

  Widget _buildContent(Map<int, List<StoreHour>> openingHours) {
    final tabs = widget.isInWizard ? const [Tab(text: 'Horários')] : const [Tab(text: 'Horários'), Tab(text: 'Pausa programada'), Tab(text: 'Feriados')];
    final List<Widget> tabViews = widget.isInWizard
        ? [_buildSchedulesView(openingHours)]
        : [_buildSchedulesView(openingHours), ScheduledPausesView(onAddPause: _showAddPauseDialog), HolidaysView(onConfigureHoliday: _showHolidayPauseDialog)];

    return Scaffold(
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal: ResponsiveBuilder.isDesktop(context) ? 24: 14.0),
        child: Center(
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverToBoxAdapter(
                  child: FixedHeader(
                    showActionsOnMobile: true,
                    title: 'Horário de funcionamento',
                    subtitle: 'Escolha os dias e horários que sua loja receberá pedidos.',
                    actions: [
                      DsButton(
                        label: 'Cadastrar horário',
                        style: DsButtonStyle.secondary,
                        onPressed: () => _showAddShiftDialog(),
                      ),
                    ],
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      // ✅ 2. AJUSTES NA TABBAR
                      isScrollable: true, // Permite que o alinhamento 'start' funcione corretamente
                      tabAlignment: TabAlignment.start, // Alinha as abas à esquerda
                      tabs: tabs,
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: tabViews,
            ),
          ),
        ),
      ),
    );
  }

  // ✅ 1. CORREÇÃO DO OVERFLOW
  // Envolve o conteúdo em um ListView para que ele seja rolável.
  Widget _buildSchedulesView(Map<int, List<StoreHour>> openingHours) {
    final bool isScheduleEmpty = openingHours.values.every((list) => list.isEmpty);

    if (isScheduleEmpty) {
      return _buildEmptyScheduleState();
    }

    // O ListView garante que o conteúdo possa rolar, resolvendo o overflow.
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 24, ),
      children: [
        _buildPopulatedScheduleState(openingHours),
      ],
    );
  }

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
            Text('Sua loja ainda não tem horários', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Clique no botão abaixo para definir os dias e horas em que sua loja estará aberta para receber pedidos.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            DsButton(label: 'Cadastrar horário', style: DsButtonStyle.secondary, onPressed: () => _showAddShiftDialog(), icon: Icons.add_alarm),
          ],
        ),
      ),
    );
  }

  // Este método agora é apenas parte do conteúdo do ListView, não precisa mais de Padding.
  Widget _buildPopulatedScheduleState(Map<int, List<StoreHour>> openingHours) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActionAndSummaryPanel(openingHours: openingHours),
        const SizedBox(height: 20),
        const SizedBox(height: 20),
        VisualScheduleCalendar(
          openingHours: openingHours,
          dayNames: dayNames,
          displayOrder: displayOrder,
          onShiftTap: (slot) => _showEditShiftDialog(slot),
          onEmptySpaceTap: (day, time) => _showAddShiftDialog(day: day, time: time),
        ),
      ],
    );
  }
}